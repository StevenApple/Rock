//
//  SipConfigurationForm.m
//  Softphone
//
//  Created by Alex Gotev on 28/01/15.
//  Copyright (c) 2015 voismart. All rights reserved.
//

#import "SipConfigurationForm.h"
#import "VSConfiguration.h"

@implementation SipConfigurationForm

-(id)init
{
    self = [super init];
    
    if (self) {
        VSPersistentSipAccountConfig *sipConfig = [[VSConfiguration sharedInstance] sipConfig];
        self.extension = sipConfig.privateId;
        self.password = sipConfig.password;
        self.host = sipConfig.host;
        self.realm = sipConfig.realm;
        self.port = sipConfig.port;
    }
    
    return self;
}

- (NSDictionary *)extensionField
{
    return @{FXFormFieldTitle: NSLocalizedString(@"EXTENSION", nil)};
}

- (NSDictionary *)portField
{
    return @{FXFormFieldTitle: NSLocalizedString(@"SIP_PORT", nil),
             FXFormFieldType: FXFormFieldTypeInteger};
}

- (NSDictionary *)hostField
{
    return @{FXFormFieldType: FXFormFieldTypeURL};
}

- (NSArray *)extraFields
{
    return @[
             @{FXFormFieldHeader: @"",
               FXFormFieldTitle: NSLocalizedString(@"SAVE_AND_APPLY", nil),
               FXFormFieldAction: @"saveAndApply:"}
             ];
}

@end
