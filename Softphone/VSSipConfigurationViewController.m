//
//  VSSipConfigurationViewController.m
//  Softphone
//
//  Created by Alex Gotev on 28/01/15.
//  Copyright (c) 2015 voismart. All rights reserved.
//

#import "VSSipConfigurationViewController.h"
#import "SipConfigurationForm.h"
#import "VSConfiguration.h"
#import "MBProgressHUD.h"
#import "VSConnectionService.h"

@interface VSSipConfigurationViewController ()

@end

@implementation VSSipConfigurationViewController

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        //set up form
        self.formController.form = [[SipConfigurationForm alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"SIP_SETTINGS", nil);
}

- (void)awakeFromNib
{
    //set up form
    self.formController.form = [[SipConfigurationForm alloc] init];
}

- (void)saveAndApply:(UITableViewCell<FXFormFieldCell> *)cell
{
    SipConfigurationForm *cfgForm = cell.field.form;
    
    VSPersistentSipAccountConfig *sipConfig = [VSConfiguration sharedInstance].sipConfig;
    
    sipConfig.privateId = cfgForm.extension;
    sipConfig.password = cfgForm.password;
    sipConfig.host = cfgForm.host;
    sipConfig.realm = cfgForm.realm;
    sipConfig.port = cfgForm.port <= 0 ? 5060 : cfgForm.port;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[VSConfiguration sharedInstance] updateAndSaveSipConfig:sipConfig];
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
