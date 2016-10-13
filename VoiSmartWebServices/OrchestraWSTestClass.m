//
//  OrchestraNGTestClass.m
//  VoiSmart Web Services
//
//  Created by Alex on 09/10/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "OrchestraWSTestClass.h"

@interface OrchestraWSTestClass()

@property (nonatomic, strong) id<VoiSmartWebServices> services;

@end

static NSString *TEST_USERNAME;
static NSString *TEST_PASSWORD;
static NSString *TEST_HOST;

@implementation OrchestraWSTestClass

- (id) initWithWebServiceImplementation:(id<VoiSmartWebServices>)webServices
                               username:(NSString *)username
                               password:(NSString *)password
                                   host:(NSString *)host
{
    self = [super init];
        
    if (self) {
        self.services = webServices;
        TEST_USERNAME = username;
        TEST_PASSWORD = password;
        TEST_HOST = host;
        [self.services setUsername:TEST_USERNAME
                          password:TEST_PASSWORD
                            pbxUrl:TEST_HOST];
    }
    
    return self;
}

- (id)initWithOrchestra5
{
    return [self initWithWebServiceImplementation:[VoiSmartWebServicesFactory getVersion:ORCHESTRA_5]
                                         username:@"siptest760"
                                         password:@"siptest760"
                                             host:@"192.168.1.53"];
}

- (id)initWithOrchestraNG
{
    return [self initWithWebServiceImplementation:[VoiSmartWebServicesFactory getVersion:ORCHESTRA_NG]
                                         username:@"agotevtest@voismart.it"
                                         password:@"agotevtest"
                                             host:@"sip.voismart.net"];
}

- (void) startTest
{
    [self.services getLicenseAndSendResponseToDelegate:self];
}

- (void) logErrorIfItIsNotNil:(NSError *)error withPrefix:(NSString *)prefix
{
    if (error) NSLog(@"%@ ERROR %ld: %@", prefix, (long)error.code, error.localizedDescription);
}

- (void) loginResponseReceivedWithSuccess:(BOOL)success
                                    token:(NSString *)token
                        validityInSeconds:(long)validityInSeconds
                                    error:(NSError *)error
{
    NSLog(@"TEST LOGIN: Success: %d, token: %@, validity: %ld", success, token, validityInSeconds);
    
    if (success == YES) {
        [self testGetLicenseWithToken:token];
    } else {
        [self logErrorIfItIsNotNil:error withPrefix:@"LOGIN"];
    }
}


- (void) testGetLicenseWithToken:(NSString *)token
{
    [self.services getLicenseAndSendResponseToDelegate:self];
}

- (void) receivedLicenseIsValid:(BOOL)valid
            withWebServiceToken:(NSString *)webServiceToken
                          error:(NSError *)error
{
    NSLog(@"TEST LICENSE VALID: %d (1=YES, 0=NO)", valid);
    [self logErrorIfItIsNotNil:error withPrefix:@"LICENSE"];
    
    if (valid) {
        [self testGetSipAccountsWithToken:webServiceToken];
        [self testGetFirstPageOfCallsWithToken:webServiceToken];
        [self testGetContactsWithToken:webServiceToken];
        [self testGetUserExtensionsWithToken:webServiceToken];
        [self testGetFaxNumbersWithToken:webServiceToken];
    }
}


- (void) testGetSipAccountsWithToken:(NSString *)token
{
    [self.services getSipAccountWithToken:token forUsername:TEST_USERNAME delegate:self];
}

- (void)receivedSipAccounts:(NSArray *)sipAccounts
                      error:(NSError *)error
{
    [self logErrorIfItIsNotNil:error withPrefix:@"SIP ACCOUNTS"];
    
    if (sipAccounts == nil || [sipAccounts count] == 0) {
        NSLog(@"TEST SIP ACCOUNTS: no account found!");
    } else {
        for (VSSipAccountConfig *sipAccount in sipAccounts) {
            NSLog(@"TEST SIP ACCOUNTS: %@", sipAccount);
        }
    }
}


- (void) testGetFirstPageOfCallsWithToken:(NSString *)token
{
    [self.services getCallsWithToken:token
                            username:TEST_USERNAME
                                page:1
                      entriesPerPage:25
                            delegate:self];
}

- (void) receivedCalls:(NSArray *)calls
                 error:(NSError *)error
{
    [self logErrorIfItIsNotNil:error withPrefix:@"CALLS"];
    
    if (calls == nil || [calls count] == 0) {
        NSLog(@"TEST CALLS: empty list!");
    } else {
        for (VSCallRegistryItem *call in calls) {
            NSLog(@"TEST CALLS: %@", call);
        }
    }
}


- (void) testGetContactsWithToken:(NSString *)token
{
    [self.services getContactsWithToken:token searchFor:@"stefano" page:1 entriesPerPage:25 delegate:self];
}

- (void) receivedContacts:(NSArray *)contacts
                    error:(NSError *)error
{
    [self logErrorIfItIsNotNil:error withPrefix:@"CONTACTS"];
    
    if (contacts == nil || [contacts count] == 0) {
        NSLog(@"TEST CONTACTS: empty list!");
    } else {
        for (VSContact *contact in contacts) {
            NSLog(@"TEST CONTACTS: %@", contact);
        }
    }
}


- (void) testGetUserExtensionsWithToken:(NSString *)token
{
    [self.services getExtensionsByUserWithToken:token username:TEST_USERNAME delegate:self];
}

- (void) receivedUserExtensions:(NSArray *)extensions
                          error:(NSError *)error
{
    [self logErrorIfItIsNotNil:error withPrefix:@"EXTENSIONS"];
    
    if (extensions == nil || [extensions count] == 0) {
        NSLog(@"TEST EXTENSIONS: empty list!");
    } else {
        for (NSString *extension in extensions) {
            NSLog(@"TEST EXTENSIONS: %@", extension);
        }
    }
}

- (void) testGetFaxNumbersWithToken:(NSString *)token
{
    [self.services getFaxNumbersWithToken:token delegate:self];
}

- (void) receivedFaxNumbers:(NSArray *)faxNumbers
                      error:(NSError *)error
{
    [self logErrorIfItIsNotNil:error withPrefix:@"FAX NUMBERS"];
    
    if (faxNumbers == nil || [faxNumbers count] == 0) {
        NSLog(@"TEST FAX NUMBERS: empty list!");
    } else {
        for (NSString *faxNumber in faxNumbers) {
            NSLog(@"TEST FAX NUMBERS: %@", faxNumber);
        }
    }
}

@end
