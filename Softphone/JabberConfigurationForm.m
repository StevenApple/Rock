//
//  JabberConfigurationForm.m
//  Softphone
//
//  Created by Alex Gotev on 28/01/15.
//  Copyright (c) 2015 voismart. All rights reserved.
//

#import "JabberConfigurationForm.h"
#import "VSConfiguration.h"

@implementation JabberConfigurationForm

-(id)init
{
    self = [super init];
    
    if (self) {
        VSXmppAccountConfig *cfg = [[VSConfiguration sharedInstance] xmppConfig];
        self.jabberID =  cfg.account;
        self.password =  cfg.password;
        self.resourceName = cfg.resourceName;
        self.server = cfg.server;
        self.port = cfg.port;
        self.priority = cfg.priority;
    }
    
    return self;
}

-(NSDictionary *) jabberIDField
{
    return @{FXFormFieldType: FXFormFieldTypeURL};
}

-(NSDictionary *) serverField
{
    return @{FXFormFieldType: FXFormFieldTypeURL,
             FXFormFieldPlaceholder: NSLocalizedString(@"SERVER_AUTO_PLACEHOLDER", nil)};
}

-(NSDictionary *) portField
{
    return @{FXFormFieldType: FXFormFieldTypeInteger,
             FXFormFieldTitle: NSLocalizedString(@"JABBER_PORT", nil)};
}

-(NSDictionary *) priorityField
{
    return @{FXFormFieldType: FXFormFieldTypeInteger,
             FXFormFieldTitle: NSLocalizedString(@"PRIORITY", nil),
             FXFormFieldPlaceholder: NSLocalizedString(@"PRIORITY_PLACEHOLDER.", nil)};
}

- (NSDictionary *)resourceNameField
{
    return @{FXFormFieldTitle: NSLocalizedString(@"RESOURCE_NAME", nil)};
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
