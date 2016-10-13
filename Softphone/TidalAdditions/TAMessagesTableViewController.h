//
//  TAMessagesTableViewController.h
//
//  Created by Tidal ArtWorks on 19/02/13.
//  Copyright (c) 2013 Tidal ArtWorks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAInsetsTextField.h"

#pragma mark - Class -

@interface TAMessagesTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

{} // Only here to avoid problem in XCode navigator

#pragma mark - Properties -

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) TAInsetsTextField *textField;

@end
