//
//  VSCallRegistryItem.h
//  VoiSmart Web Services
//
//  Created by Alex on 03/10/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VSCallType) {
    INCOMING,
    OUTGOING,
    MISSED
};

@interface VSCallRegistryItem : NSObject

@property (nonatomic, strong) NSString *number;
@property (nonatomic, assign) VSCallType callType;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;

@end
