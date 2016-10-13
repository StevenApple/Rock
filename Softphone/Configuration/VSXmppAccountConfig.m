//
//  VSXmppAccountConfig.m
//  Softphone
//
//  Created by Alex on 23/10/13.
//  Copyright (c) 2013 VoiSmart. All rights reserved.
//

#import "VSXmppAccountConfig.h"
#define DEFAULT_XMPP_SERVER_PORT 5222

@interface VSXmppAccountConfig()

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *realm;
@property (nonatomic, assign) NSInteger availablePriority;
@property (nonatomic, assign) NSInteger chatPriority;
@property (nonatomic, assign) NSInteger awayPriority;
@property (nonatomic, assign) NSInteger extendedAwayPriority;
@property (nonatomic, assign) NSInteger doNotDisturbPriority;

@end

static NSString *const KEY_XMPP_ACCOUNT = @"xmppAccount";
static NSString *const KEY_XMPP_PASSWORD = @"xmppPassword";
static NSString *const KEY_XMPP_RESOURCE = @"xmppResource";
static NSString *const KEY_XMPP_PRESENCE = @"xmppPresence";
static NSString *const KEY_XMPP_STATUS_MESSAGE = @"xmppStatusMessage";
static NSString *const KEY_LOAD_AVATARS = @"loadAvatars";
static NSString *const KEY_XMPP_PRIORITY = @"xmppPriority";
static NSString *const KEY_XMPP_PRIORITY_BY_STATUS = @"xmppPriorityByStatus";
static NSString *const KEY_XMPP_PRIORITY_AVAILABLE = @"xmppPriorityAvailable";
static NSString *const KEY_XMPP_PRIORITY_CHAT = @"xmppPriorityChat";
static NSString *const KEY_XMPP_PRIORITY_AWAY = @"xmppPriorityAway";
static NSString *const KEY_XMPP_PRIORITY_EXTAWAY = @"xmppPriorityExtAway";
static NSString *const KEY_XMPP_PRIORITY_DND = @"xmppPriorityDoNotDisturb";
static NSString *const KEY_XMPP_SERVER = @"xmppServer";
static NSString *const KEY_XMPP_PORT = @"xmppPort";

static NSString *const VS_DEFAULT_XMPP_RESOURCE = @"VoiSmart IP Communicator iOS";

@implementation VSXmppAccountConfig

- (id)init
{
    self = [super init];
    
    if (self) {
        [self reload];
    }
    
    return self;
}

- (void) reload
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    self.account = [settings stringForKey:KEY_XMPP_ACCOUNT];
    self.password = [settings stringForKey:KEY_XMPP_PASSWORD];
    self.resourceName = [settings stringForKey:KEY_XMPP_RESOURCE];
    if (self.resourceName == nil)
        self.resourceName = VS_DEFAULT_XMPP_RESOURCE;

    self.onlineStatus = [settings integerForKey:KEY_XMPP_PRESENCE];
    self.statusMessage = [settings stringForKey:KEY_XMPP_STATUS_MESSAGE];

    self.loadAvatars = [settings boolForKey:KEY_LOAD_AVATARS];
    self.usePriorityByStatus = [settings boolForKey:KEY_XMPP_PRIORITY_BY_STATUS];
    self.priority = [settings integerForKey:KEY_XMPP_PRIORITY];
    self.availablePriority = [settings integerForKey:KEY_XMPP_PRIORITY_AVAILABLE];
    self.chatPriority = [settings integerForKey:KEY_XMPP_PRIORITY_CHAT];
    self.awayPriority = [settings integerForKey:KEY_XMPP_PRIORITY_AWAY];
    self.extendedAwayPriority = [settings integerForKey:KEY_XMPP_PRIORITY_EXTAWAY];
    self.doNotDisturbPriority = [settings integerForKey:KEY_XMPP_PRIORITY_DND];
    self.server = [settings stringForKey:KEY_XMPP_SERVER];
    self.port = [settings integerForKey:KEY_XMPP_PORT];
    if (self.port == 0) {
        self.port = DEFAULT_XMPP_SERVER_PORT;
    }
}

- (void) setUsernameAndRealmFromAccount
{
    if ([_account rangeOfString:@"@"].location != NSNotFound) {
        NSArray *temp = [_account componentsSeparatedByString:@"@"];
        self.username = temp[0];
        self.realm = temp[1];
    } else {
        self.username = nil;
        self.realm = nil;
    }
}

