//
//  VSPhoneNumber.h
//  VoiSmart Web Services
//
//  Created by Alex on 03/10/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PhoneType) {
    FAX,
    MOBILE,
    OFFICE,
    HOME
};

@interface VSPhoneNumber : NSObject

@property (nonatomic, strong) NSString *contactName;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, assign) PhoneType phoneType;

- (id) initWithContactName:(NSString *)contactName
               phoneNumber:(NSString *)phoneNumber
                      type:(PhoneType)type;

@end
