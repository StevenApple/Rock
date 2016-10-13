//
//  VSSipAccountConfig.h
//  VoiSmart Web Services
//
//  Created by Alex on 13/11/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSSipAccountConfig : NSObject

@property (nonatomic, strong) NSString *privateId;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *realm;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, assign) NSInteger port;
@property (nonatomic, strong) NSString *displayName;

@end
