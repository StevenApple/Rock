//
//  Message.h
//  Softphone
//
//  Created by Alex on 26/11/13.
//  Copyright (c) 2013 VoiSmart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * recipient;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSNumber * type;

@end
