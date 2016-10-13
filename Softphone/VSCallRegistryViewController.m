//
//  VSCallRegistryViewController.m
//  Softphone
//
//  Created by Alex Gotev on 19/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import "VSCallRegistryViewController.h"
#import "VSTableViewRecentsCell.h"
#import "VSConfiguration.h"
#import "VSUtility.h"
#import "NSDate-Utilities.h"

#define DEFAULT_CALL_REGISTRY_ITEM_SIZE 25

@interface VSCallRegistryViewController()

@property (nonatomic, assign) int page;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *hourMinuteFormatter;

@end

@implementation VSCallRegistryViewController

#pragma mark - Properties


#pragma mark - Data fetching

- (NSDateFormatter *)dateFormatter
{
    
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    }
    
    return _dateFormatter;
}

- (NSDateFormatter *)hourMinuteFormatter
{
    if (_hourMinuteFormatter == nil) {
        _hourMinuteFormatter = [[NSDateFormatter alloc] init];
        [_hourMinuteFormatter setDateFormat:@"HH:mm"];
    }
    
    return _hourMinuteFormatter;
}

- (void)startFetchingItemsForPage:(NSInteger)page
{
    self.page = (int)page;
    
    VSAccountConfig *accountConfig = [VSConfiguration sharedInstance].accountConfig;
    
    if (![accountConfig isDefined]) {
        [super finishedFetchingItems:nil
                           withError:YES
                   errorMessageTitle:NSLocalizedString(@"WARNING", nil)
                    errorMessageText:NSLocalizedString(@"NO_ACCOUNT", nil)];
    } else {
        id<VoiSmartWebServices> webServices = [accountConfig getWebServicesInstance];
        [webServices getLicenseAndSendResponseToDelegate:self];
    }
}

- (void)receivedLicenseIsValid:(BOOL)valid
           withWebServiceToken:(NSString *)webServiceToken
                         error:(NSError *)error
{
    if (valid) {
        id<VoiSmartWebServices> webServices = [[VSConfiguration sharedInstance].accountConfig getWebServicesInstance];
        
        [webServices getCallsWithToken:webServiceToken
                              username:[VSConfiguration sharedInstance].accountConfig.username
                                  page:self.page
                        entriesPerPage:DEFAULT_CALL_REGISTRY_ITEM_SIZE
                              delegate:self];
    } else {
        [super finishedFetchingItems:nil
                           withError:YES
                   errorMessageTitle:NSLocalizedString(@"ERROR", nil)
                    errorMessageText:NSLocalizedString(@"LOGIN_ERROR", nil)];
    }
}

- (void)receivedCalls:(NSArray *)calls
                error:(NSError *)error
{
    [super finishedFetchingItems:calls
                       withError:NO
               errorMessageTitle:NSLocalizedString(@"ERROR", nil)
                errorMessageText:NSLocalizedString(@"RECENTS_LOADING_ERROR", nil)];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"RECENTS", nil);
    [super setDelegate:self];
    self.autoReloadDataOnStart = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView
       getCustomCellForElement:(NSObject *)element
                   atIndexPath:(NSIndexPath *)indexPath
{
    VSCallRegistryItem *item = (VSCallRegistryItem *)element;
    
    VSTableViewRecentsCell *cell = [self getCellForCallType:item.callType
                                                inTableView:tableView
                                               forIndexPath:indexPath];
    
    cell.titleLabel.text = item.number;
    
    NSDate *eventDate = item.endTime;
    
    if ([eventDate isEqualToDateIgnoringTime:[NSDate date]])
        cell.detailLabel.text = [self.hourMinuteFormatter stringFromDate:eventDate];
    else
        cell.detailLabel.text = [self.dateFormatter stringFromDate:eventDate];
    
    return cell;
}

- (VSTableViewRecentsCell *)getCellForCallType:(VSCallType)callType
                                   inTableView:(UITableView *)tableView
                                  forIndexPath:(NSIndexPath *)indexPath
{
    VSTableViewRecentsCell *cell = nil;
    
    switch (callType) {
            
        case INCOMING: {
            cell = (VSTableViewRecentsCell *)[tableView dequeueReusableCellWithIdentifier:@"CellIncoming"
                                                                             forIndexPath:indexPath];
            cell.subtitleLabel.text = NSLocalizedString(@"INCOMING_CALL_TYPE", nil);
            cell.subtitleLabel.textColor = [UIColor grayColor];
            cell.titleLabel.textColor = [UIColor blackColor];
            break;
        }
            
        case OUTGOING: {
            cell = (VSTableViewRecentsCell *)[tableView dequeueReusableCellWithIdentifier:@"CellOutgoing"
                                                                             forIndexPath:indexPath];
            cell.subtitleLabel.text = NSLocalizedString(@"OUTGOING_CALL_TYPE", nil);
            cell.subtitleLabel.textColor = [UIColor grayColor];
            cell.titleLabel.textColor = [UIColor blackColor];
            break;
        }
            
        case MISSED: {
            cell = (VSTableViewRecentsCell *)[tableView dequeueReusableCellWithIdentifier:@"CellMissed"
                                                                             forIndexPath:indexPath];
            cell.subtitleLabel.text = NSLocalizedString(@"MISSED_CALL_TYPE", nil);
            cell.subtitleLabel.textColor = [UIColor redColor];
            cell.titleLabel.textColor = [UIColor redColor];
            break;
        }
            
        default: {
            
            break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VSTableViewRecentsCell *cell = (VSTableViewRecentsCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    [VSUtility makeCallTo:cell.titleLabel.text];
}

@end
