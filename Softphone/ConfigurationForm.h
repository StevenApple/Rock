//
//  ConfigurationForm.h
//  Softphone
//
//  Created by Alex Gotev on 17/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FXForms.h>
#import "VSAccountConfig.h"
#import "Configuration/VSConfiguration.h"

@interface ConfigurationForm : NSObject <FXForm>

@property (strong, nonatomic) NSString *address;
@property (assign, nonatomic) VSOrchestraVersion version;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;

@property (assign, nonatomic) BOOL telephoneOnWifi;
@property (assign, nonatomic) BOOL telephoneOn3G;
@property (assign, nonatomic) BOOL messagesOnWifi;
@property (assign, nonatomic) BOOL messagesOn3G;

@property (strong, nonatomic) NSString *myPhoneNumber;
@property (assign, nonatomic) VSOutgoingCallType defaultCallType;

@end
