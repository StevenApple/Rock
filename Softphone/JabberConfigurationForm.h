//
//  JabberConfigurationForm.h
//  Softphone
//
//  Created by Alex Gotev on 28/01/15.
//  Copyright (c) 2015 voismart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FXForms.h>

@interface JabberConfigurationForm : NSObject <FXForm>

@property (strong, nonatomic) NSString *jabberID;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *resourceName;
@property (strong, nonatomic) NSString *server;
@property (assign, nonatomic) NSInteger port;
@property (assign, nonatomic) NSInteger priority;

@end
