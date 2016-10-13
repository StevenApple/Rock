#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VSMapsActionSheetDelegate : NSObject <UIActionSheetDelegate>

@property (nonatomic, strong) NSString *address;

-(void)showInViewController:(UIViewController *)controller;

@end
