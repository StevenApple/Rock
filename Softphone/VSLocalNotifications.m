//
//  VSLocalNotifications.m
//  Softphone
//
//  Created by Alex Gotev on 10/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import "VSLocalNotifications.h"

@implementation VSLocalNotifications

+(UILocalNotification *)missedIncomingCallNotificationWithDisplayName:(NSString *)displayName
                                                            andSipURI:(NSString *)sipURI
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"MISSED_CALL", nil), displayName];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.userInfo = @{VS_NOTIFICATION_NAME: VS_NOTIFICATION_MISSED_INCOMING_CALL,
                              VS_PARAM_DISPLAY_NAME: displayName,
                              VS_PARAM_SIP_URI: sipURI};

    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
    return notification;
}

+(UILocalNotification *)incomingCallNotificationWithID:(int)callId
                                             accountId:(int)accountId
                                           displayName:(NSString *)displayName
                                             andSipURI:(NSString *)sipURI
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"INCOMING_CALL", nil), displayName];
    notification.userInfo = @{VS_NOTIFICATION_NAME: VS_NOTIFICATION_INCOMING_CALL,
                              VS_PARAM_CALL_ID: [NSNumber numberWithInt:callId],
                              VS_PARAM_ACCOUNT_ID: [NSNumber numberWithInt:accountId],
                              VS_PARAM_DISPLAY_NAME: displayName,
                              VS_PARAM_SIP_URI: sipURI};

    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
    return notification;
}

@end
