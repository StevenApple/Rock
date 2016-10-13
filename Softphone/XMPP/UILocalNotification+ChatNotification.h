//
//  UILocalNotification+ChatNotification.h
//  Softphone
//
//  Created by Alex on 25/11/13.
//  Copyright (c) 2013 VoiSmart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILocalNotification (ChatNotification)
+ (UILocalNotification *)chatNotificationForMessage:(NSString *)message
                                       fromJabberID:(NSString *)jabberId
                                          withAlias:(NSString *)alias
                             andTotalMessagesToRead:(NSInteger)totalMessagesToRead;

- (BOOL) isChatNotification;
- (NSString *)getChatNotificationJabberID;

@end
