//
//  VSPaginatedTableViewController.h
//  Softphone
//
//  Created by Alex Gotev on 19/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VSPaginatedTableViewControllerDelegate <NSObject>

- (UITableViewCell *)tableView:(UITableView *)tableView
       getCustomCellForElement:(NSObject *)element
                   atIndexPath:(NSIndexPath *)indexPath;

- (void)startFetchingItemsForPage:(NSInteger)page;

@end

@interface VSPaginatedTableViewController : UITableViewController

@property (nonatomic, assign) BOOL autoReloadDataOnStart;

- (void)setDelegate:(id<VSPaginatedTableViewControllerDelegate>)delegate;
- (void)finishedFetchingItems:(NSArray *)fetchedItems
                    withError:(BOOL)error
            errorMessageTitle:(NSString *)errorTitle
             errorMessageText:(NSString *)errorText;

@end
