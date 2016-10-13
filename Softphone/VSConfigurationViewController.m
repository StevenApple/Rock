//
//  VSConfigurationViewController.m
//  Softphone
//
//  Created by Alex Gotev on 17/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import "VSConfigurationViewController.h"
#import "ConfigurationForm.h"
#import "MBProgressHUD.h"
#import "VSConnectionService.h"
#import "AppDelegate.h"
#import "VSNetworkTestTableViewController.h"
#import "VSUtility.h"
#import "VSSipConfigurationViewController.h"
#import "VSJabberConfigurationViewController.h"


@interface VSConfigurationViewController ()

@end

@implementation VSConfigurationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"SETTINGS", nil);
}

- (void)awakeFromNib
{
    //set up form
    self.formController.form = [[ConfigurationForm alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveAndApply:(UITableViewCell<FXFormFieldCell> *)cell
{
    ConfigurationForm *cfgForm = cell.field.form;
    
    if ([cfgForm.address length] == 0) {
        [VSUtility showMessageDialogWithLocalizedTitle:@"WARNING"
                                   andLocalizedMessage:@"PROVIDE_PBX_ADDRESS"];
        return;
    }
    
    if ([cfgForm.username length] == 0) {
        [VSUtility showMessageDialogWithLocalizedTitle:@"WARNING"
                                   andLocalizedMessage:@"PROVIDE_USERNAME"];
        return;
    }
    
    if ([cfgForm.password length] == 0) {
        [VSUtility showMessageDialogWithLocalizedTitle:@"WARNING"
                                   andLocalizedMessage:@"PROVIDE_PASSWORD"];
        return;
    }
    
    if (cfgForm.myPhoneNumber != nil) {
        if (![VSUtility isNumber:cfgForm.myPhoneNumber]) {
            [VSUtility showMessageDialogWithLocalizedTitle:@"WARNING"
                                       andLocalizedMessage:@"PROVIDE_VALID_TEL_NUMBER"];
            return;
        }
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //Update and save Account configuration
    VSAccountConfig *newCfg = [[VSAccountConfig alloc] init];
    newCfg.pbxAddress = cfgForm.address;
    newCfg.orchestraVersion = cfgForm.version;
    newCfg.username = cfgForm.username;
    newCfg.password = cfgForm.password;
    newCfg.registerSip = cfgForm.telephoneOnWifi;
    newCfg.registerSipVia3G = cfgForm.telephoneOn3G;
    newCfg.registerXmpp = cfgForm.messagesOnWifi;
    newCfg.registerXmppVia3G = cfgForm.messagesOn3G;
    newCfg.myPhoneNumber = cfgForm.myPhoneNumber;
    newCfg.defaultCallType = cfgForm.defaultCallType;
    
    [[VSConfiguration sharedInstance] updateAndSaveAccountConfig:newCfg];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //Setup reachability host
    //The callbacks of the reachability receiver implements the automatic reconnection or shutdown
    //based on user preferences
    [app setReachabilityHost:newCfg.pbxAddress];
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)reset:(UITableViewCell<FXFormFieldCell> *)cell
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RESET_ACCOUNT", nil)
                                                    message:NSLocalizedString(@"RESET_ACCOUNT_CONFIRMATION", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                          otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
    [alert show];
}

- (void)sipSettings:(UITableViewCell<FXFormFieldCell> *)cell
{
    if (![[VSConfiguration sharedInstance].accountConfig isDefined]) {
        [VSUtility showMessageDialogWithLocalizedTitle:@"WARNING"
                                   andLocalizedMessage:@"NO_CONFIGURED_ACCOUNT"];
        return;
    }
    
    if (![[VSConfiguration sharedInstance].sipConfig isDefined]) {
        [VSUtility showMessageDialogWithLocalizedTitle:@"WARNING"
                                   andLocalizedMessage:@"NO_CONFIGURED_SIP_OR_XMPP"];
        return;
    }

    VSSipConfigurationViewController *sipConfig = [[VSSipConfigurationViewController alloc] init];
    
    [self.navigationController pushViewController:sipConfig animated:YES];
}

- (void)jabberSettings:(UITableViewCell<FXFormFieldCell> *)cell
{
    if (![[VSConfiguration sharedInstance].accountConfig isDefined]) {
        [VSUtility showMessageDialogWithLocalizedTitle:@"WARNING"
                                   andLocalizedMessage:@"NO_CONFIGURED_ACCOUNT"];
        return;
    }
    
    if (![[VSConfiguration sharedInstance].xmppConfig isDefined]) {
        [VSUtility showMessageDialogWithLocalizedTitle:@"WARNING"
                                   andLocalizedMessage:@"NO_CONFIGURED_SIP_OR_XMPP"];
        return;
    }
    
    VSJabberConfigurationViewController *jabberConfig = [[VSJabberConfigurationViewController alloc] init];
    
    [self.navigationController pushViewController:jabberConfig animated:YES];
}

- (void)networkTest:(UITableViewCell<FXFormFieldCell> *)cell
{
    if (![[VSConfiguration sharedInstance].accountConfig isDefined]) {
        [VSUtility showMessageDialogWithLocalizedTitle:@"WARNING"
                                   andLocalizedMessage:@"NO_CONFIGURED_ACCOUNT"];
        return;
    }
    
    if (![[VSConfiguration sharedInstance].sipConfig isDefined] || ![[VSConfiguration sharedInstance].xmppConfig isDefined]) {
        [VSUtility showMessageDialogWithLocalizedTitle:@"WARNING"
                                   andLocalizedMessage:@"NO_CONFIGURED_SIP_OR_XMPP"];
        return;
    }

    VSNetworkTestTableViewController *networkTest = (VSNetworkTestTableViewController *)
                                                    [VSUtility getViewControllerWithIdentifier:@"NetworkTest"
                                                                            fromStorybordNamed:@"Main"];
    
    [self.navigationController pushViewController:networkTest animated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[VSConfiguration sharedInstance] resetAll];
        [[VSConnectionService sharedInstance] stopAllServices];
        
        //reload form fields
        self.formController.form = [[ConfigurationForm alloc] init];
        
        //reload table
        [self.formController.tableView reloadData];
    }
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
