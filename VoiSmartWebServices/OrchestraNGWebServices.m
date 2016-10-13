//
//  OrchestraNGWebServices.m
//  VoiSmart Web Services
//
//  Created by Alex on 08/10/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "OrchestraNGWebServices.h"
#import "VSUploadService.h"

# pragma mark - Private constants -

static NSString *const PBX_UNDEFINED = @"PBX Url not defined";

static NSString *const LOG_PREFIX = @"Orchestra NG WS";
static NSString *const PROTOCOL = @"https://";
static NSString *const LICENSE_WS = @"/jsondata/extjs/applicenseHandler/";
static NSString *const USER_WS = @"/jsondata/extjs/userHandler/";
static NSString *const EXT_WS = @"/jsondata/extjs/extensionHandler/";
static NSString *const PHONEBOOK_WS = @"/jsondata/extjs/authedPhonebookHandler/";
static NSString *const REGISTRY_WS = @"/jsondata/extjs/registryHandler/";
static NSString *const FAX_WS = @"/jsondata/extjs/faxnumberHandler/";
static NSString *const SEND_FAX = @"/jsondata/extjs/faxHandler/";
static NSString *const DIALER_HANDLER_WS = @"/jsondata/extjs/dialerHandler/";
static NSInteger const HTTP_OK = 200;
static NSTimeInterval const LICENSE_TOKEN_VALIDITY = 180; //expressed in seconds

#pragma mark - Private Interface -

@interface OrchestraNGWebServices()

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *pbxUrl;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) CachedStringWithFailureExpiration *loginToken;
@property (nonatomic, strong) CachedStringWithFailureExpiration *licenseToken;

- (void) log:(NSString *)message;

- (NSString *)getPbxUrl;

- (NSString *)getWebServiceUrl:(NSString *)webServiceRelativePath andMethod:(NSString *)webMethod;

@end

#pragma mark - Implementation -

@implementation OrchestraNGWebServices

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

