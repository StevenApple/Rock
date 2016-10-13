#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface VSEmailActionSheetDelegate : NSObject <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSString *email;

-(void)showInViewController:(UIViewController *)controller;

@end
