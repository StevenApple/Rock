//
//  VSAccountConfig.m
//  Softphone
//
//  Created by Alex on 23/10/13.
//  Copyright (c) 2013 VoiSmart. All rights reserved.
//

#import "VSAccountConfig.h"

static NSString *const KEY_USERNAME = @"username";
static NSString *const KEY_PASSWORD = @"password";
static NSString *const KEY_PBXURL = @"pbxUrl";
static NSString *const KEY_REGISTER_SIP = @"registerSip";
static NSString *const KEY_REGISTER_XMPP = @"registerXmpp";
static NSString *const KEY_REGISTER_SIP_VIA_3G = @"registerSipVia3G";
static NSString *const KEY_REGISTER_XMPP_VIA_3G = @"registerXmppVia3G";
static NSString *const KEY_ORCHESTRA_VERSION = @"orchestraVersion";
static NSString *const KEY_MY_PHONE_NUMBER = @"myPhoneNumber";
static NSString *const KEY_DEFAULT_CALL_TYPE = @"defaultCallType";

@implementation VSAccountConfig

- (id)init
{
    self = [super init];
    
    if (self){
        [self reload];
    }
    
    return self;
}

- (void) reload
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    self.username = [settings stringForKey:KEY_USERNAME];
    self.password = [settings stringForKey:KEY_PASSWORD];
    self.pbxAddress = [settings stringForKey:KEY_PBXURL];
    self.registerSip = [settings boolForKey:KEY_REGISTER_SIP];
    self.registerXmpp = [settings boolForKey:KEY_REGISTER_XMPP];
    self.registerSipVia3G = [settings boolForKey:KEY_REGISTER_SIP_VIA_3G];
    self.registerXmppVia3G = [settings boolForKey:KEY_REGISTER_XMPP_VIA_3G];
    self.orchestraVersion = [settings integerForKey:KEY_ORCHESTRA_VERSION];
    self.myPhoneNumber = [settings stringForKey:KEY_MY_PHONE_NUMBER];
    self.defaultCallType = [settings integerForKey:KEY_DEFAULT_CALL_TYPE];
}

- (BOOL) isDefined
{
    return ([self fieldIsDefined:self.username]
            && [self fieldIsDefined:self.password]
            && [self fieldIsDefined:self.pbxAddress]);
}

- (BOOL) fieldIsDefined:(NSString *)value
{
    return (value != nil && ![value isEqualToString:@""]);
}

- (BOOL) reset
{
    self.username = nil;
    self.password = nil;
    self.pbxAddress = nil;
    self.registerSip = NO;
    self.registerXmpp = NO;
    self.registerSipVia3G = NO;
    self.registerXmppVia3G = NO;
    self.orchestraVersion = ORCHESTRA_5;
    self.myPhoneNumber = nil;
    self.defaultCallType = CALL_TYPE_VOIP;

    return ([self save]);
}

- (BOOL) save
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    [settings setObject:self.username forKey:KEY_USERNAME];
    [settings setObject:self.password forKey:KEY_PASSWORD];
    [settings setObject:self.pbxAddress forKey:KEY_PBXURL];
    [settings setBool:self.registerSip forKey:KEY_REGISTER_SIP];
    [settings setBool:self.registerXmpp forKey:KEY_REGISTER_XMPP];
    [settings setBool:self.registerSipVia3G forKey:KEY_REGISTER_SIP_VIA_3G];
    [settings setBool:self.registerXmppVia3G forKey:KEY_REGISTER_XMPP_VIA_3G];
    [settings setInteger:self.orchestraVersion forKey:KEY_ORCHESTRA_VERSION];
    [settings setObject:self.myPhoneNumber forKey:KEY_MY_PHONE_NUMBER];
    [settings setInteger:self.defaultCallType forKey:KEY_DEFAULT_CALL_TYPE];
    
    return ([settings synchronize]);
}

- (BOOL)isCallbackCallType
{
    return self.defaultCallType == CALL_TYPE_CALLBACK;
}

- (BOOL)isVoIPCallType
{
    return self.defaultCallType == CALL_TYPE_VOIP;
}

- (id<VoiSmartWebServices>)getWebServicesInstance
{
    id<VoiSmartWebServices> webServices = [VoiSmartWebServicesFactory getVersion:self.orchestraVersion];
    [webServices setUsername:self.username
                    password:self.password
                      pbxUrl:self.pbxAddress];
    
    return webServices;
}

@end
