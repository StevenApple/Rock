//
//  PJSipWrapper.h
//  Softphone
//
//  Created by Alex Gotev on 01/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreTelephony/CTCallCenter.h>

// PJSIP includes
#include <pjlib.h>
#include <pjlib-util.h>
#include <pjnath.h>
#include <pjsip.h>
#include <pjsip_ua.h>
#include <pjsip_simple.h>
#include <pjsua-lib/pjsua.h>
#include <pjmedia.h>
#include <pjmedia-codec.h>

#include "PJSipUtils.h"
#include "PJSipNotifications.h"

@interface PJSipWrapper : NSObject

+(PJSipWrapper *)sharedInstance;

//Checks if the user is currently busy in a GSM Call
-(BOOL)isGSMCallInProgress;

//Start the SIP stack
//Subsequent calls to this method doesn't do anything
-(BOOL)start;

//Check if the SIP stack is initialized
-(BOOL)isInitialized;

//Method called by the UIApplicationDelegate when it goes in background
//to keep alive the SIP registration
-(void)keepAliveInBackground;

//Manually sends a keep alive for the SIP registration
-(void)sendKeepAlive;

//Sets the SIP account to be used
-(BOOL)setSipUser:(NSString *)sipUser
     withPassword:(NSString *)sipPassword
         andRealm:(NSString *)sipRealm
           onHost:(NSString *)sipHost
       andSipPort:(int)sipPort
 withTCPTransport:(BOOL)tcpTransport;

//Makes a call to a number
-(int)makeCallTo:(NSString *)number;

//Sends a DTMF tone. Vaid strings are 0-9 and * and #
-(BOOL)sendDTMF:(NSString *)dtmfTone
   toCallWithId:(int)callId;

//Accepts a call
-(BOOL)acceptCallWithId:(int)callId;

//Hangs up a call
-(BOOL)hangUpCallWithId:(int)callId;

//Holds a call
-(BOOL)holdCallWithId:(int)callId;

//Unholds a call
-(BOOL)unholdCallWithId:(int)callId;

//Mutes a call
-(BOOL)muteCallWithId:(int)callId;

//Unmutes a call
-(BOOL)unmuteCallWithId:(int)callId;

//Transfer a call
-(BOOL)transferCallWithId:(int)callId
              toExtension:(NSString *)extension;

//Get the currently set SIP user
-(NSString *)getSipUser;

//Performs SIP registration
-(BOOL)registerAccount;

//Performs SIP unregistration
-(BOOL)unregisterAccount;

//Checks if the account is registered
-(BOOL)isRegistered;

//Shutdown the SIP stack
-(BOOL)shutdown;

//Restarts the sip stack with the current settings
-(BOOL)restartWithCurrentSettings;

@end
