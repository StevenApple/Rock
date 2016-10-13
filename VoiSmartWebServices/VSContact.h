#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VSPhoneNumber.h"

@interface VSContact : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *surname;
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *country;

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *homePageUrl;
@property (nonatomic, strong) NSString *notes;

@property (nonatomic, strong) NSMutableArray *mobilePhones;
@property (nonatomic, strong) NSMutableArray *officePhones;
@property (nonatomic, strong) NSMutableArray *faxes;
@property (nonatomic, strong) NSMutableArray *homePhones;

@property (nonatomic, strong) UIImage *image;

- (NSMutableArray *)getAllPhones;
- (NSInteger)getTotalPhonesCount;
- (void)setImageFromBase64StringData:(NSString *)data;
- (NSString *)getFormattedFullAddress;
- (NSString *)fullName;

@end
