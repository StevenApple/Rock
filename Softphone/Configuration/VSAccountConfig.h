//
//  VSAccountConfig.h
//  Softphone
//
//  Created by Alex on 23/10/13.
//  Copyright (c) 2013 VoiSmart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoiSmartWebServicesFactory.h"

typedef NS_ENUM(NSInteger, VSOutgoingCallType) {
    CALL_TYPE_VOIP,
    CALL_TYPE_CALLBACK
};

@interface VSAccountConfig : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *pbxAddress;
@property (nonatomic, assign) BOOL registerSip;
@property (nonatomic, assign) BOOL registerXmpp;
@property (nonatomic, assign) BOOL registerSipVia3G;
@property (nonatomic, assign) BOOL registerXmppVia3G;
@property (nonatomic, assign) VSOrchestraVersion orchestraVersion;
@property (nonatomic, strong) NSString *myPhoneNumber;
@property (nonatomic, assign) VSOutgoingCallType defaultCallType;

- (void) reload;
- (BOOL) isDefined;
- (BOOL) reset;
- (BOOL) save;
- (BOOL) isCallbackCallType;
- (BOOL) isVoIPCallType;

- (id<VoiSmartWebServices>)getWebServicesInstance;

@end
