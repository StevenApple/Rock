//
//  VSConnectionService.m
//  Softphone
//
//  Created by Alex on 15/11/13.
//  Copyright (c) 2013 VoiSmart. All rights reserved.
//

#import "VSConnectionService.h"
#import "VSXmppService.h"
#import "PJSipWrapper.h"
#import "VSUtility.h"
#import "AppDelegate.h"

static VSConnectionService *_sharedInstance = nil;

@interface VSConnectionService()

@property (nonatomic, assign) id<VoiSmartWebServices> webServices;
@property (nonatomic, strong) NSString *webServiceToken;
@property (nonatomic, strong) ReachabilityEventReceiver *reachabilityEvents;

@end

@implementation VSConnectionService

+ (VSConnectionService *)sharedInstance {
    
    @synchronized(self) {
        if (!_sharedInstance)
            _sharedInstance = [[VSConnectionService alloc] init];
    }
    
    return _sharedInstance;
}

- (ReachabilityEventReceiver *)reachabilityEvents
{
    if (_reachabilityEvents == nil) {
        _reachabilityEvents = [[ReachabilityEventReceiver alloc] initWithDelegate:self];
    }
    
    return _reachabilityEvents;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        [self.reachabilityEvents start];
    }
    
    return self;
}

- (void)dealloc
{
    [self.reachabilityEvents stop];
}

- (void)connectAllConfiguredServices
{
    VSAccountConfig *account = [VSConfiguration sharedInstance].accountConfig;
    
    if (![account isDefined]) {
        [VSUtility showMessageDialogWithLocalizedTitle:@"WARNING"
                                   andLocalizedMessage:@"NO_ACCOUNT"];
        return;
    }

    NSLog(@"Connection Service connectAllConfiguredServices with\n "
          "username: %@\n "
          "PBX url: %@\n "
          "PBX version: %@\n "
          "Register SIP\n  "
          "Via WiFi: %@\n  "
          "Via 3G: %@\n "
          "Register XMPP\n  "
          "Via WiFi: %@\n  "
          "Via 3G: %@",
          account.username, account.pbxAddress,
          (account.orchestraVersion == ORCHESTRA_5 ? @"ORCHESTRA_5" : @"ORCHESTRA_NG"),
          (account.registerSip ? @"YES" : @"NO"), (account.registerSipVia3G ? @"YES" : @"NO"),
          (account.registerXmpp ? @"YES" : @"NO"), (account.registerXmppVia3G ? @"YES" : @"NO"));
    
    self.webServices = [account getWebServicesInstance];
    
    [self.webServices getLicenseAndSendResponseToDelegate:self];
    //the response is async and gets sent to receivedLicenseIsValid:withWebServiceToken:error:
}

- (void)receivedLicenseIsValid:(BOOL)valid
           withWebServiceToken:(NSString *)webServiceToken
                         error:(NSError *)error
{
    if (error || webServiceToken == nil || [webServiceToken isEqualToString:@""]) {
        [self notifyStatus:VS_CONNECTION_SERVICE_LOGIN_ERROR];
        return;
    }
    self.webServiceToken = webServiceToken;

    if (valid && webServiceToken != nil && [webServiceToken length] > 0) {
        
        VSAccountConfig *account = [VSConfiguration sharedInstance].accountConfig;

        NSLog(@"%@ logged in on %@", account.username, account.pbxAddress);
        
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NetworkStatus status = [app currentNetworkStatus];
        
        if ((status == ReachableViaWiFi && account.registerSip)
            || (status == ReachableViaWWAN && account.registerSipVia3G)) {
            [self registerSipAccount:[VSConfiguration sharedInstance].sipConfig
                         forUsername:account.username];
        } else {
            NSLog(@"trying to un-register the SIP account");
            [[PJSipWrapper sharedInstance] shutdown];
        }
        
        if ((status == ReachableViaWiFi && account.registerXmpp)
            || (status == ReachableViaWWAN && account.registerXmppVia3G)) {
            BOOL success = [[VSXmppService sharedInstance]
                            registerXmppAccount:[VSConfiguration sharedInstance].xmppConfig
                                     forAccount:account];
            if (!success) [self notifyStatus:VS_CONNECTION_SERVICE_XMPP_LOGIN_ERROR];
            
        } else {
            NSLog(@"trying to un-register the XMPP account");
            [[VSXmppService sharedInstance] unregister];
        }

        [self notifyStatus:VS_CONNECTION_SERVICE_LOGIN_OK];
        
    } else {
        NSLog(@"Invalid license");
        [self stopAllServices];
        [self notifyStatus:VS_CONNECTION_SERVICE_NO_LICENSE];
    }
}

