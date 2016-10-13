//
//  ConfigurationForm.m
//  Softphone
//
//  Created by Alex Gotev on 17/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import "ConfigurationForm.h"

@implementation ConfigurationForm

-(id)init
{
    self = [super init];
    
    if (self) {
        VSAccountConfig *cfg = [[VSConfiguration sharedInstance] accountConfig];
        self.address = cfg.pbxAddress;
        self.version = cfg.orchestraVersion;
        self.username = cfg.username;
        self.password = cfg.password;
        self.telephoneOnWifi = cfg.registerSip;
        self.telephoneOn3G = cfg.registerSipVia3G;
        self.messagesOnWifi = cfg.registerXmpp;
        self.messagesOn3G = cfg.registerXmppVia3G;
        self.myPhoneNumber = cfg.myPhoneNumber;
        self.defaultCallType = cfg.defaultCallType;
    }
    
    return self;
}

- (NSDictionary *)addressField
{
    return @{FXFormFieldPlaceholder: NSLocalizedString(@"PBX_ADDRESS_HINT", nil)};
}

- (NSDictionary *)usernameField
{
    return @{FXFormFieldPlaceholder: NSLocalizedString(@"USERNAME_ADDRESS_HINT", nil)};
}

- (NSDictionary *)passwordField
{
    return @{FXFormFieldPlaceholder:NSLocalizedString(@"PASSWORD_HINT", nil)};
}

- (NSDictionary *)telephoneOnWifiField
{
    return @{FXFormFieldTitle: NSLocalizedString(@"WIFI_NETWORK", nil)};
}

- (NSDictionary *)telephoneOn3GField
{
    return @{FXFormFieldTitle: NSLocalizedString(@"MOBILE_NETWORK", nil)};
}

- (NSDictionary *)messagesOnWifiField
{
    return @{FXFormFieldTitle: NSLocalizedString(@"WIFI_NETWORK", nil)};
}

- (NSDictionary *)messagesOn3GField
{
    return @{FXFormFieldTitle: NSLocalizedString(@"MOBILE_NETWORK", nil)};
}

- (NSDictionary *)myPhoneNumberField
{
    return @{FXFormFieldTitle: NSLocalizedString(@"MY_PHONE_NUMBER", nil),
             FXFormFieldPlaceholder: NSLocalizedString(@"MY_PHONE_NUMBER_HINT", nil)};
}

- (NSDictionary *)defaultCallTypeField
{
    return @{FXFormFieldTitle: NSLocalizedString(@"DEFAULT_CALL_TYPE", nil)};
}

- (NSArray *)fields
{
    return @[
        @{FXFormFieldKey: @"address",
          FXFormFieldType: FXFormFieldTypeURL,
          FXFormFieldHeader: NSLocalizedString(@"PBX", nil)},

        @{FXFormFieldKey: @"version",
          FXFormFieldOptions: @[@"Orchestra 5", @"Orchestra NG"],
          FXFormFieldFooter: NSLocalizedString(@"PBX_FOOTER", nil)},
        
        @{FXFormFieldHeader: NSLocalizedString(@"ACCOUNT", nil),
          FXFormFieldKey: @"username",
          FXFormFieldType: FXFormFieldTypeEmail},
        @{FXFormFieldKey: @"password",
          FXFormFieldFooter: NSLocalizedString(@"ACCOUNT_FOOTER", nil)},
        
        @{FXFormFieldHeader: NSLocalizedString(@"TELEPHONE", nil),
          FXFormFieldKey: @"telephoneOnWifi"},
        @{FXFormFieldKey: @"telephoneOn3G",
          FXFormFieldFooter: NSLocalizedString(@"TELEPHONE_FOOTER", nil)},
        
        @{FXFormFieldHeader: NSLocalizedString(@"MESSAGES", nil),
          FXFormFieldKey: @"messagesOnWifi"},
        @{FXFormFieldKey: @"messagesOn3G",
          FXFormFieldFooter: NSLocalizedString(@"MESSAGES_FOOTER", nil)},
        
        @{FXFormFieldHeader: NSLocalizedString(@"CALLBACK", nil),
          FXFormFieldKey: @"myPhoneNumber",
          FXFormFieldType: FXFormFieldTypePhone},
        
        @{FXFormFieldKey: @"defaultCallType",
          FXFormFieldOptions: @[@"VoIP", NSLocalizedString(@"CALLBACK", nil)]},
        
        @{FXFormFieldHeader:@"",
          FXFormFieldTitle: NSLocalizedString(@"SAVE_AND_APPLY", nil),
          FXFormFieldFooter: NSLocalizedString(@"SAVE_AND_APPLY_FOOTER", nil),
          FXFormFieldAction: @"saveAndApply:"},
        
        @{FXFormFieldTitle: NSLocalizedString(@"RESET_ACCOUNT", nil),
          FXFormFieldFooter: NSLocalizedString(@"RESET_ACCOUNT_FOOTER", nil),
          FXFormFieldAction: @"reset:"},
        
        @{FXFormFieldHeader:NSLocalizedString(@"ADVANCED_SETTINGS", nil),
          FXFormFieldTitle: NSLocalizedString(@"SIP_SETTINGS", nil),
          FXFormFieldAction: @"sipSettings:"},
        
        @{FXFormFieldTitle: NSLocalizedString(@"JABBER_SETTINGS", nil),
          FXFormFieldAction: @"jabberSettings:"},
        
        @{FXFormFieldTitle: NSLocalizedString(@"NETWORK_TEST", nil),
          FXFormFieldAction: @"networkTest:",
          FXFormFieldFooter:@""}
    ];
}

@end
