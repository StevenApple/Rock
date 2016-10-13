#import "VSInsertNumberActionSheetDelegate.h"
#import "VSSearchTelephoneViewController.h"
#import "VSUtility.h"
#import "VSPhoneNumber.h"

@interface VSInsertNumberActionSheetDelegate()

@property (weak, nonatomic) UIViewController *controller;
@property (copy, nonatomic) SelectedNumberBlock postExecuteBlock;
@property (strong, nonatomic) NSString *selectedNumber;

@end

@implementation VSInsertNumberActionSheetDelegate

-(void)showInViewController:(UIViewController *)controller
    onNumberProvidedExecute:(SelectedNumberBlock)block
{
    self.controller = controller;
    self.postExecuteBlock = block;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:NSLocalizedString(@"ADD_RECIPIENT", nil)
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"INSERT_NUMBER", nil),
                                                    NSLocalizedString(@"SEARCH_IN_CONTACTS", nil),
                                                    nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [actionSheet showInView:controller.view];
    } else {
        [actionSheet showFromTabBar:controller.tabBarController.tabBar];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self onInsertNumber];
            break;
            
        case 1:
            [self onSearchInContacts];
            break;
            
        case 2: //Cancel
        default:
            break;
    }
}

-(void)onInsertNumber
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"ADD_RECIPIENT", nil)
                              message:NSLocalizedString(@"INSERT_NUMBER", nil)
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                              otherButtonTitles:@"Ok", nil];
    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    [[alertView textFieldAtIndex:0] becomeFirstResponder];
    [alertView show];
    //The result is handled by the following method
}

- (void)alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) { //if the selected button is OK
        NSString *text = [alertView textFieldAtIndex:0].text;
        
        if (text && ![text isEqualToString:@""])
            self.postExecuteBlock(text, @"");
    }
}

- (void)onSearchInContacts
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(selectedNumber:)
     name:NOTIFICATION_NAME_VSNUMBER_SELECTED
     object:nil];
    
    VSSearchTelephoneViewController *searchTelephone =
    (VSSearchTelephoneViewController *)[VSUtility getViewControllerWithIdentifier:@"SearchTelephone"
                                                               fromStorybordNamed:@"Main"];
    searchTelephone.hidesBottomBarWhenPushed = YES;
    
    [self.controller.navigationController pushViewController:searchTelephone animated:YES];
}

- (void)selectedNumber:(NSNotification *)notification
{
    VSPhoneNumber *number = [notification object];
    
    [self.controller.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    self.postExecuteBlock([number phoneNumber], [number contactName]);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
