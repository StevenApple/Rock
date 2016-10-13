//
//  VSChatViewController.m
//  Softphone
//
//  Created by Alex Gotev on 22/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import "VSChatViewController.h"
#import "VSTabBarViewController.h"
#import "AppDelegate.h"
#import "VSXmppService.h"
#import "VSConfiguration.h"
#import "VSChatNotifications.h"
#import "Message+Persistence.h"
#import "TAMessageTableViewCell.h"
#import "VSUserExtensionsRetriever.h"
#import "VSUtility.h"

#import <CoreData/CoreData.h>

#pragma mark - Class -

@interface VSChatViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (assign, nonatomic) BOOL appearedAtLeastOneTime;
@property (strong, nonatomic) VSUserExtensionsRetriever *extensionsRetriever;

@end

@implementation VSChatViewController

- (VSUserExtensionsRetriever *)extensionsRetriever
{
    if (_extensionsRetriever == nil) {
        _extensionsRetriever = [[VSUserExtensionsRetriever alloc]
                                initWithWebServices:[[[VSConfiguration sharedInstance] accountConfig] getWebServicesInstance]];
    }
    
    return _extensionsRetriever;
}

#pragma mark - Utility methods -

- (void)scrollToLastMessageAnimated:(BOOL)animated {
    
    NSUInteger numberOfRows = ((id<NSFetchedResultsSectionInfo>) self.fetchedResultsController.sections[0]).numberOfObjects;
    
    if (numberOfRows > 0) {
        NSIndexPath *lastMessageIndexPath = [NSIndexPath indexPathForRow:(numberOfRows - 1) inSection:0];
        [self.tableView scrollToRowAtIndexPath:lastMessageIndexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animated];
    }
}

#pragma mark - Keyboard notifications -

- (void)keyboardDidShow:(NSNotification *)notification {
    
    [self scrollToLastMessageAnimated:YES];
}

#pragma mark - View lifecycle -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        // Visto che nell'animazione della tastiera ho bisogno di tutta la corsa nascondo la tab bar
        self.hidesBottomBarWhenPushed = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    if (self.otherUser == nil) return;
    
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    self.title = self.otherUser.displayName;
    
    UIBarButtonItem *callButton = [[UIBarButtonItem alloc]
                                   initWithImage:[UIImage imageNamed:@"TabIcon-Telephone.png"]
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(userTappedOnCallContact:)];
    self.navigationItem.rightBarButtonItem = callButton;
    
    [self setupFetchedResultsController];
    
    [self fetchResultsFromCoreDataAndLogIfAnErrorOccurs];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}

- (void) setupFetchedResultsController
{
    NSManagedObjectContext *context = [[VSXmppService sharedInstance] getMessagesContext];
    
    NSFetchRequest *request = [Message getFetchRequestForMessagesExchangedWith:self.otherUser.jid.bare
                                                                   withContext:context];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:request
                                     managedObjectContext:context
                                     sectionNameKeyPath:nil
                                     cacheName:nil];
    self.fetchedResultsController.delegate = self;
}

- (void) fetchResultsFromCoreDataAndLogIfAnErrorOccurs
{
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MESSAGES_LOADING_ERROR", nil), self.otherUser.jid.bare, error.localizedFailureReason];
        [VSUtility showMessageDialogWithTitle:NSLocalizedString(@"ERROR", nil) andMessage:message];
    }
}

- (void)userTappedOnCallContact:(id)sender
{
    [self.extensionsRetriever retrieveExtensionsForUsername:self.otherUser.jid.bare
                                                  withAlias:self.otherUser.displayName inViewController:self];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (!self.appearedAtLeastOneTime) {
        [self.tableView reloadData];
        [self scrollToLastMessageAnimated:NO];
        self.appearedAtLeastOneTime = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (self.otherUser == nil) return;
    
    [[VSChatNotifications sharedInstance] clearUnreadMessagesFromUser:self.otherUser.jid.bare];
    [(VSTabBarViewController *)self.tabBarController updateUnreadXMPPMessages];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if (self.otherUser == nil) return;
    
    [[VSChatNotifications sharedInstance] clearUnreadMessagesFromUser:self.otherUser.jid.bare];
    [(VSTabBarViewController *)self.tabBarController updateUnreadXMPPMessages];
}

#pragma mark - TableView data source -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.fetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *sections = self.fetchedResultsController.sections;
    
    if (section < [sections count]) {
        
        id<NSFetchedResultsSectionInfo> sectionInfo = sections[section];
        return sectionInfo.numberOfObjects;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TAMessageTableViewCell *cell;
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([message isIncomingMessage]) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellBubbleLeft" forIndexPath:indexPath];
        [cell setBubbleImageNamed:@"TAMessageTableViewCellBackgroundClear" andStyle:TAMessageStyleLeft];
    }
    else {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellBubbleRight" forIndexPath:indexPath];
        [cell setBubbleImageNamed:@"TAMessageTableViewCellBackgroundGreen" andStyle:TAMessageStyleRight];
    }
    
    [cell setMessageText:message.message withDate:[self dateStringFromTimestamp:message.timestamp]];
    return cell;
}

- (NSString *)dateStringFromTimestamp:(NSNumber *)timestamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    if ([self isDateTodayDate:date]) {
        [formatter setDateStyle:NSDateFormatterNoStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    } else {
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    }
    
    return [formatter stringFromDate:date];
}

- (BOOL)isDateTodayDate:(NSDate *)aDate {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:aDate];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    return [today isEqualToDate:otherDate];
}

#pragma mark - TableView delegate -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return [TAMessageTableViewCell requiredCellHeightForText:message.message];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        
        UIView *clearView = [[UIView alloc] init];
        clearView.backgroundColor = [UIColor clearColor];
        
        return clearView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    // Giusto per lasciare un po' di respiro all'inizio
    return (section == 0 ? 5 : 0);
}

#pragma mark - FetchedResults delegate -

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (type != NSFetchedResultsChangeInsert || !newIndexPath) return;
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - TextField delegate -

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (!textField.text || [textField.text length] == 0) return NO;
    
    // Send message and save it into the database
    [[VSXmppService sharedInstance] sendMessage:textField.text to:self.otherUser.jid.bare];
    
    [Message insertOutgoingMessage:textField.text
                        toJabberId:self.otherUser.jid.bare
                       withContext:[[VSXmppService sharedInstance] getMessagesContext]];
    
    [[VSXmppService sharedInstance] playSentMessageTone];
    
    textField.text = nil;
    
    // Return NO to not lose the focus
    return NO;
}

@end
