//
//  VSChatMasterDetailViewController.m
//  Softphone
//
//  Created by Alex Gotev on 27/01/15.
//  Copyright (c) 2015 voismart. All rights reserved.
//

#import "VSChatMasterDetailViewController.h"

@interface VSChatMasterDetailViewController ()

@end

@implementation VSChatMasterDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    // Do any additional setup after loading the view.
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
collapseSecondaryViewController:(UIViewController *)secondaryViewController
  ontoPrimaryViewController:(UIViewController *)primaryViewController {
    
    //Return YES to always show the master view first on iphone portrait
    return YES;
}

@end
