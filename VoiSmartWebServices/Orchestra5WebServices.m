//
//  Orchestra5WebServices.m
//  VoiSmart Web Services
//
//  Created by Alex on 11/10/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "Orchestra5WebServices.h"

# pragma mark - Private constants -

static NSString *const PBX_UNDEFINED = @"PBX Url not defined";

static NSString *const LOG_PREFIX = @"Orchestra 5 WS";
static NSString *const PROTOCOL = @"https://";
static NSString *const AUTH_WS = @"/lib/webservices/common/auth_endpnt.php";
static NSString *const LICENSE_WS = @"/lib/webservices/common/externallicense_endpnt.php";
static NSString *const USERS_WS = @"/lib/webservices/common/users_endpnt.php";
static NSString *const PHONES_WS = @"/lib/webservices/pbx/phones_endpnt.php";
static NSString *const CDR_WS = @"/lib/webservices/pbx/cdr_endpnt.php";
static NSString *const PHONEBOOK_WS = @"/lib/webservices/common/ldapcontacts_endpnt.php";
static NSString *const FAX_WS = @"/lib/webservices/fax/faxnumberout_endpnt.php";

static NSInteger const TOKEN_VALIDITY = 300;
static NSTimeInterval const LICENSE_TOKEN_VALIDITY = 180; //expressed in seconds

@interface Orchestra5WebServices()

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *pbxUrl;

@property (nonatomic, strong) CachedStringWithFailureExpiration *loginToken;
@property (nonatomic, strong) CachedStringWithFailureExpiration *licenseToken;

- (void) log:(NSString *)message;

- (NSString *)getPbxUrl;

- (NSString *)getWebServiceUrl:(NSString *)webServiceEndpoint;

@end

@implementation Orchestra5WebServices

- (void)setUsername:(NSString *)username
           password:(NSString *)password
             pbxUrl:(NSString *)pbxUrl
{
    self.username = username;
    self.password = password;
    self.pbxUrl = pbxUrl;
    [self.loginToken reset];
    [self.licenseToken reset];
}

- (NSString *)getPbxUrl
{
    return [NSString stringWithFormat:@"%@%@", PROTOCOL, self.pbxUrl];
}

- (CachedStringWithFailureExpiration *)loginToken
{
    if (_loginToken == nil) _loginToken = [[CachedStringWithFailureExpiration alloc] init];
    return _loginToken;
}

- (CachedStringWithFailureExpiration *)licenseToken
{
    if (_licenseToken == nil) _licenseToken = [[CachedStringWithFailureExpiration alloc] init];
    return _licenseToken;
}

- (void) log:(NSString *)message
{
    NSLog(@"%@: %@", LOG_PREFIX, message);
}

- (NSString *)getWebServiceUrl:(NSString *)webServiceEndpoint
{
    return [NSString stringWithFormat:@"%@%@%@", PROTOCOL, self.pbxUrl, webServiceEndpoint];
}

- (void) loginAndSendResponseToDelegate:(id<VoiSmartWebServiceDelegate>)delegate
{
    if (self.pbxUrl == nil) {
        [self log:PBX_UNDEFINED];
        return;
    }
    
    [self requestWebServiceTokenAndExecute:^(BOOL success, NSError *error) {
        if ([delegate respondsToSelector:@selector(loginResponseReceivedWithSuccess:token:validityInSeconds:error:)]) {
            VSWebServiceError *vsError = nil;
            if (error)
                vsError = [[VSWebServiceError alloc] initWithErrorCode:VS_WS_CONNECTION_ERROR];
            
            [delegate loginResponseReceivedWithSuccess:success
                                                 token:[self.loginToken string]
                                     validityInSeconds:[self.loginToken cacheTime]
                                                 error:vsError];
        } else {
            [self log:@"Delegate does not implement loginResponseReceivedWithSuccess:token:validityInSeconds:error:"];
        }
    }];
}

