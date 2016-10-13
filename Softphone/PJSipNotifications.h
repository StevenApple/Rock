//
//  PJSipNotifications.h
//  Softphone
//
//  Created by Alex Gotev on 02/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import <Foundation/Foundation.h>

#define VS_NOTIFICATION_NAME @"VSNotificationName"

#define VS_NOTIFICATION_INCOMING_CALL @"VSNotificationIncomingCall"
#define VS_PARAM_CALL_ID @"VSParamCallID"
#define VS_PARAM_ACCOUNT_ID @"VSParamAccountID"
#define VS_PARAM_DISPLAY_NAME @"VSParamDisplayName"
#define VS_PARAM_SIP_URI @"VSParamSipURI"

#define VS_NOTIFICATION_INCOMING_DTMF @"VSNotificationIncomingDTMF"
#define VS_PARAM_DTMF_DIGIT @"VSParamDTMFDigit"
//uses also #define VS_PARAM_CALL_ID @"VSParamCallID"

#define VS_NOTIFICATION_MISSED_INCOMING_CALL @"VSNotificationMissedIncomingCall"
/*uses
 #define VS_PARAM_DISPLAY_NAME @"VSParamDisplayName"
 #define VS_PARAM_SIP_URI @"VSParamSipURI"
 */

#define VS_NOTIFICATION_TERMINATED_CALL @"VSNotificationTerminatedCall"
//uses also #define VS_PARAM_CALL_ID @"VSParamCallID"

#define VS_NOTIFICATION_IN_CALL @"VSNotificationInCall"
/*uses
 #define VS_PARAM_CALL_ID @"VSParamCallID"
 #define VS_PARAM_DISPLAY_NAME @"VSParamDisplayName"
 #define VS_PARAM_SIP_URI @"VSParamSipURI"
 */

#define VS_NOTIFICATION_SIP_REGISTERED @"VSNotificationSipRegistered"
//uses also #define VS_PARAM_ACCOUNT_ID @"VSParamAccountID"

#define VS_NOTIFICATION_SIP_UNREGISTERED @"VSNotificationSipUnregistered"
//uses also #define VS_PARAM_ACCOUNT_ID @"VSParamAccountID"

@protocol PJSipNotificationsDelegate <NSObject>

-(void)onAccountRegistered:(int)accountId;

-(void)onAccountUnregistered:(int)accountId;

-(void)onIncomingCallWithId:(int)callId
                    account:(int)accountId
            fromDisplayName:(NSString *)displayName
                  andSipURI:(NSString *)sipURI;

-(void)onMissedIncomingCallFromDisplayName:(NSString *)displayName
                                 andSipURI:(NSString *)sipURI;

-(void)onIncomingDTMFdigit:(NSString *)dtmfDigit
            fromCallWithId:(int)callId;

-(void)onCallTerminatedWithId:(int)callId;

-(void)onCallInProgressWithId:(int)callId
                  displayName:(NSString *)displayName
                    andSipURI:(NSString *)sipURI;

@end

@interface PJSipNotifications : NSObject <PJSipNotificationsDelegate>

+(PJSipNotifications *)sharedInstance;

-(void)onAccountRegistered:(int)accountId;

-(void)onAccountUnregistered:(int)accountId;

-(void)onIncomingCallWithId:(int)callId
                    account:(int)accountId
            fromDisplayName:(NSString *)displayName
                  andSipURI:(NSString *)sipURI;

-(void)onMissedIncomingCallFromDisplayName:(NSString *)displayName
                                 andSipURI:(NSString *)sipURI;

-(void)onIncomingDTMFdigit:(NSString *)dtmfDigit
            fromCallWithId:(int)callId;

-(void)onCallTerminatedWithId:(int)callId;

-(void)onCallInProgressWithId:(int)callId
                  displayName:(NSString *)displayName
                    andSipURI:(NSString *)sipURI;

@end
