#import "VSChatNotifications.h"
#import "VSUtility.h"

static NSString *const KEY_MESSAGES_TO_READ_BY_USER = @"xmppMessagesToReadByUser";
static NSString *const KEY_TOTAL_MESSAGES_TO_READ = @"xmppTotalMessagesToRead";

static VSChatNotifications *_sharedInstance = nil;

@interface VSChatNotifications()

@property (nonatomic, strong) NSMutableDictionary *messagesToReadByUser;
@property (nonatomic, assign) NSInteger totalMessagesToRead;
@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation VSChatNotifications

+ (VSChatNotifications *)sharedInstance
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [[VSChatNotifications alloc] init];
        }
        
        return _sharedInstance;
    }
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
        _messagesToReadByUser = [[_userDefaults dictionaryForKey:KEY_MESSAGES_TO_READ_BY_USER] mutableCopy];
        if (_messagesToReadByUser == nil) {
            _messagesToReadByUser = [[NSMutableDictionary alloc] init];
        }
        _totalMessagesToRead = [_userDefaults integerForKey:KEY_TOTAL_MESSAGES_TO_READ];
    }
    
    return self;
}

- (BOOL)save
{
    [self.userDefaults setObject:self.messagesToReadByUser forKey:KEY_MESSAGES_TO_READ_BY_USER];
    [self.userDefaults setInteger:self.totalMessagesToRead forKey:KEY_TOTAL_MESSAGES_TO_READ];
    return [self.userDefaults synchronize];
}

- (NSInteger) getNumberOfUnreadMessagesFromUser:(NSString *)usernameJabberId
{
    NSNumber *numberOfNotifications = [self.messagesToReadByUser objectForKey:usernameJabberId];
    
    NSInteger totalNotificationForThisJabberId;
    if (numberOfNotifications) {
        totalNotificationForThisJabberId = [numberOfNotifications integerValue];
    } else {
        totalNotificationForThisJabberId = 0;
    }
    
    return totalNotificationForThisJabberId;
}

- (BOOL) addUnreadMessage:(NSString *)message
                 fromUser:(NSString *)usernameJabberId
                withAlias:(NSString *)alias
{
    NSInteger totalNotificationForThisJabberId = [self getNumberOfUnreadMessagesFromUser:usernameJabberId];
    
    totalNotificationForThisJabberId++;
    self.totalMessagesToRead++;
    
    [self.messagesToReadByUser setObject:[NSNumber numberWithInteger:totalNotificationForThisJabberId]
                                  forKey:usernameJabberId];
    
    if ([VSUtility applicationIsNotActive]) {
        [self sendLocalNotificationForMessage:message
                       sentByUserWithJabberId:usernameJabberId
                                     andAlias:alias];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_INCOMING_MESSAGE
                                                        object:usernameJabberId];
    
    return ([self save]);
}

- (BOOL) clearUnreadMessagesFromUser:(NSString *)usernameJabberId
{
    NSInteger totalNotificationsForUser = [self getNumberOfUnreadMessagesFromUser:usernameJabberId];
    [self.messagesToReadByUser removeObjectForKey:usernameJabberId];
    self.totalMessagesToRead -= totalNotificationsForUser;
    
    [self clearLocalNotificationsFromUser:usernameJabberId];
    
    return ([self save]);
}

- (NSInteger) getTotalUnreadMessages
{
    return self.totalMessagesToRead;
}

- (void) sendLocalNotificationForMessage:(NSString *)message
                  sentByUserWithJabberId:(NSString *)jabberId
                                andAlias:(NSString *)alias
{
    
    UILocalNotification *notif = [UILocalNotification chatNotificationForMessage:message
                                                                    fromJabberID:jabberId
                                                                       withAlias:alias
                                                          andTotalMessagesToRead:self.totalMessagesToRead];

    [[UIApplication sharedApplication] presentLocalNotificationNow:notif];
}

- (void) clearLocalNotificationsFromUser:(NSString *)jabberId
{
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for (UILocalNotification *notification in localNotifications) {
        if ([notification isChatNotification]) {
            NSString *notificationJabberId = [notification getChatNotificationJabberID];
            
            if ([notificationJabberId isEqualToString:jabberId]) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
            }
        }
    }
}

- (BOOL) clearAll
{
    [self.messagesToReadByUser removeAllObjects];
    self.totalMessagesToRead = 0;
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    return ([self save]);
}

@end
