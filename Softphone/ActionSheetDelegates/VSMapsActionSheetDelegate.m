#import "VSMapsActionSheetDelegate.h"
#import "VSUtility.h"

@interface VSMapsActionSheetDelegate()

@property (weak, nonatomic) UIViewController *controller;

@end

@implementation VSMapsActionSheetDelegate

-(void)showInViewController:(UIViewController *)controller
{
    self.controller = controller;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:NSLocalizedString(@"ADDRESS", nil)
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"OPEN_IN_MAPS", nil), NSLocalizedString(@"COPY", nil), nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [actionSheet showInView:controller.view];
    } else {
        [actionSheet showFromTabBar:controller.tabBarController.tabBar];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) { //Open in maps action
        [VSUtility openMapsToAddress:self.address inView:self.controller.view];
        
    } else if (buttonIndex == 1) { //Copy action
        [UIPasteboard generalPasteboard].string = self.address;
    }
}

@end
