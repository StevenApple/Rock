//
//  VSMessagesViewController.m
//  Softphone
//
//  Created by Alex Gotev on 22/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import "VSMessagesViewController.h"

#import <CoreData/CoreData.h>
#import "VSChatViewController.h"
#import "VSTabBarViewController.h"
#import "VSChatListCell.h"
#import "AppDelegate.h"
#import "VSXmppService.h"
#import "VSChatNotifications.h"
#import "VSConfiguration.h"
#import "VSUserExtensionsRetriever.h"
#import "VSUtility.h"

#pragma mark - Class -

@interface VSMessagesViewController () <XMPPRosterMemoryStorageDelegate, UIAlertViewDelegate, VSChatListCellDelegate>

@property (strong, nonatomic) NSArray *allUsers;
@property (strong, nonatomic) NSMutableArray *onlineUsers;
@property (strong, nonatomic) NSMutableArray *offlineUsers;
@property (strong, nonatomic) VSUserExtensionsRetriever *extensionsRetriever;

@end

@implementation VSMessagesViewController

- (VSUserExtensionsRetriever *)extensionsRetriever
{
    if (_extensionsRetriever == nil) {
        _extensionsRetriever = [[VSUserExtensionsRetriever alloc]
                                initWithWebServices:[[[VSConfiguration sharedInstance] accountConfig] getWebServicesInstance]];
    }
    
    return _extensionsRetriever;
}

#pragma mark - Actions -
- (IBAction)plusButtonPressed:(id)sender {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ADD", nil)
                                                            message:NSLocalizedString(@"ADD_JABBERID_TEXT", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                                  otherButtonTitles:NSLocalizedString(@"ADD", nil), nil];
        
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
        
        return;
}

#pragma mark - Utility methods -

- (void) receivedIncomingMessage:(NSNotification *)notification
{
    [self updateUnreadXMPPMessages];
}

- (void)updateUnreadXMPPMessages {
    for (NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]) {
        
        VSChatListCell *cell = (VSChatListCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        XMPPUserMemoryStorageObject *user = (indexPath.section == 0 ?
                                             self.onlineUsers[indexPath.row] :
                                             self.offlineUsers[indexPath.row]);
        
        [self checkUnreadMessagesFromUser:user.jid.bare inCell:cell];
    }
    
    [(VSTabBarViewController *)self.tabBarController updateUnreadXMPPMessages];
}

