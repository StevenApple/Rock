//
//  CachedStringWithFailureExpiration.m
//  VoiSmart Web Services
//
//  Created by Alex on 21/10/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "CachedStringWithFailureExpiration.h"

@interface CachedStringWithFailureExpiration()

@property (nonatomic, strong) NSString *string;
@property (nonatomic, assign) NSTimeInterval cacheUntil;
@property (nonatomic, assign) NSTimeInterval cacheTime;
@property (nonatomic, assign) NSInteger numberOfFailures;

@end

static NSInteger const MAX_FAILURES = 3;

@implementation CachedStringWithFailureExpiration

- (NSString *)string
{
    if ([[NSDate date] timeIntervalSince1970] < _cacheUntil) {
        return _string;
    }
    return nil;
}

- (BOOL)isNotNil
{
    if (self.string == nil) return NO;
    return YES;
}

- (void)setString:(NSString *)string
      andCacheFor:(NSTimeInterval)secondsFromNow
{
    _string = string;
    _cacheTime = secondsFromNow;
    _cacheUntil = [[NSDate date] timeIntervalSince1970] + secondsFromNow;
    _numberOfFailures = 0;
}

- (NSTimeInterval)cacheTime
{
    return _cacheTime;
}

- (NSTimeInterval)cacheExpirationTime
{
    return _cacheUntil;
}

- (void)reset
{
    _cacheUntil = 0;
    _cacheTime = 0;
    _string = nil;
    _numberOfFailures = 0;
}

- (void)registerFailure
{
    _numberOfFailures++;
    if (_numberOfFailures >= MAX_FAILURES) {
        [self reset];
    }
}

@end
