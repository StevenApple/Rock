//
//  PJSipNotificationsReceiver.m
//  Softphone
//
//  Created by Alex Gotev on 04/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import "PJSipNotificationsReceiver.h"

@implementation PJSipNotificationsReceiver

-(void)registerObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onIncomingNotification:)
                                                 name:nil
                                               object:[PJSipNotifications sharedInstance]];
}

-(void)unregisterObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)onIncomingNotification:(NSNotification *)notification
{
    if (self.delegate == nil) return;

    if ([notification.name isEqualToString:VS_NOTIFICATION_INCOMING_CALL]) {
        NSNumber *callId = [notification.userInfo objectForKey:VS_PARAM_CALL_ID];
        NSNumber *accountId = [notification.userInfo objectForKey:VS_PARAM_ACCOUNT_ID];
        NSString *displayName = [notification.userInfo objectForKey:VS_PARAM_DISPLAY_NAME];
        NSString *sipURI = [notification.userInfo objectForKey:VS_PARAM_SIP_URI];
            
        [self.delegate onIncomingCallWithId:[callId intValue]
                                    account:[accountId intValue]
                            fromDisplayName:displayName
                                  andSipURI:sipURI];
    
    
    } else if ([notification.name isEqualToString:VS_NOTIFICATION_INCOMING_DTMF]) {
        NSNumber *callId = [notification.userInfo objectForKey:VS_PARAM_CALL_ID];
        NSString *dtmf = [notification.userInfo objectForKey:VS_PARAM_DTMF_DIGIT];
            
        [self.delegate onIncomingDTMFdigit:dtmf
                            fromCallWithId:[callId intValue]];
    
    } else if ([notification.name isEqualToString:VS_NOTIFICATION_MISSED_INCOMING_CALL]) {
        NSString *displayName = [notification.userInfo objectForKey:VS_PARAM_DISPLAY_NAME];
        NSString *sipURI = [notification.userInfo objectForKey:VS_PARAM_SIP_URI];
            
        [self.delegate onMissedIncomingCallFromDisplayName:displayName
                                                 andSipURI:sipURI];
    
    } else if ([notification.name isEqualToString:VS_NOTIFICATION_TERMINATED_CALL]) {
        NSNumber *callId = [notification.userInfo objectForKey:VS_PARAM_CALL_ID];
        
        [self.delegate onCallTerminatedWithId:[callId intValue]];
    
    } else if ([notification.name isEqualToString:VS_NOTIFICATION_IN_CALL]) {
        NSNumber *callId = [notification.userInfo objectForKey:VS_PARAM_CALL_ID];
        NSString *displayName = [notification.userInfo objectForKey:VS_PARAM_DISPLAY_NAME];
        NSString *sipURI = [notification.userInfo objectForKey:VS_PARAM_SIP_URI];

        [self.delegate onCallInProgressWithId:[callId intValue]
                                  displayName:displayName
                                    andSipURI:sipURI];
    
    } else if ([notification.name isEqualToString:VS_NOTIFICATION_SIP_REGISTERED]) {
        NSNumber *accountId = [notification.userInfo objectForKey:VS_PARAM_ACCOUNT_ID];
        
        [self.delegate onAccountRegistered:[accountId intValue]];
    
    } else if ([notification.name isEqualToString:VS_NOTIFICATION_SIP_UNREGISTERED]) {
        NSNumber *accountId = [notification.userInfo objectForKey:VS_PARAM_ACCOUNT_ID];
        
        [self.delegate onAccountUnregistered:[accountId intValue]];
    }
}

-(void)dealloc
{
    [self unregisterObserver];
}

@end