- (void) requestWebServiceTokenAndExecute:(void (^)(BOOL, NSError *))callback
{
    if ([self.loginToken isNotNil]) {
        [self log:@"Returning already loaded web service token..."];
        callback(YES, nil);
        return;
    }
    
    [self log:@"Requesting new web service token..."];
    
    NSString *soapBody = [NSString stringWithFormat:
                          @"<ns1:loginUser soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\n"
                          "<username xsi:type=\"xsd:string\">%@</username>\n"
                          "<password xsi:type=\"xsd:string\">%@</password>\n"
                          "</ns1:loginUser>", self.username, self.password];
    
    VSSOAPRequest *request = [[VSSOAPRequest alloc] init];
    
    [request sendSOAPRequestToUrl:[self getWebServiceUrl:AUTH_WS]
                  soapRequestBody:soapBody
     
    executeWhenResponseIsSuccessful:^(DDXMLDocument *response) {
        BOOL success = NO;
        NSString *token = [[[response nodesForXPath:@"//return/token/text()" error:nil] lastObject] stringValue];
        NSString *tokenStr = @"";
        
        if (token && token.length > 0) {
            success = YES;
            tokenStr = token;
        }
        
        if (success == YES) {
            [self.loginToken setString:tokenStr andCacheFor:TOKEN_VALIDITY];
        } else {
            [self.loginToken reset];
        }
        
        callback(success, nil);
    }
     
    executeWhenAnErrorOccurs:^(NSError *error) {
        [self.loginToken reset];
        callback(NO, error);
    }];
}

- (void) getLicenseAndSendResponseToDelegate:(id<VoiSmartWebServiceDelegate>)delegate
{
    [self requestWebServiceTokenAndExecute:^(BOOL success, NSError *error) {
        
        if (success) {
            [self requestLicenseAndExecute:^(BOOL success, NSError *error) {
                if ([delegate respondsToSelector:@selector(receivedLicenseIsValid:withWebServiceToken:error:)]) {
                    VSWebServiceError *vsError = nil;
                    if (error)
                        vsError = [[VSWebServiceError alloc] initWithErrorCode:VS_WS_NO_LICENSE];
                    [delegate receivedLicenseIsValid:[self.loginToken isNotNil]
                                 withWebServiceToken:[self.loginToken string]
                                               error:vsError];
                } else {
                    [self log:@"Delegate does not implement receivedLicenseIsValid:withWebServiceToken:error:"];
                }
            }];
        } else {
            if ([delegate respondsToSelector:@selector(receivedLicenseIsValid:withWebServiceToken:error:)]) {
                VSWebServiceError *vsError = [[VSWebServiceError alloc] initWithErrorCode:VS_WS_CONNECTION_ERROR];
                [delegate receivedLicenseIsValid:[self.licenseToken isNotNil]
                             withWebServiceToken:[self.loginToken string]
                                           error:vsError];
            } else {
                [self log:@"Delegate does not implement receivedLicenseIsValid:withWebServiceToken:error:"];
            }
        }
    }];
}

- (void)requestLicenseAndExecute:(void (^)(BOOL, NSError *))callback
{
    if ([self.licenseToken isNotNil]) {
        [self log:@"Returning cached license token..."];
        callback(YES, nil);
        return;
    }
    
    [self log:@"Requesting new license token... "];

    NSString *soapBody = [NSString stringWithFormat:
                          @"<ns1:bookLicense soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\n"
                          "<token xsi:type=\"xsd:string\">%@</token>\n"
                          "<licensetype xsi:type=\"xsd:string\">softphone</licensetype>\n"
                          "</ns1:bookLicense>", [self.loginToken string]];
    
    VSSOAPRequest *request = [[VSSOAPRequest alloc] init];
    
    [request sendSOAPRequestToUrl:[self getWebServiceUrl:LICENSE_WS]
                  soapRequestBody:soapBody
     
    executeWhenResponseIsSuccessful:^(DDXMLDocument *response) {
        NSString *token = [[[response nodesForXPath:@"//return/text()" error:nil] lastObject] stringValue];
        
        if (token && [token length] > 0) {
            [self.licenseToken setString:token andCacheFor:LICENSE_TOKEN_VALIDITY];
        } else {
            [self.licenseToken registerFailure];
        }
        
        callback([self.licenseToken isNotNil], nil);
    }
     
    executeWhenAnErrorOccurs:^(NSError *error) {
        [self.licenseToken registerFailure];
        callback([self.licenseToken isNotNil], error);
    }];
}