#pragma mark - View lifecycle -

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.onlineUsers   = [[NSMutableArray alloc] initWithCapacity:10];
    self.offlineUsers  = [[NSMutableArray alloc] initWithCapacity:10];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedIncomingMessage:)
                                                 name:NOTIFICATION_NAME_INCOMING_MESSAGE
                                               object:nil];
    
    [self xmppRosterDidChange:[[VSXmppService sharedInstance] rosterStorage]];
    [[VSXmppService sharedInstance] setRosterMemoryStorageDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self xmppRosterDidChange:[[VSXmppService sharedInstance] rosterStorage]];
    [[VSXmppService sharedInstance] setRosterMemoryStorageDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[VSXmppService sharedInstance] removeRosterMemoryStorageDelegate:self];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    
    // Mi tolgo dalla coda delle notifiche
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableView datasource -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSString *)tableView:(UITableView *)sender
titleForHeaderInSection:(NSInteger)sectionIndex {
    
    return (sectionIndex == 0 ? NSLocalizedString(@"ONLINE", nil) : NSLocalizedString(@"OFFLINE", nil));
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)sectionIndex {
    
    return (sectionIndex == 0 ? [self.onlineUsers count] : [self.offlineUsers count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VSChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatListRow"];
    XMPPUserMemoryStorageObject *user = (indexPath.section == 0 ?
                                         self.onlineUsers[indexPath.row] :
                                         self.offlineUsers[indexPath.row]);
    
    cell.delegate = self;
    cell.userJabberId = user.jid.bare;
    cell.contactName.text = user.displayName;
    cell.contactStatusMessage.text = [[user.primaryResource presence] status];
    
    UIImage *avatarImage;
    if (user.photo != nil) {
        avatarImage = user.photo;
    } else {
        avatarImage = [[VSXmppService sharedInstance] getAvatarForJabberID:user.jid];
    }
    cell.contactAvatar.image = avatarImage;
    
    if (user.isOnline) {
        switch ([[user.primaryResource presence] intShow]) {
            case 0: //do not disturb
                cell.contactOnlineStatusIndicator.backgroundColor = [UIColor redColor];
                break;
                
            case 1: //extended away
                cell.contactOnlineStatusIndicator.backgroundColor = [UIColor orangeColor];
                break;
                
            case 2: //away
                cell.contactOnlineStatusIndicator.backgroundColor = [UIColor yellowColor];
                break;
                
            default: //available or free to chat
                cell.contactOnlineStatusIndicator.backgroundColor = [UIColor greenColor];
                break;
        }
    } else {
        cell.contactOnlineStatusIndicator.backgroundColor = [UIColor grayColor];
    }
    
    [self checkUnreadMessagesFromUser:user.jid.bare inCell:cell];
    
    return cell;
}

- (void) userTappedOnCallContact:(VSChatListCell *)contactCell
{
    [self.extensionsRetriever retrieveExtensionsForUsername:contactCell.userJabberId
                                                  withAlias:contactCell.contactName.text
                                           inViewController:self];
}

- (void) checkUnreadMessagesFromUser:(NSString *)jabberID
                              inCell:(VSChatListCell *)cell
{
    if ([[VSChatNotifications sharedInstance] getNumberOfUnreadMessagesFromUser:jabberID] > 0) {
        cell.unreadMessagesIndicator.hidden = NO;
    } else {
        cell.unreadMessagesIndicator.hidden = YES;
    }
}

#pragma mark - UITableView delegate -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *users = (indexPath.section == 0 ? self.onlineUsers : self.offlineUsers);

    VSChatViewController *chatViewController = (VSChatViewController *)[VSUtility getViewControllerWithIdentifier:@"ChatMessagesController"
                                                                       fromStorybordNamed:@"Main"];
    chatViewController.otherUser = users[indexPath.row];
    [[VSChatNotifications sharedInstance] clearUnreadMessagesFromUser:[[users[indexPath.row] jid] bare]];
    
    UINavigationController *detailViewController = (UINavigationController *)[self.splitViewController.viewControllers lastObject];
    [detailViewController popViewControllerAnimated:NO];
    [detailViewController pushViewController:chatViewController animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        XMPPUserMemoryStorageObject *user = (indexPath.section == 0 ? self.onlineUsers[indexPath.row] : self.offlineUsers[indexPath.row]);
        [[VSXmppService sharedInstance] deleteContactWithJabberId:user.jid];
    }
}

#pragma mark - UIAlertView delegate -

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        NSString *username = [alertView textFieldAtIndex:0].text;
        
        if (!username)
            return;
        
        NSRange atRange = [username rangeOfString:@"@"];
        
        if (atRange.location == NSNotFound)
            username = [username stringByAppendingFormat:@"@%@", [VSConfiguration sharedInstance].xmppConfig.account];
        
        [[VSXmppService sharedInstance] addContactWithJabberId:username
                                                         alias:username
                                                      andGroup:nil];
    }
}

#pragma mark - XMPPRosterMemoryStorage delegate -

- (void)xmppRosterDidChange:(XMPPRosterMemoryStorage *)rosterStorage {
    
    @synchronized(self) {
        
        self.allUsers = [rosterStorage unsortedUsers];
        [self.onlineUsers removeAllObjects];
        [self.offlineUsers removeAllObjects];
        
        for (XMPPUserMemoryStorageObject *user in self.allUsers) {
            
            if ([user.allResources count] == 0)
                [self.offlineUsers addObject:user];
            else
                [self.onlineUsers addObject:user];
        }
        
        self.onlineUsers = [[self.onlineUsers sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            XMPPUserMemoryStorageObject *userA = (XMPPUserMemoryStorageObject *)obj1;
            XMPPUserMemoryStorageObject *userB = (XMPPUserMemoryStorageObject *)obj2;
            
            NSComparisonResult result;
            
            int availabilityA = [[userA.primaryResource presence] intShow];
            int availabilityB = [[userB.primaryResource presence] intShow];
            
            if (availabilityA < availabilityB) {
                result = NSOrderedDescending;
            } else if (availabilityA > availabilityB) {
                result = NSOrderedAscending;
            } else {
                result = [userA compareByName:userB];
            }
            
            return result;
            
        }] mutableCopy];
        
        [self.tableView reloadData];
    }
}

@end
