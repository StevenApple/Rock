//
//  VSContact.m
//  VoiSmart Web Services
//
//  Created by Alex on 03/10/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "VSContact.h"
#import "NSData+XMPP.h"

@interface VSContact()

- (VSPhoneNumber *)getWithNumber:(NSString *)number
                     contactName:(NSString *)fullName
                         andType:(PhoneType)phoneType;

@end

@implementation VSContact

@synthesize mobilePhones = _mobilePhones;
@synthesize officePhones = _officePhones;
@synthesize faxes = _faxes;
@synthesize homePhones = _homePhones;

- (NSMutableArray *)mobilePhones
{
    if (_mobilePhones == nil) _mobilePhones = [[NSMutableArray alloc] init];
    return _mobilePhones;
}

- (NSMutableArray *)officePhones
{
    if (_officePhones == nil) _officePhones = [[NSMutableArray alloc] init];
    return _officePhones;
}

- (NSMutableArray *)faxes
{
    if (_faxes == nil) _faxes = [[NSMutableArray alloc] init];
    return _faxes;
}


- (NSMutableArray *)homePhones
{
    if (_homePhones == nil) _homePhones = [[NSMutableArray alloc] init];
    return _homePhones;
}

- (NSInteger)getTotalPhonesCount
{
    return ([self.faxes count] + [self.mobilePhones count] + [self.officePhones count] + [self.homePhones count]);
}

- (NSMutableArray *)getAllPhones
{
    NSMutableArray *allPhones = [[NSMutableArray alloc] init];
    
    NSString *fullName = [[NSString alloc] initWithFormat:@"%@ %@", self.name, self.surname];
    
    if ([self.faxes count] > 0)
        for (NSString *number in self.faxes) {
            VSPhoneNumber *phoneNumber = [self getWithNumber:number
                                                 contactName:fullName
                                                     andType:FAX];
            [allPhones addObject:phoneNumber];
        }
    
    if ([self.mobilePhones count] > 0)
        for (NSString *number in self.mobilePhones) {
            VSPhoneNumber *phoneNumber = [self getWithNumber:number
                                                 contactName:fullName
                                                     andType:MOBILE];
            [allPhones addObject:phoneNumber];
        }
    
    if ([self.officePhones count] > 0)
        for (NSString *number in self.officePhones) {
            VSPhoneNumber *phoneNumber = [self getWithNumber:number
                                                 contactName:fullName
                                                     andType:OFFICE];
            [allPhones addObject:phoneNumber];
        }
    
    if ([self.homePhones count] > 0)
        for (NSString *number in self.homePhones) {
            VSPhoneNumber *phoneNumber = [self getWithNumber:number
                                                 contactName:fullName
                                                     andType:HOME];
            [allPhones addObject:phoneNumber];
        }
    
    return allPhones;
}

- (void)setImageFromBase64StringData:(NSString *)data
{
    if (data == nil || [data length] == 0) return;
    
    NSData *nsdata = [[NSData alloc] initWithBase64EncodedString:data options:NSDataBase64DecodingIgnoreUnknownCharacters];
    self.image = [UIImage imageWithData:nsdata];
}

- (VSPhoneNumber *)getWithNumber:(NSString *)number
                     contactName:(NSString *)fullName
                         andType:(PhoneType)phoneType
{
    VSPhoneNumber *phoneNumber =
    [[VSPhoneNumber alloc] initWithContactName:fullName phoneNumber:number type:phoneType];
    return phoneNumber;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"Name:%@, Surname:%@, Company:%@, Title:%@, Numbers:%tu",
            self.name, self.surname, self.company, self.title,
            [self.officePhones count] + [self.faxes count] + [self.homePhones count] + [self.mobilePhones count]];
}

- (NSString *)getFormattedFullAddress
{
    NSString *fullAddress = @"";
    
    fullAddress = [fullAddress stringByAppendingString:[self addNewLineIfNotEmpty:self.address]];
    fullAddress = [fullAddress stringByAppendingString:[self postalCodeAndCity]];
    fullAddress = [fullAddress stringByAppendingString:[self addNewLineIfNotEmpty:self.state]];
    if (self.country)
        fullAddress = [fullAddress stringByAppendingString:self.country];
    
    return fullAddress;
}

- (NSString *)addNewLineIfNotEmpty:(NSString *)string
{
    if (string && ![string isEqualToString:@""]) {
        return [string stringByAppendingString:@"\n"];
    }
    return @"";
}

- (NSString *)addSpaceIfNotEmpty:(NSString *)string
{
    if (string && ![string isEqualToString:@""]) {
        return [string stringByAppendingString:@" "];
    }
    return @"";
}

- (NSString *)postalCodeAndCity
{
    NSString *code = [self addSpaceIfNotEmpty:self.postalCode];
    
    if (self.city && ![self.city isEqualToString:@""]) {
        return [self addNewLineIfNotEmpty:[NSString stringWithFormat:@"%@%@", code, self.city]];
    }
    return @"";
}

- (NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ %@", self.name, self.surname];
}

@end