- (void) getSipAccountWithToken:(NSString *)token
                    forUsername:(NSString *)username
                       delegate:(id<VoiSmartWebServiceDelegate>)delegate
{
    [self fetchSipAccountWithToken:token forUsername:username
   
     executeWhenResponseIsSuccessful:^(NSArray *sipAccounts) {
         if ([delegate respondsToSelector:@selector(receivedSipAccounts:error:)]) {
             [delegate receivedSipAccounts:sipAccounts error:nil];
         } else {
             [self log:@"Delegate does not implement receivedSipAccounts:error:"];
         }
     }
     
     executeWhenAnErrorOccurs:^(NSError *error) {
         if ([delegate respondsToSelector:@selector(receivedSipAccounts:error:)]) {
             VSWebServiceError *vsError = [[VSWebServiceError alloc] initWithErrorCode:VS_WS_CONNECTION_ERROR];
             [delegate receivedSipAccounts:nil error:vsError];
         } else {
             [self log:@"Delegate does not implement receivedSipAccounts:error:"];
         }
     }];
}

- (void) fetchSipAccountWithToken:(NSString *)token
                      forUsername:(NSString *)username
  executeWhenResponseIsSuccessful:(void (^)(NSArray *))successCallBack
         executeWhenAnErrorOccurs:(void (^)(NSError *))errorCallBack;
{
    [self getUserExtensionWithToken:token forUsername:username
    
    executeWhenResponseIsSuccessful:^(NSString *extension) {
        [self getExtensionIdWithToken:token forExtension:extension
        
         executeWhenResponseIsSuccessful:^(NSString *extensionId) {
             NSString *soapBody = [NSString stringWithFormat:
                            @"<ns1:getPhoneInfo soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\n"
                            "<token xsi:type=\"xsd:string\">%@</token>\n"
                            "<phoneId xsi:type=\"xsd:int\">%@</phoneId>\n"
                            "</ns1:getPhoneInfo>", token, extensionId];
             
             VSSOAPRequest *request = [[VSSOAPRequest alloc] init];
             
             [request sendSOAPRequestToUrl:[self getWebServiceUrl:PHONES_WS]
             soapRequestBody:soapBody
           
             executeWhenResponseIsSuccessful:^(DDXMLDocument *response) {
                 NSString *name = [[[response nodesForXPath:@"//return/teNome/text()" error:nil] lastObject] stringValue];
                 NSString *ext = [[[response nodesForXPath:@"//return/teExten/text()" error:nil] lastObject] stringValue];
                 NSString *pwd = [[[response nodesForXPath:@"//return/tePassword/text()" error:nil] lastObject] stringValue];
               
                 if (name && ext && pwd && [ext length] > 0 && [pwd length] > 0) {
                     VSSipAccountConfig *sipAccount = [[VSSipAccountConfig alloc] init];
                     sipAccount.displayName = name;
                     sipAccount.privateId = ext;
                     sipAccount.password = pwd;
                     sipAccount.realm = self.pbxUrl;
                     sipAccount.host = self.pbxUrl;
                     
                     NSArray *sipAccountsArray = [NSArray arrayWithObjects:sipAccount, nil];
                     
                     successCallBack(sipAccountsArray);
               
                 } else {
                     errorCallBack(nil);
                 }
             }
              
             executeWhenAnErrorOccurs:errorCallBack];
         }
         
         executeWhenAnErrorOccurs:errorCallBack];
    }
    
    executeWhenAnErrorOccurs:errorCallBack];
}

- (void) getUserExtensionWithToken:(NSString *)token
                       forUsername:(NSString *)username
   executeWhenResponseIsSuccessful:(void (^)(NSString *))successCallBack
          executeWhenAnErrorOccurs:(void (^)(NSError *))errorCallBack
{
    NSString *soapBody = [NSString stringWithFormat:
                    @"<ns1:getUserInfo soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\n"
                    "<token xsi:type=\"xsd:string\">%@</token>\n"
                    "<username xsi:type=\"xsd:string\">%@</username>\n"
                    "</ns1:getUserInfo>", token, username];
    
    VSSOAPRequest *request = [[VSSOAPRequest alloc] init];
    
    [request sendSOAPRequestToUrl:[self getWebServiceUrl:USERS_WS]
    soapRequestBody:soapBody
    executeWhenResponseIsSuccessful:^(DDXMLDocument *response) {
        NSString *ext = [[[response nodesForXPath:@"//return/utExten/text()" error:nil] lastObject] stringValue];
        
        if (ext && [ext length] > 0) {
            successCallBack(ext);
        } else {
            errorCallBack(nil);
        }
        
    }
    executeWhenAnErrorOccurs:errorCallBack];
}

