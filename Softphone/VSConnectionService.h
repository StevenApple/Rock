//
//  VSConnectionService.h
//  Softphone
//
//  Created by Alex on 15/11/13.
//  Copyright (c) 2013 VoiSmart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoiSmartWebServicesFactory.h"
#import "ReachabilityEventReceiver.h"
#import "VSConfiguration.h"

static NSString *const VS_CONNECTION_SERVICE_NOTIFICATION = @"VSConnectionServiceNotification";
static NSString *const VS_CONNECTION_SERVICE_NOTIFICATION_STATUS = @"VSConnectionServiceNotificationStatus";

typedef NS_ENUM(NSInteger, VSConnectionServiceStatus) {
    VS_CONNECTION_SERVICE_LOGIN_ERROR,
    VS_CONNECTION_SERVICE_NO_LICENSE,
    VS_CONNECTION_SERVICE_LOGIN_OK,
    VS_CONNECTION_SERVICE_NO_SIP_ACCOUNTS,
    VS_CONNECTION_SERVICE_XMPP_LOGIN_ERROR,
    VS_CONNECTION_SERVICE_NO_INTERNET_CONNECTION
};

@interface VSConnectionService : NSObject<VoiSmartWebServiceDelegate, ReachabilityEventReceiverDelegate>

+ (VSConnectionService *)sharedInstance;

- (void)connectAllConfiguredServices;

- (void)stopAllServices;

- (void)restartAllServices;

- (void)shutdown;

@end
