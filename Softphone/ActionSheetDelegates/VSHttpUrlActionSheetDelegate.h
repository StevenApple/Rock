#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VSHttpUrlActionSheetDelegate : NSObject <UIActionSheetDelegate>

@property (nonatomic, strong) NSString *url;

-(void)showInViewController:(UIViewController *)controller;

@end
