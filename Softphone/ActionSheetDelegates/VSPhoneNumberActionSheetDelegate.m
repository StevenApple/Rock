#import "VSPhoneNumberActionSheetDelegate.h"
#import "PJSipWrapper.h"
#import "VSUtility.h"

@implementation VSPhoneNumberActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) { //Call via GSM action
        [VSUtility makeGSMphoneCallTo:self.phoneNumber];
        
    } else if (buttonIndex == 1) { //Call via IP Communicator action
        [VSUtility makeCallTo:self.phoneNumber];

    } else if (buttonIndex == 2) { //Copy action
        [UIPasteboard generalPasteboard].string = self.phoneNumber;
    }
}

-(void)showInViewController:(UIViewController *)controller
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:self.phoneNumber
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"CALL_VIA_GSM", nil),NSLocalizedString(@"CALL_VIA_IPCOMM", nil), NSLocalizedString(@"COPY", nil), nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [actionSheet showInView:controller.view];
    } else {
        [actionSheet showFromTabBar:controller.tabBarController.tabBar];
    }
}

@end
