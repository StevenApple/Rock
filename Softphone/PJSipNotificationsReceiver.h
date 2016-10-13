//
//  PJSipNotificationsReceiver.h
//  Softphone
//
//  Created by Alex Gotev on 04/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PJSipNotifications.h"

@interface PJSipNotificationsReceiver : NSObject
@property (nonatomic, weak) id<PJSipNotificationsDelegate> delegate;

-(void)registerObserver;
-(void)unregisterObserver;

@end