- (void) getExtensionIdWithToken:(NSString *)token
                    forExtension:(NSString *)extension
 executeWhenResponseIsSuccessful:(void (^)(NSString *))successCallBack
        executeWhenAnErrorOccurs:(void (^)(NSError *))errorCallBack
{
    NSString *soapBody = [NSString stringWithFormat:
                    @"<ns1:getPhonesList soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\n"
                    "<token xsi:type=\"xsd:string\">%@</token>\n"
                      "<searchParams xsi:type=\"ns1:technologiesRecordPortion\">\n"
                    "<teExten xsi:type=\"xsd:string\">%@</teExten>\n"
                    "</searchParams>\n"
                    "<orderingColumn xsi:type=\"xsd:string\">teExten</orderingColumn>\n"
                    "<orderType xsi:type=\"xsd:string\">ASC</orderType>\n"
                    "</ns1:getPhonesList>", token, extension];
    
    VSSOAPRequest *request = [[VSSOAPRequest alloc] init];
    
    [request sendSOAPRequestToUrl:[self getWebServiceUrl:PHONES_WS]
    soapRequestBody:soapBody
  
    executeWhenResponseIsSuccessful:^(DDXMLDocument *response) {
        NSString *extId = [[[response nodesForXPath:@"//return/phones/item[1]/teId/text()" error:nil] lastObject] stringValue];
      
        if (extId && [extId length] > 0) {
            successCallBack(extId);
        } else {
            errorCallBack(nil);
        }
    }
    
    executeWhenAnErrorOccurs:errorCallBack];
}

- (void) getCallsWithToken:(NSString *)token
                  username:(NSString *)username
                      page:(int)page
            entriesPerPage:(int)entriesPerPage
                  delegate:(id<VoiSmartWebServiceDelegate>)delegate
{
    NSString *soapBody = [NSString stringWithFormat:
                         @"<ns1:getCalls soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\n"
                         "<token xsi:type=\"xsd:string\">%@</token>\n"
                         "<username xsi:type=\"xsd:string\">%@</username>\n"
                         "<searchParams xsi:type=\"ns1:cdrSearchParams\">\n"
                           "<callType xsi:type=\"xsd:int\">0</callType>\n"
                         "</searchParams>\n"
                         "<reqPage xsi:type=\"xsd:int\">%d</reqPage>\n"
                         "<entriesPerPage xsi:type=\"xsd:int\">%d</entriesPerPage>\n"
                         "</ns1:getCalls>", token, username, page, entriesPerPage];
    
    VSSOAPRequest *request = [[VSSOAPRequest alloc] init];
    
    [request sendSOAPRequestToUrl:[self getWebServiceUrl:CDR_WS]
    soapRequestBody:soapBody
     
    executeWhenResponseIsSuccessful:^(DDXMLDocument *response) {
        
        [self fetchSipAccountWithToken:token forUsername:username
         
        executeWhenResponseIsSuccessful:^(NSArray *sipAccounts) {
            VSSipAccountConfig *sipAccount = sipAccounts[0];
            NSArray *xmlCalls = [response nodesForXPath:@"//return/calls/item" error:nil];
            NSMutableArray *calls = nil;
            
            if (xmlCalls && [xmlCalls count] > 0) {
                calls = [NSMutableArray arrayWithCapacity:[xmlCalls count]];
                
                for (DDXMLElement *item in xmlCalls) {
                    [calls addObject:
                           [self getCallRegistryItemFromXMLitem:item
                                                  andUserNumber:sipAccount.privateId]];
                }
                
            }
            
            if ([delegate respondsToSelector:@selector(receivedCalls:error:)]) {
                [delegate receivedCalls:calls error:nil];
            } else {
                [self log:@"Delegate does not implement receivedCalls:error:"];
            }
        }
         
        executeWhenAnErrorOccurs:^(NSError *error) {
            if ([delegate respondsToSelector:@selector(receivedCalls:error:)]) {
                VSWebServiceError *vsError = [[VSWebServiceError alloc] initWithErrorCode:VS_WS_CONNECTION_ERROR];
                [delegate receivedCalls:nil error:vsError];
            } else {
                [self log:@"Delegate does not implement receivedCalls:error:"];
            }
        }];
    }
     
    executeWhenAnErrorOccurs:^(NSError *error){
        if ([delegate respondsToSelector:@selector(receivedCalls:error:)]) {
            VSWebServiceError *vsError = [[VSWebServiceError alloc] initWithErrorCode:VS_WS_CONNECTION_ERROR];
            [delegate receivedCalls:nil error:vsError];
        } else {
            [self log:@"Delegate does not implement receivedCalls:error:"];
        }
    }];
}

