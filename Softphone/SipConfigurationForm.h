//
//  SipConfigurationForm.h
//  Softphone
//
//  Created by Alex Gotev on 28/01/15.
//  Copyright (c) 2015 voismart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FXForms.h>

@interface SipConfigurationForm : NSObject <FXForm>

@property (strong, nonatomic) NSString *extension;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *host;
@property (strong, nonatomic) NSString *realm;
@property (assign, nonatomic) NSInteger port;

@end
