//
//  VSConfiguration.h
//  Softphone
//
//  Created by Alex on 26/11/13.
//  Copyright (c) 2013 VoiSmart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSPersistentSipAccountConfig.h"
#import "VSXmppAccountConfig.h"
#import "VSAccountConfig.h"

@interface VSConfiguration : NSObject

+ (VSConfiguration *)sharedInstance;

- (VSAccountConfig *)accountConfig;
- (BOOL)updateAndSaveAccountConfig:(VSAccountConfig *)config;

- (VSPersistentSipAccountConfig *)sipConfig;
- (BOOL)updateAndSaveSipConfig:(VSPersistentSipAccountConfig *)config;

- (VSXmppAccountConfig *)xmppConfig;
- (BOOL)updateAndSaveXmppConfig:(VSXmppAccountConfig *)config;

- (BOOL)resetAll;

@end
