//
//  VSChatNotifications.h
//  Softphone
//
//  Created by Alex on 25/11/13.
//  Copyright (c) 2013 VoiSmart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UILocalNotification+ChatNotification.h"
#define NOTIFICATION_NAME_INCOMING_MESSAGE @"VSChatNotificationsIncomingMessage"

@interface VSChatNotifications : NSObject

+ (VSChatNotifications *)sharedInstance;

- (NSInteger) getNumberOfUnreadMessagesFromUser:(NSString *)usernameJabberId;
- (BOOL) addUnreadMessage:(NSString *)message
                 fromUser:(NSString *)usernameJabberId
                withAlias:(NSString *)alias;
- (BOOL) clearUnreadMessagesFromUser:(NSString *)usernameJabberId;
- (NSInteger) getTotalUnreadMessages;
- (BOOL) clearAll;

@end
