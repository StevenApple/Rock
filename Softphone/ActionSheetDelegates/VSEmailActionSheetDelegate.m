#import "VSEmailActionSheetDelegate.h"
#import "VSUtility.h"

@interface VSEmailActionSheetDelegate()

@property (weak, nonatomic) UIViewController *controller;

@end

@implementation VSEmailActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) { //Send e-mail action
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setToRecipients:[NSArray arrayWithObject:self.email]];
            [controller setSubject:@""];
            [controller setMessageBody:@"" isHTML:NO];
            if (controller) [self.controller presentViewController:controller animated:YES completion:nil];
        
        } else {
            [VSUtility showMessageDialogWithLocalizedTitle:@"WARNING"
                                       andLocalizedMessage:@"EMAIL_NOT_CONFIGURED"];
        }
        
    } else if (buttonIndex == 1) { //Copy action
        [UIPasteboard generalPasteboard].string = self.email;
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    [self.controller.presentedViewController dismissViewControllerAnimated:YES
                                                                completion:nil];
}

-(void)showInViewController:(UIViewController *)controller
{
    self.controller = controller;

    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:self.email
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"SEND_EMAIL", nil), NSLocalizedString(@"COPY", nil), nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [actionSheet showInView:controller.view];
    } else {
        [actionSheet showFromTabBar:controller.tabBarController.tabBar];
    }
}

@end
