//
//  VSSearchTelephoneViewController.m
//  Softphone
//
//  Created by Alex Gotev on 22/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import "VSSearchTelephoneViewController.h"
#import "VoiSmartWebServicesFactory.h"
#import "VSConfiguration.h"
#import "VSLoadContactsPage.h"
#import "MBProgressHUD.h"

@interface VSSearchTelephoneViewController () <UISearchDisplayDelegate, UITableViewDataSource, VSLoadContactsPageDelegate>

@property (strong, nonatomic) VSLoadContactsPage *contactsLoader;
@property (strong, nonatomic) NSMutableArray *loadedTelephoneNumbers;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSString *searchTerm;

@end

@implementation VSSearchTelephoneViewController

- (VSLoadContactsPage *)contactsLoader
{
    if (_contactsLoader == nil) {
        _contactsLoader = [[VSLoadContactsPage alloc]
                           initWithWebServices:[[[VSConfiguration sharedInstance] accountConfig] getWebServicesInstance]];
    }
    
    return _contactsLoader;
}

- (NSMutableArray *)loadedTelephoneNumbers
{
    if (_loadedTelephoneNumbers == nil) {
        _loadedTelephoneNumbers = [NSMutableArray arrayWithCapacity:20];
    }
    
    return _loadedTelephoneNumbers;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"SEARCH_PHONE_NUMBERS", nil);
    
    [self.tableView setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.searchDisplayController.searchBar becomeFirstResponder];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.loadedTelephoneNumbers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TelephoneCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TelephoneCell"];
    }
    
    VSPhoneNumber *phone = [self.loadedTelephoneNumbers objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [phone contactName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@",
                                 [self getPhoneTypeString:phone.phoneType],
                                 [phone phoneNumber]];
    
    return cell;
}

- (NSString *)getPhoneTypeString:(PhoneType)type
{
    NSString *typeString;
    
    switch (type) {
        case FAX:
            typeString = NSLocalizedString(@"FAX", nil);
            break;
            
        case HOME:
            typeString = NSLocalizedString(@"HOME_PHONE", nil);
            break;
            
        case MOBILE:
            typeString = NSLocalizedString(@"MOBILE_PHONE", nil);
            break;
            
        case OFFICE:
            typeString = NSLocalizedString(@"OFFICE_PHONE", nil);
            break;
            
        default:
            typeString = @"";
            break;
    }
    
    return typeString;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:NOTIFICATION_NAME_VSNUMBER_SELECTED
     object:[self.loadedTelephoneNumbers objectAtIndex:[indexPath row]]];
    
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
    
    NSLog(@"Received %lu contacts", (unsigned long)[contacts count]);
    
    [self.loadedTelephoneNumbers removeAllObjects];
    
    for (VSContact *contact in contacts) {
        NSMutableArray *allPhones = [contact getAllPhones];
        
        for (VSPhoneNumber *phone in allPhones) {
            [self.loadedTelephoneNumbers addObject:phone];
        }
    }
    
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)loadingOfContactsEncounteredAnError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.searchDisplayController.searchResultsTableView
                             animated:YES];
}

@end
