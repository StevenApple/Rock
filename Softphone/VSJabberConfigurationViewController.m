//
//  VSJabberConfigurationViewController.m
//  Softphone
//
//  Created by Alex Gotev on 28/01/15.
//  Copyright (c) 2015 voismart. All rights reserved.
//

#import "VSJabberConfigurationViewController.h"
#import "JabberConfigurationForm.h"
#import "VSConnectionService.h"
#import "MBProgressHUD.h"
#import "VSUtility.h"

@interface VSJabberConfigurationViewController ()

@end

@implementation VSJabberConfigurationViewController

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        //set up form
        self.formController.form = [[JabberConfigurationForm alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"JABBER_SETTINGS", nil);
}

- (void)awakeFromNib
{
    //set up form
    self.formController.form = [[JabberConfigurationForm alloc] init];
}

- (void)saveAndApply:(UITableViewCell<FXFormFieldCell> *)cell
{
    JabberConfigurationForm *cfgForm = cell.field.form;
    
    if (cfgForm.jabberID == nil || [cfgForm.jabberID length] == 0) {
        [VSUtility showMessageDialogWithLocalizedTitle:@"WARNING"
                                   andLocalizedMessage:@"JABBERID_ERROR"];
        return;
    }
    
    if (cfgForm.resourceName == nil || [cfgForm.resourceName length] == 0) {
        [VSUtility showMessageDialogWithLocalizedTitle:@"WARNING"
                                   andLocalizedMessage:@"RESOURCE_ERROR"];
        return;
    }
    
    if (cfgForm.priority < 0 || cfgForm.priority > 127) {
        [VSUtility showMessageDialogWithLocalizedTitle:@"WARNING"
                                   andLocalizedMessage:@"PRIORITY_ERROR"];
        return;
    }
    
    VSXmppAccountConfig *xmppConfig = [VSConfiguration sharedInstance].xmppConfig;
    
    xmppConfig.account = cfgForm.jabberID;
    xmppConfig.password = cfgForm.password;
    xmppConfig.resourceName = cfgForm.resourceName;
    xmppConfig.server = cfgForm.server;
    xmppConfig.port = cfgForm.port;
    xmppConfig.priority = cfgForm.priority;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[VSConfiguration sharedInstance] updateAndSaveXmppConfig:xmppConfig];
    [[VSConnectionService sharedInstance] restartAllServices];  
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