- (NSTimeInterval) getSecondsFromBillsec:(NSString *)billsec
{
    NSArray *temp = [billsec componentsSeparatedByString:@":"];
    
    NSTimeInterval seconds = 0.0;
    
    seconds += [NSString stringWithFormat:@"%@", temp[2]].intValue;
    seconds += [NSString stringWithFormat:@"%@", temp[1]].intValue * 60;
    seconds += [NSString stringWithFormat:@"%@", temp[0]].intValue * 3600;
    
    return seconds;
}

- (NSTimeInterval) getTimestampInSecondsFromDate:(NSString *)dateString
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    NSDate *date = [format dateFromString:dateString];
    return [date timeIntervalSince1970];
}

- (VSCallRegistryItem *)getCallRegistryItemFromXMLitem:(DDXMLElement *)xmlItem
                                         andUserNumber:(NSString *)userNumber
{
    
    NSString *billsec = [[[xmlItem nodesForXPath:@"billsec" error:nil] lastObject] stringValue];
    NSString *startTime = [[[xmlItem nodesForXPath:@"calldate" error:nil] lastObject] stringValue];
    NSTimeInterval billsecInt = [self getSecondsFromBillsec:billsec];
    NSTimeInterval startTimeInt = [self getTimestampInSecondsFromDate:startTime];
    NSTimeInterval endTimeInt = startTimeInt + billsecInt;
    
    NSString *src = [[[xmlItem nodesForXPath:@"src" error:nil] lastObject] stringValue];
    NSString *dst = [[[xmlItem nodesForXPath:@"dst" error:nil] lastObject] stringValue];
    
    VSCallRegistryItem *callItem = [[VSCallRegistryItem alloc] init];
    
    callItem.startTime = [NSDate dateWithTimeIntervalSince1970:startTimeInt];
    callItem.endTime = [NSDate dateWithTimeIntervalSince1970:endTimeInt];
    
    if ([userNumber isEqualToString:src]) {
        callItem.number = dst;
        callItem.callType = OUTGOING;
    } else {
        callItem.number = src;
        if (billsecInt == 0) {
            callItem.callType = MISSED;
        } else {
            callItem.callType = INCOMING;
        }
    }
    
    return callItem;
}