- (NSDateFormatter *)dateFormatter {
    
    if (!_dateFormatter) {
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        [_dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
    }
    
    return _dateFormatter;
}

- (void) log:(NSString *)message
{
    NSLog(@"%@: %@", LOG_PREFIX, message);
}

- (NSString *)getWebServiceUrl:(NSString *)webServiceRelativePath andMethod:(NSString *)webMethod
{
    return [NSString stringWithFormat:@"%@%@%@%@", PROTOCOL, self.pbxUrl, webServiceRelativePath, webMethod];
}

- (NSDate *)dateFromUNIXtimestampStringInMilliseconds:(id)obj
{
    if (obj == nil) return [NSDate dateWithTimeIntervalSinceNow:0];

    NSString *str = [NSString stringWithFormat:@"%@", obj];
    return [NSDate dateWithTimeIntervalSince1970:(str.doubleValue / 1000)];
}

- (void)loginAndSendResponseToDelegate:(id<VoiSmartWebServiceDelegate>)delegate
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
    
    VSWebRequest *request = [[VSWebRequest alloc] init];
    
    [request addParameterWithName:@"username" andValue:self.username];
    [request addParameterWithName:@"password" andValue:self.password];
    [request addParameterWithName:@"request_date" andValue:[self.dateFormatter stringFromDate:[NSDate date]]];
    [request addParameterWithName:@"browser_tz" andValue:[[NSTimeZone systemTimeZone] name]];
    
    [request sendRequestToURL:[self getPbxUrl]
     
    executeWhenResponseIsSuccessful:^(NSInteger responseCode, NSData *responseData){
        BOOL success = NO;
        NSString *token = @"";
        long validity = 0;
        
        if (responseCode == HTTP_OK) {
            success = YES;
            
            for (NSHTTPCookie *cookie in
                 [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:[self getPbxUrl]]]) {
                
                if ([cookie.name isEqualToString:@"Ydin.user-ydin-auth"]) {
                    token = [[cookie.value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                             substringFromIndex:2];
                } else if ([cookie.name isEqualToString:@"Ydin.user-ydin-auth-sessionexpiry"]) {
                    validity = [[cookie.value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                substringFromIndex:2].intValue;
                }
            }
        }
    
        if (success == YES) {
            [self.loginToken setString:token andCacheFor:validity];
        } else {
            [self.loginToken reset];
        }
        
        callback(success, nil);
    }
     
    executeWhenAnErrorOccurs:^(NSError * error) {
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
    
    VSWebRequest *request = [[VSWebRequest alloc] init];
    
    [request addParameterWithName:@"token" andValue:[self.loginToken string]];
    [request addParameterWithName:@"data" andValue:@"[{\"application\":\"softphonev0\"}]"];
    
    [request sendRequestToURL:[self getWebServiceUrl:LICENSE_WS andMethod:@"create"]
     
    executeWhenResponseIsSuccessful:^(NSInteger responseCode, NSData *responseData){
        BOOL validLicense = NO;
        NSError *error = nil;
        
        id json = NULL_TO_NIL([NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error]);
        
        if (!error && responseCode == HTTP_OK) {
            NSString *token = (((NSArray *) NULL_TO_NIL(json[@"data"]))[0])[@"token"];
            
            if (token) {
                validLicense = YES;
                [self.licenseToken setString:token andCacheFor:LICENSE_TOKEN_VALIDITY];
            }
        }
        
        if (validLicense == NO) {
            [self.licenseToken registerFailure];
        }
        
        callback([self.licenseToken isNotNil], nil);
    }
     
    executeWhenAnErrorOccurs:^(NSError * error) {
        [self.licenseToken registerFailure];
        callback([self.licenseToken isNotNil], error);
    }];
}

- (void) getSipAccountWithToken:(NSString *)token
                    forUsername:(NSString *)username
                       delegate:(id<VoiSmartWebServiceDelegate>)delegate
{
    VSWebRequest *request = [[VSWebRequest alloc] init];
    
    [request addParameterWithName:@"token" andValue:token];
    [request addParameterWithName:@"limit" andValue:@"100"];
    [request addParameterWithName:@"start" andValue:@"0"];
    [request addParameterWithName:@"page"  andValue:@"1"];
    
    [request sendRequestToURL:[self getWebServiceUrl:USER_WS andMethod:@"read_myextensions"]
     
     executeWhenResponseIsSuccessful:^(NSInteger responseCode, NSData *responseData) {
         NSError *error = nil;
         NSArray *sipAccounts = nil;
         
         id json = NULL_TO_NIL([NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error]);
         
         if (!error && responseCode == HTTP_OK) {
             NSArray *extensions = NULL_TO_NIL(json[@"data"]);
             
             if (extensions && [extensions count] > 0) {
                 NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:[extensions count]];

                 for (NSDictionary *extension in extensions) {
                     VSSipAccountConfig *sipAccount = [[VSSipAccountConfig alloc] init];
                     
                     sipAccount.privateId = NULL_TO_NIL(extension[@"username"]);
                     sipAccount.displayName = NULL_TO_NIL(extension[@"number_alias"]);
                     sipAccount.password = NULL_TO_NIL(extension[@"password"]);
                     sipAccount.realm = [self getRealmFromUsername:username
                                                andIfIsNotFoundUse:self.pbxUrl];
                     sipAccount.host = self.pbxUrl;
                     
                     
                     [tempArray addObject:sipAccount];
                 }
                 
                 sipAccounts = [NSArray arrayWithArray:tempArray];
             }
         }
         
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

- (NSString *)getRealmFromUsername:(NSString *)username
                andIfIsNotFoundUse:(NSString *)fallback
{
    NSArray *array = [username componentsSeparatedByString:@"@"];
    
    NSString *output;
    
    if ([array count] != 2) {
        output = fallback;
    } else {
        output = array[1];
    }
    
    return output;
}

- (void) getCallsWithToken:(NSString *)token
                  username:(NSString *)username
                      page:(int)page
            entriesPerPage:(int)entriesPerPage
                  delegate:(id<VoiSmartWebServiceDelegate>)delegate
{
    VSWebRequest *request = [[VSWebRequest alloc] init];
    
    [request addParameterWithName:@"token"  andValue:token];
    [request addParameterWithName:@"sort"   andValue:@"start_time"];
    [request addParameterWithName:@"dir"    andValue:@"DESC"];
    [request addParameterWithName:@"page"   andValue:[NSString stringWithFormat:@"%d", page]];
    [request addParameterWithName:@"start"  andValue:[NSString stringWithFormat:@"%d", (page-1) * entriesPerPage]];
    [request addParameterWithName:@"limit"  andValue:[NSString stringWithFormat:@"%d", entriesPerPage]];
    
    [request sendRequestToURL:[self getWebServiceUrl:REGISTRY_WS andMethod:@"read_latest"]
     
     executeWhenResponseIsSuccessful:^(NSInteger responseCode, NSData *responseData) {
         NSError *error = nil;
         NSArray *calls = nil;
         
         id json = NULL_TO_NIL([NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error]);
         
         if (!error && responseCode == HTTP_OK) {
             NSArray *jsonCalls = NULL_TO_NIL(json[@"data"]);
             
             if (jsonCalls && [jsonCalls count] > 0) {
                 NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:[jsonCalls count]];
                 
                 for (NSDictionary *call in jsonCalls) {
                     
                     if ([@"call" isEqualToString:call[@"type"]]) {
                         VSCallRegistryItem *item = [[VSCallRegistryItem alloc] init];
                         
                         item.callType = [self getCallTypeFromString:NULL_TO_NIL(call[@"status"])];
                         item.startTime = [self dateFromUNIXtimestampStringInMilliseconds:NULL_TO_NIL(call[@"start_time"])];
                         item.endTime = [self dateFromUNIXtimestampStringInMilliseconds:NULL_TO_NIL(call[@"end_time"])];
                         item.number = NULL_TO_NIL(call[@"number"]);
                         
                         [tempArray addObject:item];
                     }
                 }
                 
                 calls = [NSArray arrayWithArray:tempArray];
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

- (VSCallType)getCallTypeFromString:(NSString *)string
{
    VSCallType callType;
    
    if ([string isEqualToString:@"in"]) {
        callType = INCOMING;
    } else if ([string isEqualToString:@"out"]) {
        callType = OUTGOING;
    } else {
        callType = MISSED;
    }
    
    return callType;
}

- (void) getContactsWithToken:(NSString *)token
                    searchFor:(NSString *)searchFor
                         page:(int)page
               entriesPerPage:(int)entriesPerPage
                     delegate:(id<VoiSmartWebServiceDelegate>)delegate
{
    VSWebRequest *request = [[VSWebRequest alloc] init];
    
    NSString *filter = [self getSearchFilterFromString:searchFor];
    
    [request addParameterWithName:@"filter"  andValue:filter];
    [request addParameterWithName:@"phonebooktype"  andValue:@"4"];
    [request addParameterWithName:@"token"  andValue:token];
    [request addParameterWithName:@"page"   andValue:[NSString stringWithFormat:@"%d", page]];
    [request addParameterWithName:@"start"  andValue:[NSString stringWithFormat:@"%d", (page-1) * entriesPerPage]];
    [request addParameterWithName:@"limit"  andValue:[NSString stringWithFormat:@"%d", entriesPerPage]];
    
    [request sendRequestToURL:[self getWebServiceUrl:PHONEBOOK_WS andMethod:@"get_contact"]

    executeWhenResponseIsSuccessful:^(NSInteger responseCode, NSData *responseData) {
        NSError *error = nil;
        NSArray *contacts = nil;
        
        id json = NULL_TO_NIL([NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error]);
        
        if (!error && responseCode == HTTP_OK) {
            NSArray *jsonContacts = NULL_TO_NIL(json[@"data"]);
            
            if (jsonContacts && [jsonContacts count] > 0) {
                NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:[jsonContacts count]];
                
                for (NSDictionary *contact in jsonContacts) {
                    [tempArray addObject:[self getContactFromJSONobject:contact]];
                }
                
                contacts = tempArray;
            }
        }
        
        if ([delegate respondsToSelector:@selector(receivedContacts:error:)]) {
            [delegate receivedContacts:contacts error:nil];
        } else {
            [self log:@"Delegate does not implement receivedContacts:error:"];
        }
    }

    executeWhenAnErrorOccurs:^(NSError *error) {
        if ([delegate respondsToSelector:@selector(receivedContacts:error:)]) {
            VSWebServiceError *vsError = [[VSWebServiceError alloc] initWithErrorCode:VS_WS_CONNECTION_ERROR];
            [delegate receivedContacts:nil error:vsError];
        } else {
            [self log:@"Delegate does not implement receivedContacts:error"];
        }
    }];
}

- (NSString *)getSearchFilterFromString:(NSString *)string
{
    NSMutableString *filter = [[NSMutableString alloc] init];
    
    NSString *pattern = @"(sn=*[SRC]* or givenName=*[SRC]* or o=*[SRC]* or mobile=*[SRC]* or facsimileTelephoneNumber=*[SRC]* or telephoneNumber=*[SRC]*) and ";
    
    if (string == nil || [string isEqualToString:@""] || [string isEqualToString:@"*"]) {
        [filter appendString:@"sn=*"];
    
    } else {
        NSString *trimmed = [string stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray *terms = [trimmed componentsSeparatedByString:@" "];
        
        [filter appendString:@"("];
        
        for (NSString *term in terms) {
            if (term && ![term isEqualToString:@""])
                [filter appendString:[pattern stringByReplacingOccurrencesOfString:@"[SRC]" withString:term]];
        }
        
        //Delete the last: " and "
        [filter deleteCharactersInRange:NSMakeRange([filter length] - 5, 5)];
        
        [filter appendString:@")"];
    }
    
    return [NSString stringWithString:filter];
}

- (VSContact *)getContactFromJSONobject:(NSDictionary *)json
{
    VSContact *contact = [[VSContact alloc] init];
    
    contact.address = NULL_TO_NIL(json[@"street"]);
    contact.city = NULL_TO_NIL(json[@"l"]);
    contact.company = NULL_TO_NIL(json[@"o"]);
    contact.country = NULL_TO_NIL(json[@"co"]);
    contact.email = NULL_TO_NIL(json[@"mail"])[0]; //Now it's a list, so get the first one as fallback
    contact.homePageUrl = NULL_TO_NIL(json[@"labeledURI"]);
    contact.name = NULL_TO_NIL(json[@"givenName"]);
    contact.notes = NULL_TO_NIL(json[@"description"]);
    contact.state = NULL_TO_NIL(json[@"st"]);
    contact.surname = NULL_TO_NIL(json[@"sn"]);
    contact.title = NULL_TO_NIL(json[@"title"]);
    contact.postalCode = NULL_TO_NIL(json[@"postalCode"]);
    
    NSArray *faxes = NULL_TO_NIL(json[@"facsimileTelephoneNumber"]);
    if (faxes && [faxes count] > 0) {
        for (NSString *faxNumber in faxes) {
            [contact.faxes addObject:faxNumber];
        }
    }
    
    NSArray *office = NULL_TO_NIL(json[@"telephoneNumber"]);
    if (office && [office count] > 0) {
        for (NSString *officeNumber in office) {
            [contact.officePhones addObject:officeNumber];
        }
    }
    
    NSArray *mobile = NULL_TO_NIL(json[@"mobile"]);
    if (mobile && [mobile count] > 0) {
        for (NSString *mobilePhone in mobile) {
            [contact.mobilePhones addObject:mobilePhone];
        }
    }
    
    NSArray *home = NULL_TO_NIL(json[@"homePhone"]);
    if (home && [home count] > 0) {
        for (NSString *homePhone in home) {
            [contact.homePhones addObject:homePhone];
        }
    }
    
    [contact setImageFromBase64StringData:NULL_TO_NIL(json[@"jpegPhoto"])];
    
    return contact;
}

- (void) getExtensionsByUserWithToken:(NSString *)token
                             username:(NSString *)username
                             delegate:(id<VoiSmartWebServiceDelegate>)delegate
{
    [self getUsernameIdWithToken:token forUsername:username
    
    receivedUsernameId:^(NSInteger usernameId) {
        VSWebRequest *request = [[VSWebRequest alloc] init];
        
        [request addParameterWithName:@"token"  andValue:token];
        [request addParameterWithName:@"page"   andValue:@"1"];
        [request addParameterWithName:@"start"  andValue:@"0"];
        [request addParameterWithName:@"limit"  andValue:@"2000"];
        [request addParameterWithName:@"association"
                             andValue:[NSString stringWithFormat:@"[{\"property\":\"user_id\",\"value\":%ld}]", (long)usernameId]];
        
        [request sendRequestToURL:[self getWebServiceUrl:EXT_WS andMethod:@"unprivileged_read"]
  
        executeWhenResponseIsSuccessful:^(NSInteger responseCode, NSData *responseData) {
            NSError *error = nil;
            NSMutableArray *userExtensions = nil;
            
            id json = NULL_TO_NIL([NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error]);
            
            if (!error && responseCode == HTTP_OK) {
                NSArray *jsonExtensions = NULL_TO_NIL(json[@"data"]);
                
                if (jsonExtensions && [jsonExtensions count] > 0) {
                    userExtensions = [NSMutableArray arrayWithCapacity:[jsonExtensions count]];
                    
                    for (NSDictionary *extension in jsonExtensions) {
                        NSString *numberAlias = NULL_TO_NIL(extension[@"number_alias"]);
                        if (numberAlias != nil) {
                            [userExtensions addObject:numberAlias];
                        }
                    }
                }
            }
            
            if ([delegate respondsToSelector:@selector(receivedUserExtensions:error:)]) {
                [delegate receivedUserExtensions:userExtensions error:nil];
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
    
    executeWhenAnErrorOccurs:^(NSError *error) {
        if ([delegate respondsToSelector:@selector(receivedUserExtensions:error:)]) {
            VSWebServiceError *vsError = [[VSWebServiceError alloc] initWithErrorCode:VS_WS_CONNECTION_ERROR];
            [delegate receivedUserExtensions:nil error:vsError];
        } else {
            [self log:@"Delegate does not implement receivedUserExtensions:error:"];
        }
    }];
}

- (void) getUsernameIdWithToken:(NSString *)token
                    forUsername:(NSString *)username
             receivedUsernameId:(void (^)(NSInteger))receivedUsernameId
       executeWhenAnErrorOccurs:(void (^)(NSError *))errorCallBack;
{
    VSWebRequest *request = [[VSWebRequest alloc] init];

    [request addParameterWithName:@"query"  andValue:[VoiSmartWebServicesFactory getUsernameFromJabberIDstring:username]];
    [request addParameterWithName:@"token"  andValue:token];
    [request addParameterWithName:@"page"   andValue:@"1"];
    [request addParameterWithName:@"start"  andValue:@"0"];
    [request addParameterWithName:@"limit"  andValue:@"1"];
    
    [request sendRequestToURL:[self getWebServiceUrl:USER_WS andMethod:@"unprivileged_read"]
    
    executeWhenResponseIsSuccessful:^(NSInteger responseCode, NSData *responseData) {
        NSError *error = nil;
        
        id json = NULL_TO_NIL([NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error]);
        
        if (!error && responseCode == HTTP_OK) {
            NSArray *jsonIds = NULL_TO_NIL(json[@"data"]);
            
            if (jsonIds && [jsonIds count] > 0) {
                NSInteger value = [NSString stringWithFormat:@"%@", [jsonIds objectAtIndex:0][@"id"]].integerValue;
                receivedUsernameId(value);
            
            } else {
                errorCallBack(error);
            }
        
        } else {
            errorCallBack(error);
        }
    }
     
    executeWhenAnErrorOccurs:^(NSError *error) {
        errorCallBack(error);
    }];
}

- (void) getFaxNumbersWithToken:(NSString *)token
                       delegate:(id<VoiSmartWebServiceDelegate>)delegate
{
    VSWebRequest *request = [[VSWebRequest alloc] init];
    
    [request addParameterWithName:@"token"  andValue:token];
    [request addParameterWithName:@"page"   andValue:@"1"];
    [request addParameterWithName:@"start"  andValue:@"0"];
    [request addParameterWithName:@"limit"  andValue:@"2000"];
    
    [request sendRequestToURL:[self getWebServiceUrl:FAX_WS andMethod:@"get_numbers_for_user"]

    executeWhenResponseIsSuccessful:^(NSInteger responseCode, NSData *responseData) {
        NSError *error = nil;
        NSMutableArray *faxNumbers = nil;
        
        id json = NULL_TO_NIL([NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error]);
        
        if (!error && responseCode == HTTP_OK) {
            NSArray *jsonFaxes = NULL_TO_NIL(json[@"data"]);
            
            if (jsonFaxes && [jsonFaxes count] > 0) {
                faxNumbers = [NSMutableArray arrayWithCapacity:[jsonFaxes count]];
                
                for (NSDictionary *faxNumber in jsonFaxes) {
                    NSString *number = NULL_TO_NIL(faxNumber[@"number"]);
                    if (number != nil) {
                        [faxNumbers addObject:number];
                    }
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

- (void)sendFaxWithToken:(NSString *)token
                 pdfPath:(NSString *)pdfPath
            senderNumber:(NSString *)senderNumber
                   notes:(NSString *)notes
        recipientNumbers:(NSArray *)recipientNumbers
                delegate:(id<VoiSmartWebServiceDelegate>)delegate
{
    NSString *requestUrl = [self getWebServiceUrl:SEND_FAX andMethod:@"send_fax"];

    VSUploadRequest *request = [[VSUploadRequest alloc] initWithServerURL:requestUrl];
    
    [request addFileToUploadWithPath:pdfPath
                       parameterName:@"document"
                            fileName:@"fax.pdf"
                      andContentType:@"application/pdf"];
    
    [request addParameterWithName:@"token" andValue:token];
    [request addParameterWithName:@"sender" andValue:senderNumber];
    [request addParameterWithName:@"note" andValue:notes];
    [request addParameterWithName:@"sendTo" andValue:@"singleNumbers"];
    [request addParameterWithName:@"priority" andValue:@"1"];
    
    for (NSString *number in recipientNumbers) {
        [request addParameterWithName:@"recipients" andValue:number];
    }
    
    VSUploadService *uploadService = [VSUploadService sharedInstance];
    
    [uploadService startUploadRequest:request
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

- (void)makeCallWithToken:(NSString *)token
                 toNumber:(NSString *)numberToCall
       andConnectToNumber:(NSString *)numberToConnect
                 delegate:(id<VoiSmartWebServiceDelegate>)delegate
{
    VSWebRequest *request = [[VSWebRequest alloc] init];
    
    [request addParameterWithName:@"token"  andValue:token];
    
    NSString *data;
    if (numberToConnect != nil && ![numberToConnect isEqualToString:@""]) {
        data = [NSString stringWithFormat:@"[{\"number_to_call\":\"%@\",\"number_to_connect\":\"%@\"}]", numberToCall, numberToConnect];
    } else {
        data = [NSString stringWithFormat:@"[{\"number_to_call\":\"%@\"}]", numberToCall];
    }
    
    [request addParameterWithName:@"data" andValue:data];
    
    [request sendRequestToURL:[self getWebServiceUrl:DIALER_HANDLER_WS andMethod:@"click_and_dial"]
     
    executeWhenResponseIsSuccessful:^(NSInteger responseCode, NSData *responseData) {
        NSError *error = nil;
    
        id json = NULL_TO_NIL([NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error]);

        BOOL result;
        if (!error && responseCode == HTTP_OK) {
            NSNumber *number = NULL_TO_NIL(json[@"result"]);
            if (number == nil) result = NO;
            else result = ([number intValue] == 1);
        } else {
            result = NO;
        }
    
        if ([delegate respondsToSelector:@selector(makeCallResult:)]) {
            [delegate makeCallResult:result];
        } else {
            [self log:@"Delegate does not implement makeCallResult:"];
        }
    }
     
    executeWhenAnErrorOccurs:^(NSError *error) {
        if ([delegate respondsToSelector:@selector(makeCallResult:)]) {
            [delegate makeCallResult:NO];
        } else {
            [self log:@"Delegate does not implement makeCallResult:"];
        }
    }];
}

@end
