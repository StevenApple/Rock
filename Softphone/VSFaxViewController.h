//
//  VSFaxViewController.h
//  Softphone
//
//  Created by Alex on 23/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VSFaxViewController : UITableViewController <UIGestureRecognizerDelegate>

- (void)setSelectedPDFFilePathAndReloadTableView:(NSString *)path;

@end
