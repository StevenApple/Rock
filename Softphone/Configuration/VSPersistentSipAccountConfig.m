//
//  VSSipAccountConfig.m
//  Softphone
//
//  Created by Alex on 23/10/13.
//  Copyright (c) 2013 VoiSmart. All rights reserved.
//

#import "VSPersistentSipAccountConfig.h"
#define VS_DEFAULT_SIP_PORT 5060

static NSString *const KEY_PRIVATE_ID = @"sipPrivateId";
static NSString *const KEY_PASSWORD = @"sipPassword";
static NSString *const KEY_REALM = @"sipRealm";
static NSString *const KEY_HOST = @"sipHost";
static NSString *const KEY_PORT = @"sipPort";
static NSString *const KEY_DISPLAY_NAME = @"sipDisplayName";

@implementation VSPersistentSipAccountConfig

- (NSString *)privateId
{
    NSString *privateid = [_privateId stringByReplacingOccurrencesOfString:@"sip:" withString:@""];
    NSLog(@"GET privateId. Returning [%@]", privateid);
    return privateid;
}

- (NSString *)realm
{
    return [_realm stringByReplacingOccurrencesOfString:@"sip:" withString:@""];
}

- (id) init
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
    self.privateId = [[settings stringForKey:KEY_PRIVATE_ID] stringByReplacingOccurrencesOfString:@"sip:" withString:@""];
    self.password = [settings stringForKey:KEY_PASSWORD];
    self.realm = [[settings stringForKey:KEY_REALM] stringByReplacingOccurrencesOfString:@"sip:" withString:@""];
    self.host = [settings stringForKey:KEY_HOST];
    
    self.port = [settings integerForKey:KEY_PORT];
    if (self.port == 0)
        self.port = VS_DEFAULT_SIP_PORT;
    
    self.displayName = [settings stringForKey:KEY_DISPLAY_NAME];
}

- (BOOL) isDefined
{
    return ([self fieldIsDefined:self.privateId]
            && [self fieldIsDefined:self.password]
            && [self fieldIsDefined:self.host]);
}

- (BOOL) fieldIsDefined:(NSString *)value
{
    return (value != nil && ![value isEqualToString:@""]);
}

- (BOOL) reset
{
    self.privateId = nil;
    self.password = nil;
    self.realm = nil;
    self.host = nil;
    self.port = 0;
    self.displayName = nil;
    
    return ([self save]);
}

- (BOOL) save
{
    NSLog(@"\n\n\n\n\n\n\nSaving SIP settings\n\n\n\n\n\n\n");
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    [settings setObject:self.privateId forKey:KEY_PRIVATE_ID];
    [settings setObject:self.password forKey:KEY_PASSWORD];
    [settings setObject:self.realm forKey:KEY_REALM];
    [settings setObject:self.host forKey:KEY_HOST];
    [settings setInteger:self.port forKey:KEY_PORT];
    [settings setObject:self.displayName forKey:KEY_DISPLAY_NAME];
    
    BOOL retValue = [settings synchronize];
    
    return (retValue);
}

- (void) setFromSipAccountConfig:(VSSipAccountConfig *)config
{
    self.privateId = config.privateId;
    self.password = config.password;
    self.realm = config.realm;
    self.host = config.host;
    self.port = config.port;
    self.displayName = config.displayName;
}

@end
