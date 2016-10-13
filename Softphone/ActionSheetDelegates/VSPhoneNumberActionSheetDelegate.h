//
//  VSPhoneNumberActionSheetDelegate.h
//  Softphone
//
//  Created by Alex on 14/01/14.
//  Copyright (c) 2014 VoiSmart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VSPhoneNumberActionSheetDelegate : NSObject <UIActionSheetDelegate>

@property (nonatomic, strong) NSString *phoneNumber;

-(void)showInViewController:(UIViewController *)controller;

@end
