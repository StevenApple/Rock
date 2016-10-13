//
//  VSPhoneNumber.m
//  VoiSmart Web Services
//
//  Created by Alex on 03/10/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "VSPhoneNumber.h"

@implementation VSPhoneNumber

- (id) initWithContactName:(NSString *)contactName
               phoneNumber:(NSString *)phoneNumber
                      type:(PhoneType)type
{
    self = [self init];
    self.contactName = contactName;
    self.phoneNumber = phoneNumber;
    self.phoneType = type;
    return self;
}

@end
