//
//  VSContactDetailsViewController.h
//  Softphone
//
//  Created by Alex Gotev on 22/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSContact.h"

@interface VSContactDetailsViewController : UITableViewController

@property (weak, nonatomic) VSContact *contactToShow;

@end
