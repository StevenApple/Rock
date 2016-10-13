//
//  VSPaginatedTableViewController.m
//  Softphone
//
//  Created by Alex Gotev on 19/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import "VSPaginatedTableViewController.h"
#import "VSUtility.h"

static NSInteger const VS_PAGINATED_TABLE_VIEW_LOADING_CELL = 1234;

typedef  NS_ENUM(NSInteger, VSPaginatedTableViewControllerFetchingStatus) {
    VS_PAGINATED_TVC_READY,
    VS_PAGINATED_TVC_LOADING
};

@interface VSPaginatedTableViewController ()

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) id<VSPaginatedTableViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *fetchedItems;
@property (nonatomic, assign) VSPaginatedTableViewControllerFetchingStatus status;
@property (nonatomic, assign) BOOL hideLoadingCell;

@end

@implementation VSPaginatedTableViewController

- (NSMutableArray *)fetchedItems
{
    if (_fetchedItems == nil) {
        _fetchedItems = [[NSMutableArray alloc] initWithCapacity:25];
    }
    
    return _fetchedItems;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init]; //swipe down to refresh
    [self.refreshControl addTarget:self
                            action:@selector(userSwipedDownToRefreshFirstPage)
                  forControlEvents:UIControlEventValueChanged];
    
    _currentPage = 0;
    _status = VS_PAGINATED_TVC_READY;
    _hideLoadingCell = NO;
    [_fetchedItems removeAllObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.autoReloadDataOnStart) {
        [self.refreshControl beginRefreshing];
        [self userSwipedDownToRefreshFirstPage];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
        return [self.fetchedItems count];
    else {
        return (self.hideLoadingCell ? 0 : 1);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        cell = [self.delegate tableView:tableView
                getCustomCellForElement:[self.fetchedItems objectAtIndex:indexPath.row]
                            atIndexPath:indexPath];
    } else {
        cell = [self loadingCell];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && self.status == VS_PAGINATED_TVC_READY) {
        [self loadNextPage];
    } else if (indexPath.section == 0 && indexPath.row == ([self.fetchedItems count] - 1)) {
        self.hideLoadingCell = NO;
    }
}

- (void) userSwipedDownToRefreshFirstPage
{
    if (self.status == VS_PAGINATED_TVC_READY) {
        _currentPage = 0; //whatever the page was, I need to reload the first one
        [self loadNextPage];
    } else {
        [self.refreshControl endRefreshing];
    }
}

- (void) loadNextPage
{
    _currentPage++;
    _status = VS_PAGINATED_TVC_LOADING;
    [self.delegate startFetchingItemsForPage:_currentPage];
}

//Create a new cell that displays a loading spinner
- (UITableViewCell *)loadingCell
{
    UITableViewCell *cell = [[UITableViewCell alloc]
                             initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.tag = VS_PAGINATED_TABLE_VIEW_LOADING_CELL;
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]
                                                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;

    [cell.contentView addSubview:activityIndicator];
    
    // Center horizontally
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:cell.contentView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    // Center vertically
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:cell.contentView
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [cell.contentView setNeedsLayout];
    
    [activityIndicator startAnimating];
    
    return cell;
}

- (void)setDelegate:(id<VSPaginatedTableViewControllerDelegate>)delegate
{
    _delegate = delegate;
}

- (void)finishedFetchingItems:(NSArray *)fetchedItems
                    withError:(BOOL)error
            errorMessageTitle:(NSString *)errorTitle
             errorMessageText:(NSString *)errorText
{
    _status = VS_PAGINATED_TVC_READY;
    [self.refreshControl endRefreshing]; //if user swiped down to refresh data, hide loading spinner
    self.hideLoadingCell = YES;
    
    if (error) {
        [VSUtility showMessageDialogWithTitle:errorTitle andMessage:errorText];
        
    } else if (fetchedItems != nil && [fetchedItems count] > 0) {
        if (_currentPage == 1) {
            [self.fetchedItems removeAllObjects]; //empty the array holding fetched items
        }
        
        [self.fetchedItems addObjectsFromArray:fetchedItems];
        self.hideLoadingCell = NO;
        
    }
    
    if (_currentPage == 1) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.tableView reloadData];
    }
}

@end