- (void) getContactsWithToken:(NSString *)token
                    searchFor:(NSString *)searchFor
                         page:(int)page
               entriesPerPage:(int)entriesPerPage
                     delegate:(id<VoiSmartWebServiceDelegate>)delegate
{
    NSString *soapBody = [NSString stringWithFormat:
            @"<ns1:ldapSearchAllContactsLite soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\n"
            "<token xsi:type=\"xsd:string\">%1$@</token>\n"
            "<searchFor xsi:type=\"ns1:ArrayOfstring\" soapenc:arrayType=\"xsd:string[3]\">\n"
              "<item xsi:type=\"xsd:string\">sn</item>\n"
              "<item xsi:type=\"xsd:string\">givenname</item>\n"
              "<item xsi:type=\"xsd:string\">o</item>\n"
            "</searchFor>\n"
            "<searchValue xsi:type=\"ns1:ArrayOfstring\" soapenc:arrayType=\"xsd:string[3]\">\n"
              "<item xsi:type=\"xsd:string\">%2$@</item>\n"
              "<item xsi:type=\"xsd:string\">%2$@</item>\n"
              "<item xsi:type=\"xsd:string\">%2$@</item>\n"
            "</searchValue>\n"
            "<numeroPagina xsi:type=\"xsd:int\">%3$d</numeroPagina>\n"
            "<entriesPerPagina xsi:type=\"xsd:int\">%4$d</entriesPerPagina>\n"
            "<tipoFiltro xsi:type=\"xsd:int\">1</tipoFiltro>\n"
            "<idRubrica xsi:type=\"xsd:int\">1</idRubrica>\n"
            "</ns1:ldapSearchAllContactsLite>", token, searchFor, page, entriesPerPage];
    
    VSSOAPRequest *request = [[VSSOAPRequest alloc] init];
    
    [request sendSOAPRequestToUrl:[self getWebServiceUrl:PHONEBOOK_WS]
    soapRequestBody:soapBody
     
    executeWhenResponseIsSuccessful:^(DDXMLDocument *response) {
        NSArray *xmlContacts = [response nodesForXPath:@"//return/entries/item" error:nil];
        NSMutableArray *contacts = nil;
        
        if (xmlContacts && [xmlContacts count] > 0) {
            contacts = [NSMutableArray arrayWithCapacity:[xmlContacts count]];
            
            for (DDXMLElement *item in xmlContacts) {
                [contacts addObject:[self bindContactFromXML:item]];
            }
            
        }
        
        if ([delegate respondsToSelector:@selector(receivedContacts:error:)]) {
            [delegate receivedContacts:contacts error:nil];
        } else {
            [self log:@"Delegate does not implement receivedContacts:error"];
        }
    }
     
    executeWhenAnErrorOccurs:^(NSError *error){
        if ([delegate respondsToSelector:@selector(receivedContacts:error:)]) {
            VSWebServiceError *vsError = [[VSWebServiceError alloc] initWithErrorCode:VS_WS_CONNECTION_ERROR];
            [delegate receivedContacts:nil error:vsError];
        } else {
            [self log:@"Delegate does not implement receivedContacts:error"];
        }
    }];
}

- (VSContact *) bindContactFromXML:(DDXMLElement *)xmlItem
{
    VSContact *contact = [[VSContact alloc] init];
    
    contact.title = [[[xmlItem nodesForXPath:@"title" error:nil] lastObject] stringValue];
    contact.name = [[[xmlItem nodesForXPath:@"givenname" error:nil] lastObject] stringValue];
    contact.surname = [[[xmlItem nodesForXPath:@"sn" error:nil] lastObject] stringValue];
    contact.company = [[[xmlItem nodesForXPath:@"o" error:nil] lastObject] stringValue];
    contact.email = [[[xmlItem nodesForXPath:@"mail" error:nil] lastObject] stringValue];
    contact.homePageUrl = [[[xmlItem nodesForXPath:@"url" error:nil] lastObject] stringValue];
    
    NSArray *vsNumbers = [xmlItem nodesForXPath:@"vsnumbers/item" error:nil];
    
    if (vsNumbers && [vsNumbers count] > 0) {
        for (DDXMLElement *vsnumber in vsNumbers) {
            NSString *type = [[[vsnumber nodesForXPath:@"vsnumtype" error:nil] lastObject] stringValue];
            NSString *number = [[[vsnumber nodesForXPath:@"vsnumber" error:nil] lastObject] stringValue];
            
            if (type == nil || number == nil) continue;
            else if ([type isEqualToString:@"TelUfficio"] || [type isEqualToString:@"Interno"]) {
                [contact.officePhones addObject:number];
            
            } else if ([type isEqualToString:@"Cellulare"]) {
                [contact.mobilePhones addObject:number];
            
            } else if ([type isEqualToString:@"Fax"]) {
                [contact.faxes addObject:number];
            
            } else if ([type isEqualToString:@"TelAbitazione"] || [type isEqualToString:@"TelAltro"]) {
                [contact.homePhones addObject:number];
            }
        }
    }
    
    return contact;
}

