//
//  VSConfiguration.m
//  Softphone
//
//  Created by Alex on 26/11/13.
//  Copyright (c) 2013 VoiSmart. All rights reserved.
//

#import "VSConfiguration.h"

static VSConfiguration *_sharedInstance = nil;

@interface VSConfiguration()

@property (nonatomic, strong) VSPersistentSipAccountConfig *sipConfig;
@property (nonatomic, strong) VSXmppAccountConfig *xmppConfig;
@property (nonatomic, strong) VSAccountConfig *accountConfig;

@end

@implementation VSConfiguration

+ (VSConfiguration *)sharedInstance
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [[VSConfiguration alloc] init];
        }
        
        return _sharedInstance;
    }   			
}

- (VSAccountConfig *)accountConfig
{
    if (_accountConfig == nil) {
        _accountConfig = [[VSAccountConfig alloc] init];
    }
    
    return _accountConfig;
}

- (BOOL)updateAndSaveAccountConfig:(VSAccountConfig *)config
{
    _accountConfig = config;
    
    return ([_accountConfig save]);
}

- (VSPersistentSipAccountConfig *)sipConfig
{
    _sipConfig = [[VSPersistentSipAccountConfig alloc] init];
    
    return _sipConfig;
}

- (BOOL)updateAndSaveSipConfig:(VSPersistentSipAccountConfig *)config
{
    _sipConfig = config;
    
    return ([_sipConfig save]);
}

- (VSXmppAccountConfig *)xmppConfig
{
    if (_xmppConfig == nil) {
        _xmppConfig = [[VSXmppAccountConfig alloc] init];
    }
    
    return _xmppConfig;
}

- (BOOL)updateAndSaveXmppConfig:(VSXmppAccountConfig *)config
{
    _xmppConfig = config;
    
    return ([_xmppConfig save]);
}

- (BOOL)resetAll
{
    return ([self.accountConfig reset] && [self.sipConfig reset] && [self.xmppConfig reset]);
}

@end
