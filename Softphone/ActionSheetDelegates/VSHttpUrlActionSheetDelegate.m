#import "VSHttpUrlActionSheetDelegate.h"

@interface VSHttpUrlActionSheetDelegate()

@property (weak, nonatomic) UIViewController *controller;

@end

@implementation VSHttpUrlActionSheetDelegate

-(void)showInViewController:(UIViewController *)controller
{
    self.controller = controller;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:self.url
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"OPEN_LINK", nil),NSLocalizedString(@"COPY", nil), nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [actionSheet showInView:controller.view];
    } else {
        [actionSheet showFromTabBar:controller.tabBarController.tabBar];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) { //Open link action
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
        
    } else if (buttonIndex == 1) { //Copy action
        [UIPasteboard generalPasteboard].string = self.url;
    }
}

@end
