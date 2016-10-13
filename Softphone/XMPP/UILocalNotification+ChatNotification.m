//
//  UILocalNotification+ChatNotification.m
//  Softphone
//
//  Created by Alex on 25/11/13.
//  Copyright (c) 2013 VoiSmart. All rights reserved.
//

#import "UILocalNotification+ChatNotification.h"

static NSString *const VS_CHAT_NOTIFICATION_JABBER_ID_KEY = @"JabberID";

@implementation UILocalNotification (ChatNotification)

+ (UILocalNotification *)chatNotificationForMessage:(NSString *)message
                                       fromJabberID:(NSString *)jabberId
                                          withAlias:(NSString *)alias
                             andTotalMessagesToRead:(NSInteger)totalMessagesToRead
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.applicationIconBadgeNumber = totalMessagesToRead;
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.alertBody = [NSString stringWithFormat:@"%@: %@", alias, message];
    notification.userInfo = [NSDictionary dictionaryWithObject:jabberId
                                                        forKey:VS_CHAT_NOTIFICATION_JABBER_ID_KEY];
    
    return notification;
}

- (BOOL) isChatNotification
{
    return ([self userInfo] != nil
            && [[self userInfo] objectForKey:VS_CHAT_NOTIFICATION_JABBER_ID_KEY] != nil);
}

- (NSString *)getChatNotificationJabberID
{
    return [[self userInfo] objectForKey:VS_CHAT_NOTIFICATION_JABBER_ID_KEY];
}

@end
