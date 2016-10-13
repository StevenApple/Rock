//
//  VSInCallViewController.h
//  Softphone
//
//  Created by Alex Gotev on 11/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PJSipWrapper.h"

@interface VSInCallViewController : UIViewController <UIAlertViewDelegate>

@property (assign, nonatomic) int callId;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *sipURI;

@end
