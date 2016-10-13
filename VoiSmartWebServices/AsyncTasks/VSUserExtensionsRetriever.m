#import "VSUserExtensionsRetriever.h"
#import "VSUtility.h"
#import "MBProgressHUD.h"
#import "PJSipWrapper.h"

@interface VSUserExtensionsRetriever() <VoiSmartWebServiceDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) id<VoiSmartWebServices> webServices;
@property (weak, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *alias;

@end

@implementation VSUserExtensionsRetriever

-(id)initWithWebServices:(id<VoiSmartWebServices>)services
{
    self = [super init];
    
    if (self) {
        self.webServices =  services;
    }
    
    return self;
}

- (void)retrieveExtensionsForUsername:(NSString *)username
                            withAlias:(NSString *)alias
                     inViewController:(UIViewController *)viewController
{
    [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    
    self.username = username;
    self.alias = alias;
    self.viewController = viewController;

    [self.webServices getLicenseAndSendResponseToDelegate:self];
    //async response sent to receivedLicenseIsValid:withWebServiceToken:error:
}

- (void) receivedLicenseIsValid:(BOOL)valid
            withWebServiceToken:(NSString *)webServiceToken
                          error:(NSError *)error
{
    if (valid && webServiceToken != nil && [webServiceToken length] > 0) {
        [self.webServices getExtensionsByUserWithToken:webServiceToken
                                     username:self.username
                                     delegate:self];
        //async response sent to receivedUserExtensions:error:
        
    } else {
        [MBProgressHUD hideHUDForView:self.viewController.view animated:YES];
        
        [VSUtility showMessageDialogWithLocalizedTitle:@"WARNING"
                                   andLocalizedMessage:@"INVALID_LICENSE"];
    }
}

- (void) receivedUserExtensions:(NSArray *)extensions
                          error:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.viewController.view animated:YES];
    
    if (extensions && [extensions count] > 0) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:self.alias
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        
        for (NSString *extension in extensions) {
            [actionSheet addButtonWithTitle:extension];
        }
        
        [actionSheet addButtonWithTitle:NSLocalizedString(@"CANCEL", nil)];
        actionSheet.cancelButtonIndex = [extensions count];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [actionSheet showInView:self.viewController.view];
        } else {
            [actionSheet showFromTabBar:self.viewController.tabBarController.tabBar];
        }
        
    } else {
        [VSUtility showMessageDialogWithLocalizedTitle:@"WARNING"
                                   andLocalizedMessage:@"NO_TELEPHONE_NUMBERS"];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if (![buttonTitle isEqualToString:NSLocalizedString(@"CANCEL", nil)]) {
        [VSUtility makeCallTo:buttonTitle];
    }
}

@end
