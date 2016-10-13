//
//  PJSipUtils.h
//  Softphone
//
//  Created by Alex Gotev on 02/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pjsua.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

@interface PJSipRemoteContactInfo : NSObject
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *sipURI;
@end

@interface PJSipUtils : NSObject

+(PJSipUtils *)sharedInstance;

+(pj_str_t)fromNSString:(NSString *)str;

+(NSString *)fromPJString:(const pj_str_t *)pjString;

+(PJSipRemoteContactInfo *)getSipRemoteContactInfo:(const pj_str_t *)pjString;

//Sound related functions
-(void)startRingTone;
-(void)stopRingTone;

@end