- (void) getExtensionsByUserWithToken:(NSString *)token
                             username:(NSString *)username
                             delegate:(id<VoiSmartWebServiceDelegate>)delegate
{
    NSString *uname = [VoiSmartWebServicesFactory getUsernameFromJabberIDstring:username];
    
    [self getUserExtensionWithToken:token forUsername:uname
     
    executeWhenResponseIsSuccessful:^(NSString *extension) {
        NSArray *extensions = [NSArray arrayWithObject:extension];
        if ([delegate respondsToSelector:@selector(receivedUserExtensions:error:)]) {
            [delegate receivedUserExtensions:extensions error:nil];
        } else {
            [self log:@"Delegate does not implement receivedUserExtensions:error:"];
        }
    }
     
    executeWhenAnErrorOccurs:^(NSError *error) {
        if ([delegate respondsToSelector:@selector(receivedUserExtensions:error:)]) {
            VSWebServiceError *vsError = [[VSWebServiceError alloc] initWithErrorCode:VS_WS_CONNECTION_ERROR];
            [delegate receivedUserExtensions:nil error:vsError];
        } else {
            [self log:@"Delegate does not implement receivedUserExtensions:error:"];
        }
    }];
}

- (void) getFaxNumbersWithToken:(NSString *)token
                       delegate:(id<VoiSmartWebServiceDelegate>)delegate
{
    [self getUserIdFromToken:token

    executeWhenResponseIsSuccessful:^(NSString *userId) {
        NSString *soapBody = [NSString stringWithFormat:
                    @"<ns1:retrieveUserAssociatedFaxNumbersOut soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\n"
                    "<token xsi:type=\"xsd:string\">%@</token>\n"
                    "<idUtenti xsi:type=\"ns1:ArrayOfint\" soapenc:arrayType=\"xsd:int[1]\">\n"
                    "<item xsi:type=\"xsd:int\">%@</item>\n"
                    "</idUtenti>\n"
                    "</ns1:retrieveUserAssociatedFaxNumbersOut>", token, userId];
        
        VSSOAPRequest *request = [[VSSOAPRequest alloc] init];
        
        [request sendSOAPRequestToUrl:[self getWebServiceUrl:FAX_WS]
        soapRequestBody:soapBody
         
        executeWhenResponseIsSuccessful:^(DDXMLDocument *response) {
            NSArray *xmlFaxes = [response nodesForXPath:@"//return/item" error:nil];
            NSMutableArray *faxNumbers = nil;
            
            if (xmlFaxes && [xmlFaxes count] > 0) {
                faxNumbers = [NSMutableArray arrayWithCapacity:[xmlFaxes count]];
                
                DDXMLElement *item __attribute__((unused));
                
                for (item in xmlFaxes) {
                    NSString *number = [[[response nodesForXPath:@"//faxNumberOutRecord/noNumeroFaxOut/text()" error:nil] lastObject] stringValue];
                    
                    if (number && [number length] > 0) {
                        [faxNumbers addObject:number];
                    }
                }
            }
            
            if ([delegate respondsToSelector:@selector(receivedFaxNumbers:error:)]) {
                [delegate receivedFaxNumbers:faxNumbers error:nil];
            } else {
                [self log:@"Delegate does not implement receivedFaxNumbers:error:"];
            }
        }
         
        executeWhenAnErrorOccurs:^(NSError *error) {
            if ([delegate respondsToSelector:@selector(receivedFaxNumbers:error:)]) {
                VSWebServiceError *vsError = [[VSWebServiceError alloc] initWithErrorCode:VS_WS_CONNECTION_ERROR];
                [delegate receivedFaxNumbers:nil error:vsError];
            } else {
                [self log:@"Delegate does not implement receivedFaxNumbers:error:"];
            }
        }];
    }
    
    executeWhenAnErrorOccurs:^(NSError *error) {
        if ([delegate respondsToSelector:@selector(receivedFaxNumbers:error:)]) {
            VSWebServiceError *vsError = [[VSWebServiceError alloc] initWithErrorCode:VS_WS_CONNECTION_ERROR];
            [delegate receivedFaxNumbers:nil error:vsError];
        } else {
            [self log:@"Delegate does not implement receivedFaxNumbers:error:"];
        }
    }];
}

