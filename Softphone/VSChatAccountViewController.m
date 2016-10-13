//
//  VSChatAccountViewController.m
//  Softphone
//
//  Created by Alex on 23/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import "VSChatAccountViewController.h"
#import "VSConfiguration.h"
#import "VSXmppService.h"
#import "VSUtility.h"

#define AVATAR_CELL_ACCOUNT_LABEL 100
#define AVATAR_CELL_ACCOUNT_IMAGE 200
#define PERSONAL_MESSAGE_TEXT 1000
#define NUMBER_OF_STATUSES 5

@implementation VSChatAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"ACCOUNT", nil);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    VSXmppAccountConfig *xmppConfig = [[VSConfiguration sharedInstance] xmppConfig];
    [[VSXmppService sharedInstance] sendPresenceStatus:xmppConfig.onlineStatus
                                           withMessage:xmppConfig.statusMessage];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return NUMBER_OF_STATUSES;
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName = nil;
    
    switch (section) {
        case 0:
            sectionName = @"";
            break;
            
        case 1:
            sectionName = NSLocalizedString(@"PERSONAL_MESSAGE", nil);
            break;
            
        case 2:
        default:
            sectionName = NSLocalizedString(@"STATUS", nil);
            break;
    }
    
    return sectionName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if ([indexPath section] == 0) {
        NSString *jabberId;
        if ([[[VSConfiguration sharedInstance] xmppConfig] isDefined]) {
            jabberId = [[VSConfiguration sharedInstance] xmppConfig].account;
            
            UIImageView *avatar = (UIImageView *) [cell viewWithTag:AVATAR_CELL_ACCOUNT_IMAGE];
            avatar.image = [[VSXmppService sharedInstance]
                            getAvatarForJabberID:[XMPPJID jidWithString:jabberId]];
        } else {
            jabberId = NSLocalizedString(@"NOT_CONFIGURED", nil);
        }
        
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"avatarCell"];
        UILabel *label = (UILabel *) [cell viewWithTag:AVATAR_CELL_ACCOUNT_LABEL];
        label.text = jabberId;
        
    } else if ([indexPath section] == 1) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"personalMessageCell"];
        UITextField *personalMessageView = (UITextField *) [cell viewWithTag:PERSONAL_MESSAGE_TEXT];
        
        if ([[[VSConfiguration sharedInstance] xmppConfig] isDefined]) {
            personalMessageView.text = [[[VSConfiguration sharedInstance] xmppConfig] statusMessage];
            personalMessageView.delegate = self;
        
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(personalMessageTextDidChange:)
                                                         name:UITextFieldTextDidChangeNotification
                                                       object:personalMessageView];
        }
        
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"statusCell"];
        
        VSPresenceStatus presenceStatus = [[[VSConfiguration sharedInstance] xmppConfig] onlineStatus];
        
        switch ([indexPath row]) {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"STATUS_AVAILABLE", nil);
                [self checkIfTheCell:cell atRow:0 representsTheCurrentOnlineStatus:presenceStatus];
                break;
                
            case 1:
                cell.textLabel.text = NSLocalizedString(@"STATUS_FREE_TO_CHAT", nil);
                [self checkIfTheCell:cell atRow:1 representsTheCurrentOnlineStatus:presenceStatus];
                break;
                
            case 2:
                cell.textLabel.text = NSLocalizedString(@"STATUS_AWAY", nil);
                [self checkIfTheCell:cell atRow:2 representsTheCurrentOnlineStatus:presenceStatus];
                break;
                
            case 3:
                cell.textLabel.text = NSLocalizedString(@"STATUS_LONG_AWAY", nil);
                [self checkIfTheCell:cell atRow:3 representsTheCurrentOnlineStatus:presenceStatus];
                break;
                
            case 4:
            default:
                cell.textLabel.text = NSLocalizedString(@"STATUS_DND", nil);
                [self checkIfTheCell:cell atRow:4 representsTheCurrentOnlineStatus:presenceStatus];
                break;
        }
        
    }
    
    return cell;
}

- (void) checkIfTheCell:(UITableViewCell *)cell
                  atRow:(NSInteger)row
representsTheCurrentOnlineStatus:(VSPresenceStatus)status
{
    if (status == row) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        return 80;
    }
    return 44;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 1) {
        [[[self.tableView cellForRowAtIndexPath:indexPath]
          viewWithTag:PERSONAL_MESSAGE_TEXT] becomeFirstResponder];
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) { //Change avatar
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    } else if ([indexPath section] == 2) { //Change online status
        for (int row = 0; row < NUMBER_OF_STATUSES; row++) {
            [self removeCheckmarkFromCellInSection2AtRow:row];
        }
        [[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
        
        VSXmppAccountConfig *xmppConfig = [[VSConfiguration sharedInstance] xmppConfig];
        [xmppConfig setOnlineStatus:[indexPath row]];
        [[VSConfiguration sharedInstance] updateAndSaveXmppConfig:xmppConfig];
        [[VSXmppService sharedInstance] sendPresenceStatus:xmppConfig.onlineStatus
                                               withMessage:xmppConfig.statusMessage];
    }
}

//Called when the user picks an image to set as a new avatar
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    UIImage *newAvatar = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *scaledAvatar = [VSUtility imageWithImage:newAvatar withMaxWidthOrHeightScaledTo:80];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UIImageView *avatarView = (UIImageView *) [cell viewWithTag:AVATAR_CELL_ACCOUNT_IMAGE];
    avatarView.image = scaledAvatar;
    
    [[VSXmppService sharedInstance] updateAvatar:scaledAvatar];
}

- (void)removeCheckmarkFromCellInSection2AtRow:(NSInteger)row
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:2];
    [[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)personalMessageTextDidChange:(NSNotification *)notification
{
    UITextField *textField = (UITextField *) [notification object];
    
    VSXmppAccountConfig *xmppAccount = [[VSConfiguration sharedInstance] xmppConfig];
    
    xmppAccount.statusMessage = textField.text;
    
    [[VSConfiguration sharedInstance] updateAndSaveXmppConfig:xmppAccount];
}


@end