- (void) setAccount:(NSString *)account
{
    _account = account;
    [self setUsernameAndRealmFromAccount];
}

- (NSString *)username
{
    return _username;
}

- (NSString *)realm
{
    return _realm;
}

- (NSString *)resourceName
{
    if (_resourceName == nil || [_resourceName length] <= 0) {
        return VS_DEFAULT_XMPP_RESOURCE;
    }
    
    return _resourceName;
}

- (BOOL) isDefined
{
    return ([self fieldIsDefined:self.account]
            && [self fieldIsDefined:self.password]);
}

- (BOOL) fieldIsDefined:(NSString *)value
{
    return (value != nil && ![value isEqualToString:@""]);
}

- (void) setAvailablePriority:(NSInteger)availablePriority
{
    _availablePriority = availablePriority;
}

- (void) setChatPriority:(NSInteger)chatPriority
{
    _chatPriority = chatPriority;
}

- (void) setAwayPriority:(NSInteger)awayPriority
{
    _awayPriority = awayPriority;
}

- (void) setExtendedAwayPriority:(NSInteger)extendedAwayPriority
{
    _extendedAwayPriority = extendedAwayPriority;
}

- (void) setDoNotDisturbPriority:(NSInteger)doNotDisturbPriority
{
    _doNotDisturbPriority = doNotDisturbPriority;
}

- (NSInteger) getPriority
{
    NSInteger level;

    if (self.usePriorityByStatus) {
        level = [self getPriorityByStatus:self.onlineStatus];
    } else {
        level = self.priority;
    }
    
    return level;
}

- (NSInteger) getPriorityByStatus:(VSPresenceStatus)status
{
    NSInteger level;
    
    switch (status) {
        case AVAILABLE:
            level = self.availablePriority;
            break;
            
        case CHAT:
            level = self.chatPriority;
            break;
            
        case AWAY:
            level = self.awayPriority;
            break;
            
        case EXTENDED_AWAY:
            level = self.extendedAwayPriority;
            break;
            
        case DO_NOT_DISTURB:
            level = self.doNotDisturbPriority;
            break;
            
        case OFFLINE:
        default:
            level = 0;
            break;
    }
    
    return level;
}

- (BOOL) save
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:self.account forKey:KEY_XMPP_ACCOUNT];
    [settings setObject:self.password forKey:KEY_XMPP_PASSWORD];
    [settings setObject:self.resourceName forKey:KEY_XMPP_RESOURCE];
    [settings setInteger:self.onlineStatus forKey:KEY_XMPP_PRESENCE];
    [settings setObject:self.statusMessage forKey:KEY_XMPP_STATUS_MESSAGE];
    [settings setBool:self.loadAvatars forKey:KEY_LOAD_AVATARS];
    [settings setInteger:self.priority forKey:KEY_XMPP_PRIORITY];
    [settings setBool:self.usePriorityByStatus forKey:KEY_XMPP_PRIORITY_BY_STATUS];
    [settings setInteger:self.availablePriority forKey:KEY_XMPP_PRIORITY_AVAILABLE];
    [settings setInteger:self.chatPriority forKey:KEY_XMPP_PRIORITY_CHAT];
    [settings setInteger:self.awayPriority forKey:KEY_XMPP_PRIORITY_AWAY];
    [settings setInteger:self.extendedAwayPriority forKey:KEY_XMPP_PRIORITY_EXTAWAY];
    [settings setInteger:self.doNotDisturbPriority forKey:KEY_XMPP_PRIORITY_DND];
    [settings setObject:self.server forKey:KEY_XMPP_SERVER];
    [settings setInteger:self.port forKey:KEY_XMPP_PORT];
    
    return ([settings synchronize]);
}

- (BOOL) reset
{
    self.account = nil;
    self.password = nil;
    self.username = nil;
    self.realm = nil;
    self.resourceName = VS_DEFAULT_XMPP_RESOURCE;
    self.onlineStatus = AVAILABLE;
    self.statusMessage = nil;
    self.loadAvatars = YES;
    self.server = nil;
    self.port = DEFAULT_XMPP_SERVER_PORT;
    
    return ([self save]);
}

@end
