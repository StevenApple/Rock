//
//  AppDelegate.h
//  Softphone
//
//  Created by Alex Gotev on 01/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PJSipNotificationsReceiver.h"
#import "VSConnectionServiceEventReceiver.h"
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, PJSipNotificationsDelegate, VSConnectionServiceEventReceiverDelegate>

@property (strong, nonatomic) UIWindow *window;

//Sets the host to be used as a reference for the internet connection
-(void)setReachabilityHost:(NSString *)host;

-(NetworkStatus)currentNetworkStatus;

@end

