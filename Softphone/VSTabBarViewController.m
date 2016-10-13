//
//  VSTabBarViewController.m
//  Softphone
//
//  Created by Alex Gotev on 22/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import "VSTabBarViewController.h"

@interface VSTabBarViewController ()

@end

@implementation VSTabBarViewController

- (void)updateUnreadXMPPMessages
{
    NSInteger count = [[VSChatNotifications sharedInstance] getTotalUnreadMessages];
    UITabBarItem *tabBarItem = [self.tabBar.items objectAtIndex:0];
    tabBarItem.badgeValue = (count != 0 ? [NSString stringWithFormat:@"%ld", (long)count] : nil);
}

#pragma mark - View lifecycle -

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUnreadXMPPMessages];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationMaskAll;

    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
