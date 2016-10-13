//
//  VSSipAccountConfig.h
//  Softphone
//
//  Created by Alex on 23/10/13.
//  Copyright (c) 2013 VoiSmart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSipAccountConfig.h"

@interface VSPersistentSipAccountConfig : NSObject

@property (nonatomic, strong) NSString *privateId;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *realm;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, assign) NSInteger port;
@property (nonatomic, strong) NSString *displayName;

- (void) reload;
- (BOOL) isDefined;
- (BOOL) reset;
- (BOOL) save;
- (void) setFromSipAccountConfig:(VSSipAccountConfig *)config;

@end
