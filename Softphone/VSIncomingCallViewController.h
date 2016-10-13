//
//  VSIncomingCallViewController.h
//  Softphone
//
//  Created by Alex Gotev on 10/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "PJSipWrapper.h"

@interface VSIncomingCallViewController : UIViewController

@property (assign, nonatomic) int callId;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *sipURI;

@end