- (void) getUserIdFromToken:(NSString *)token
executeWhenResponseIsSuccessful:(void (^)(NSString *))successCallBack
   executeWhenAnErrorOccurs:(void (^)(NSError *))errorCallBack;
{
    NSString *soapBody = [NSString stringWithFormat:
                @"<ns1:getUserId soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\n"
                "<token xsi:type=\"xsd:string\">%@</token>\n"
                "</ns1:getUserId>", token];
    
    VSSOAPRequest *request = [[VSSOAPRequest alloc] init];
    
    [request sendSOAPRequestToUrl:[self getWebServiceUrl:USERS_WS]
    soapRequestBody:soapBody
     
    executeWhenResponseIsSuccessful:^(DDXMLDocument *response) {
        NSString *userId = [[[response nodesForXPath:@"//return/text()" error:nil] lastObject] stringValue];
        
        if (userId != nil && [userId length] > 0) {
            successCallBack(userId);
        } else {
            errorCallBack(nil);
        }
    }
     
    executeWhenAnErrorOccurs:errorCallBack];
}

- (void)sendFaxWithToken:(NSString *)token
                 pdfPath:(NSString *)pdfPath
            senderNumber:(NSString *)senderNumber
                   notes:(NSString *)notes
        recipientNumbers:(NSArray *)recipientNumbers
                delegate:(id<VoiSmartWebServiceDelegate>)delegate
{
    NSString *requestUrl = [self getWebServiceUrl:@"/faxupload.php"];
    
    NSString *name = [NSString stringWithFormat:@"ipcomm_ios_%0.f",
                      ([[NSDate date] timeIntervalSince1970] * 100000.0)];
    
    NSData *config = [self generateFaxConfigurationFileWithUser:self.username
                                                   senderNumber:senderNumber
                                                     recipients:recipientNumbers
                                                          notes:notes];
    
    VSUploadRequest *request = [[VSUploadRequest alloc] initWithServerURL:requestUrl];
    
    [request addFileToUploadWithPath:pdfPath
                       parameterName:@"document"
                            fileName:[NSString stringWithFormat:@"%@.ps", name]
                      andContentType:@"application/pdf"];
    
    [request addFileToUploadWithData:config
                       parameterName:@"config"
                            fileName:[NSString stringWithFormat:@"%@.txt", name]
                      andContentType:@"application/text"];
    
    [request addParameterWithName:@"token" andValue:token];
    
    
    [[VSUploadService sharedInstance] startUploadRequest:request
    
    executeWhenResponseIsSuccessful:^(NSInteger responseCode, NSData *responseData) {
        if ([delegate respondsToSelector:@selector(faxSendingCompletedWithResponseCode:andMessage:)]) {
            NSNumber *code = [NSNumber numberWithLong:responseCode];
            NSString *message = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            [delegate faxSendingCompletedWithResponseCode:code andMessage:message ];
              
        } else {
            [self log:@"Delegate does not implement faxSendingCompletedWithResponseCode:andMessage:"];
        }
    }
     
    executeWhenAnErrorOccurs:^(NSError *error) {
        if ([delegate respondsToSelector:@selector(faxSendingError:)]) {
            VSWebServiceError *vsError = [[VSWebServiceError alloc] initWithErrorCode:VS_WS_CONNECTION_ERROR];
            [delegate faxSendingError:vsError];
                     
        } else {
            [self log:@"Delegate does not implement faxSendingError:"];
        }
    }];
}

- (NSData *)generateFaxConfigurationFileWithUser:(NSString *)user
                                    senderNumber:(NSString *)sender
                                      recipients:(NSArray *)recipients
                                           notes:(NSString *)notes
{
    NSString *builder;
    
    builder = [NSString stringWithFormat:@"mittente=%@;faxout=%@;destinatari=", user, sender];
    
    for (NSString *recipient in recipients) {
        builder = [builder stringByAppendingString:[NSString stringWithFormat:@"%@,", recipient]];
    }
    builder = [builder substringToIndex:[builder length] - 1];
    
    builder = [builder stringByAppendingString:[NSString stringWithFormat:@";prior=5;\nnote=\n%@;", notes]];
    
    return [builder dataUsingEncoding:NSUTF8StringEncoding];
}

- (void) makeCallWithToken:(NSString *)token
                  toNumber:(NSString *)numberToCall
        andConnectToNumber:(NSString *)numberToConnect
                  delegate:(id<VoiSmartWebServiceDelegate>)delegate
{
    if ([delegate respondsToSelector:@selector(makeCallResult:)]) {
        [delegate makeCallResult:NO];
    } else {
        [self log:@"Delegate does not implement makeCallResult:"];
    }
}

@end