- (void) registerSipAccount:(VSPersistentSipAccountConfig *)sipAccount
                forUsername:(NSString *)username
{
    //if I don't have a SIP account saved, try to fetch it from the PBX
    if (![sipAccount isDefined]) {
        NSLog(@"No defined SIP account found. Requesting one from the web server");
        [self.webServices getSipAccountWithToken:self.webServiceToken
                                     forUsername:username
                                        delegate:self];
        //the response is async and gets sent to receivedSipAccounts:error:
    } else {
        [[PJSipWrapper sharedInstance] shutdown];
        [[PJSipWrapper sharedInstance] start];
        BOOL useTcpTransport = [VSConfiguration sharedInstance].accountConfig.orchestraVersion == ORCHESTRA_NG;
        [[PJSipWrapper sharedInstance] setSipUser:sipAccount.privateId
                                    withPassword:sipAccount.password
                                        andRealm:sipAccount.realm
                                          onHost:sipAccount.host
                                       andSipPort:(int)sipAccount.port
                                 withTCPTransport:useTcpTransport];
    }
}

- (void) receivedSipAccounts:(NSArray *)sipAccounts
                       error:(NSError *)error
{
    if (sipAccounts != nil && [sipAccounts count] > 0) {
        NSLog(@"Found accounts");
        VSSipAccountConfig *fetchedConfig = sipAccounts[0];
        
        NSLog(@"%@", fetchedConfig);
        
        VSPersistentSipAccountConfig *currentConfig = [VSConfiguration sharedInstance].sipConfig;
        [currentConfig setFromSipAccountConfig:fetchedConfig];
        [[VSConfiguration sharedInstance] updateAndSaveSipConfig:currentConfig];
        
        if ([currentConfig isDefined]) {
            [[PJSipWrapper sharedInstance] shutdown];
            [[PJSipWrapper sharedInstance] start];
            BOOL useTcpTransport = [VSConfiguration sharedInstance].accountConfig.orchestraVersion == ORCHESTRA_NG;
            [[PJSipWrapper sharedInstance] setSipUser:currentConfig.privateId
                                         withPassword:currentConfig.password
                                             andRealm:currentConfig.realm
                                               onHost:currentConfig.host
                                           andSipPort:(int)currentConfig.port
                                     withTCPTransport:useTcpTransport];
        } else {
            [self notifyStatus:VS_CONNECTION_SERVICE_NO_SIP_ACCOUNTS];
        }
    } else {
        NSLog(@"NO SIP ACCOUNTS!!");
    }
}

- (void)stopAllServices
{
    NSLog(@"Stopping all services...");
    
    [[PJSipWrapper sharedInstance] shutdown];
    [[VSXmppService sharedInstance] unregister];
}

- (void)shutdown
{
    NSLog(@"Shutdown requested");
    [self stopAllServices];
}

-(void)restartAllServices
{
    [self stopAllServices];
    [self connectAllConfiguredServices];
}

- (void)notifyStatus:(VSConnectionServiceStatus)status
{
    NSDictionary *userInfo = @{
        VS_CONNECTION_SERVICE_NOTIFICATION_STATUS: [NSNumber numberWithInt:status]
    };
    
    [[NSNotificationCenter defaultCenter]
        postNotificationName:VS_CONNECTION_SERVICE_NOTIFICATION
                      object:self
                    userInfo:userInfo];
}

#pragma mark - Reachability Event receiver delegate -

- (void)onInternetReachableViaWiFi
{
    NSLog(@"Internet is now reachable via WiFi. Re-connecting services.");
    [self connectAllConfiguredServices];
}

- (void)onInternetReachableVia3G
{
    NSLog(@"Internet is now reachable via 3G. Re-connecting services.");
    [self connectAllConfiguredServices];
}

- (void)onInternetUnreachable
{
    NSLog(@"Internet is not reachable, stopping services");
    [self stopAllServices];
}

@end
