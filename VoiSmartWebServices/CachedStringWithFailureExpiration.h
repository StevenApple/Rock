//
//  CachedStringWithFailureExpiration.h
//  VoiSmart Web Services
//
//  Extended cached string that it automatically reset if the number of registered
//  failures is >= that MAX_FAILURES
//
//  Created by Alex on 21/10/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CachedStringWithFailureExpiration : NSObject

- (NSString *)string;

- (BOOL)isNotNil;

- (NSTimeInterval)cacheTime;

- (NSTimeInterval)cacheExpirationTime;

- (void)setString:(NSString *)string andCacheFor:(NSTimeInterval)secondsFromNow;

- (void)reset;

- (void)registerFailure;

@end
