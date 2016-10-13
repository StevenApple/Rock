//
//  VSLocalNotifications.h
//  Softphone
//
//  Created by Alex Gotev on 10/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PJSipNotifications.h"

@interface VSLocalNotifications : NSObject

+(UILocalNotification *)missedIncomingCallNotificationWithDisplayName:(NSString *)displayName
                                                            andSipURI:(NSString *)sipURI;

+(UILocalNotification *)incomingCallNotificationWithID:(int)callId
                                             accountId:(int)accountId
                                           displayName:(NSString *)displayName
                                             andSipURI:(NSString *)sipURI;

@end
