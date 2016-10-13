//
//  PJSipNotifications.m
//  Softphone
//
//  Created by Alex Gotev on 02/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import "PJSipNotifications.h"

@implementation PJSipNotifications

//Pointer to the instance of this class.
//Needed to send messages from the C code
static PJSipNotifications *objClassPointer;

+(PJSipNotifications *)sharedInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        objClassPointer = [[PJSipNotifications alloc] init];
    });
    return objClassPointer;
}

-(void)onAccountRegistered:(int)accountId
{
    NSDictionary *userInfo = @{VS_PARAM_ACCOUNT_ID: [NSNumber numberWithInt:accountId]};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VS_NOTIFICATION_SIP_REGISTERED
                                                        object:objClassPointer
                                                      userInfo:userInfo];
}

-(void)onAccountUnregistered:(int)accountId
{
    NSDictionary *userInfo = @{VS_PARAM_ACCOUNT_ID: [NSNumber numberWithInt:accountId]};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VS_NOTIFICATION_SIP_UNREGISTERED
                                                        object:objClassPointer
                                                      userInfo:userInfo];
}

-(void)onIncomingCallWithId:(int)callId
                    account:(int)accountId
            fromDisplayName:(NSString *)displayName
                  andSipURI:(NSString *)sipURI
{
    NSDictionary *userInfo = @{VS_PARAM_CALL_ID: [NSNumber numberWithInt:callId],
                               VS_PARAM_ACCOUNT_ID: [NSNumber numberWithInt:accountId],
                               VS_PARAM_DISPLAY_NAME: displayName,
                               VS_PARAM_SIP_URI: sipURI};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VS_NOTIFICATION_INCOMING_CALL
                                                        object:objClassPointer
                                                      userInfo:userInfo];
}

-(void)onMissedIncomingCallFromDisplayName:(NSString *)displayName
                                 andSipURI:(NSString *)sipURI
{
    NSDictionary *userInfo = @{VS_PARAM_DISPLAY_NAME: displayName,
                               VS_PARAM_SIP_URI: sipURI};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VS_NOTIFICATION_MISSED_INCOMING_CALL
                                                        object:objClassPointer
                                                      userInfo:userInfo];
}

-(void)onIncomingDTMFdigit:(NSString *)dtmfDigit
            fromCallWithId:(int)callId
{
    if (dtmfDigit != nil) {
        NSDictionary *userInfo = @{VS_PARAM_CALL_ID: [NSNumber numberWithInt:callId],
                                   VS_PARAM_DTMF_DIGIT: dtmfDigit};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VS_NOTIFICATION_INCOMING_DTMF
                                                            object:objClassPointer
                                                          userInfo:userInfo];
    }
}

-(void)onCallTerminatedWithId:(int)callId
{
    NSDictionary *userInfo = @{VS_PARAM_CALL_ID: [NSNumber numberWithInt:callId]};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VS_NOTIFICATION_TERMINATED_CALL
                                                        object:objClassPointer
                                                      userInfo:userInfo];
}

- (void)onCallInProgressWithId:(int)callId
                   displayName:(NSString *)displayName
                     andSipURI:(NSString *)sipURI
{
    NSDictionary *userInfo = @{VS_PARAM_CALL_ID: [NSNumber numberWithInt:callId],
                               VS_PARAM_DISPLAY_NAME: displayName,
                               VS_PARAM_SIP_URI: sipURI};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VS_NOTIFICATION_IN_CALL
                                                        object:objClassPointer
                                                      userInfo:userInfo];
}

@end
