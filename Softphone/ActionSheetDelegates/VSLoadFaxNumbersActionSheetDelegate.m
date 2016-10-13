#import "VSLoadFaxNumbersActionSheetDelegate.h"
#import "VSConfiguration.h"
#import "MBProgressHUD.h"
#import "VSUtility.h"

@interface VSLoadFaxNumbersActionSheetDelegate()

@property (weak, nonatomic) UIViewController *controller;
@property (copy, nonatomic) SelectedFaxNumber postExecuteBlock;

@end

@implementation VSLoadFaxNumbersActionSheetDelegate

-(void)showInViewController:(UIViewController *)controller
         onCompletedExecute:(SelectedFaxNumber)block
{
    self.controller = controller;
    self.postExecuteBlock = block;
    
    [MBProgressHUD showHUDAddedTo:self.controller.view animated:YES];

    id<VoiSmartWebServices> service = [[[VSConfiguration sharedInstance] accountConfig] getWebServicesInstance];
    [service getLicenseAndSendResponseToDelegate:self];
    //async response sent to receivedLicenseIsValid:withWebServiceToken:error:
}

- (void) receivedLicenseIsValid:(BOOL)valid
            withWebServiceToken:(NSString *)webServiceToken
                          error:(NSError *)error
{
    if (valid && webServiceToken != nil && [webServiceToken length] > 0) {
        id<VoiSmartWebServices> service = [[[VSConfiguration sharedInstance] accountConfig] getWebServicesInstance];
        [service getFaxNumbersWithToken:webServiceToken delegate:self];
        //async response sent to receivedFaxNumbers:error:
        
    } else {
        [MBProgressHUD hideHUDForView:self.controller.view animated:YES];
        
        [VSUtility showMessageDialogWithLocalizedTitle:@"WARNING"
                                   andLocalizedMessage:@"INVALID_LICENSE"];
    }
}

- (void) receivedFaxNumbers:(NSArray *)faxNumbers
                      error:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.controller.view animated:YES];
    
    if (faxNumbers == nil || [faxNumbers count] == 0) {
        [VSUtility showMessageDialogWithLocalizedTitle:@"WARNING"
                                   andLocalizedMessage:@"NO_FAX_NUMBERS"];
    
    } else {
    
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:NSLocalizedString(@"SELECT_FAX_NUMBER", nil)
                                      delegate:self
                                      cancelButtonTitle:nil
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:nil];
        
        for (NSString *number in faxNumbers) {
            [actionSheet addButtonWithTitle:number];
        }
        
        [actionSheet addButtonWithTitle:NSLocalizedString(@"CANCEL", nil)];
        actionSheet.cancelButtonIndex = [faxNumbers count];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [actionSheet showInView:self.controller.view];
        } else {
            [actionSheet showFromTabBar:self.controller.tabBarController.tabBar];
        }

    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if (![buttonTitle isEqualToString:NSLocalizedString(@"CANCEL", nil)]) {
        self.postExecuteBlock(buttonTitle);
    }
}

@end
