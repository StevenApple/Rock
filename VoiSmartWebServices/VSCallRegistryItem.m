//
//  VSCallRegistryItem.m
//  VoiSmart Web Services
//
//  Created by Alex on 03/10/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "VSCallRegistryItem.h"

@implementation VSCallRegistryItem

@synthesize number = _number;
@synthesize callType = _callType;
@synthesize startTime = _startTime;
@synthesize endTime = _endTime;

- (NSString *)description {
    return [NSString stringWithFormat: @"Number:%@, CallType:%zu, StartTime:%@ EndTime:%@",
            self.number, (long)self.callType, self.startTime, self.endTime];
}

@end
