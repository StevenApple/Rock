//
//  VSSearchContactsViewControllerTableViewController.m
//  Softphone
//
//  Created by Alex Gotev on 22/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import "VSSearchContactsViewController.h"
#import "VSContactDetailsViewController.h"
#import "VoiSmartWebServicesFactory.h"
#import "VSConfiguration.h"
#import "VSLoadContactsPage.h"
#import "MBProgressHUD.h"

#define CONTACT_AVATAR 100
#define CONTACT_FULL_NAME 200
#define CONTACT_ORGANIZATION 300

@interface VSSearchContactsViewController () <UISearchDisplayDelegate, UITableViewDataSource, VSLoadContactsPageDelegate>

@property (strong, nonatomic) VSLoadContactsPage *contactsLoader;
@property (strong, nonatomic) NSMutableArray *loadedContacts;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSString *searchTerm;
@property (strong, nonatomic) UIImage *defaultAvatar;
@property (strong, nonatomic) VSContact *contactToShow;

@end

@implementation VSSearchContactsViewController

- (VSLoadContactsPage *)contactsLoader
{
    if (_contactsLoader == nil) {
        _contactsLoader = [[VSLoadContactsPage alloc]
                           initWithWebServices:[[[VSConfiguration sharedInstance] accountConfig] getWebServicesInstance]];
    }
    
    return _contactsLoader;
}

- (NSMutableArray *)loadedContacts
{
    if (_loadedContacts == nil) {
        _loadedContacts = [NSMutableArray arrayWithCapacity:25];
    }
    
    return _loadedContacts;
}

- (UIImage *)defaultAvatar
{
    if (_defaultAvatar == nil) {
        _defaultAvatar = [UIImage imageNamed:@"Icon-User.png"];
    }
    
    return _defaultAvatar;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"CONTACTS", nil);
    
    [self.tableView setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"SEARCH_RESULTS", nil);
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.loadedContacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    
    UIImageView *avatar = (UIImageView *)[cell viewWithTag:CONTACT_AVATAR];
    UILabel *fullName = (UILabel *)[cell viewWithTag:CONTACT_FULL_NAME];
    UILabel *organization = (UILabel *)[cell viewWithTag:CONTACT_ORGANIZATION];
    
    VSContact *contact = (VSContact *)[self.loadedContacts objectAtIndex:indexPath.row];
    
    if (contact.image) {
        avatar.image = contact.image;
    } else {
        avatar.image = self.defaultAvatar;
    }
    
    fullName.text = [NSString stringWithFormat:@"%@ %@", contact.name, contact.surname];
    organization.text = contact.company;
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.contactToShow = [self.loadedContacts objectAtIndex:indexPath.row];
    return indexPath;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    self.searchTerm = searchString;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                              target:self
                                            selector:@selector(performSearch:)
                                            userInfo:nil
                                             repeats:NO];
    
    return NO;
}

- (void)performSearch:(NSTimer *)timer
{
    [MBProgressHUD showHUDAddedTo:self.searchDisplayController.searchResultsTableView
                         animated:YES];
    
    [self.contactsLoader loadContactsPageWithSearchTerm:self.searchTerm
                                             pageToLoad:1
                                         entriesPerPage:40
                                               delegate:self];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self.tableView reloadData];
}

- (void)receivedContacts:(NSArray *)contacts
{
    [MBProgressHUD hideAllHUDsForView:self.searchDisplayController.searchResultsTableView
                             animated:YES];
    
    [self.loadedContacts removeAllObjects];
    [self.loadedContacts addObjectsFromArray:contacts];
    
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)loadingOfContactsEncounteredAnError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.searchDisplayController.searchResultsTableView
                             animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    VSContactDetailsViewController *details = segue.destinationViewController;
    details.contactToShow = self.contactToShow;
}

@end
