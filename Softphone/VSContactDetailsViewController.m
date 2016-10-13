//
//  VSContactDetailsViewController.m
//  Softphone
//
//  Created by Alex Gotev on 22/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import "VSContactDetailsViewController.h"
#import "VSPhoneNumberActionSheetDelegate.h"
#import "VSEmailActionSheetDelegate.h"
#import "VSHttpUrlActionSheetDelegate.h"
#import "VSMapsActionSheetDelegate.h"
#import "VSUtility.h"

#define CONTACT_DETAILS_IMAGE   100
#define CONTACT_DETAILS_NAME    200
#define CONTACT_DETAILS_SURNAME 300
#define CONTACT_DETAILS_COMPANY 400

#define ADDRESS_CELL_LINE1 10
#define ADDRESS_CELL_LINE2 20
#define ADDRESS_CELL_LINE3 30

#define CONTACT_DETAILS_CELL @"ContactDetailsCell"
#define NUMBER_CELL          @"NumberCell"
#define ADDRESS_CELL         @"AddressCell"

@interface VSContactDetailsViewController ()

@property (strong, nonatomic) UIImage *defaultAvatar;
@property (strong, nonatomic) VSPhoneNumberActionSheetDelegate *numberActionSheet;
@property (strong, nonatomic) VSEmailActionSheetDelegate *emailActionSheet;
@property (strong, nonatomic) VSHttpUrlActionSheetDelegate *urlActionSheet;
@property (strong, nonatomic) VSMapsActionSheetDelegate *mapsActionSheet;

@end

@implementation VSContactDetailsViewController

- (UIImage *)defaultAvatar
{
    if (_defaultAvatar == nil) {
        _defaultAvatar = [UIImage imageNamed:@"Icon-User.png"];
    }
    
    return _defaultAvatar;
}

- (VSPhoneNumberActionSheetDelegate *)numberActionSheet
{
    if (_numberActionSheet == nil) {
        _numberActionSheet = [[VSPhoneNumberActionSheetDelegate alloc] init];
    }
    
    return _numberActionSheet;
}

- (VSEmailActionSheetDelegate *)emailActionSheet
{
    if (_emailActionSheet == nil) {
        _emailActionSheet = [[VSEmailActionSheetDelegate alloc] init];
    }
    
    return _emailActionSheet;
}

- (VSHttpUrlActionSheetDelegate *)urlActionSheet
{
    if (_urlActionSheet == nil) {
        _urlActionSheet = [[VSHttpUrlActionSheetDelegate alloc] init];
    }
    
    return _urlActionSheet;
}

- (VSMapsActionSheetDelegate *)mapsActionSheet
{
    if (_mapsActionSheet == nil) {
        _mapsActionSheet = [[VSMapsActionSheetDelegate alloc] init];
    }
    
    return _mapsActionSheet;
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
    
    self.title = NSLocalizedString(@"CONTACT_DETAILS", nil);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 9;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName = nil;
    
    switch(section) {
        case 0:
            sectionName = NSLocalizedString(@"CONTACT", nil);
            break;
            
        case 1:
            if ([self tableView:tableView numberOfRowsInSection:section] > 0)
                sectionName = NSLocalizedString(@"OFFICE_PHONE", nil);
            break;
            
        case 2:
            if ([self tableView:tableView numberOfRowsInSection:section] > 0)
                sectionName = NSLocalizedString(@"MOBILE_PHONE", nil);
            break;
            
        case 3:
            if ([self tableView:tableView numberOfRowsInSection:section] > 0)
                sectionName = NSLocalizedString(@"FAX", nil);
            break;
            
        case 4:
            if ([self tableView:tableView numberOfRowsInSection:section] > 0)
                sectionName = NSLocalizedString(@"HOME_PHONE", nil);
            break;
            
        case 5:
            if ([self tableView:tableView numberOfRowsInSection:section] > 0)
                sectionName = NSLocalizedString(@"EMAIL", nil);
            break;
            
        case 6:
            if ([self tableView:tableView numberOfRowsInSection:section] > 0)
                sectionName = NSLocalizedString(@"ADDRESS", nil);
            break;
            
        case 7:
            if ([self tableView:tableView numberOfRowsInSection:section] > 0)
                sectionName = NSLocalizedString(@"HOME_PAGE", nil);
            break;
            
        case 8:
        default:
            if ([self tableView:tableView numberOfRowsInSection:section] > 0)
                sectionName = NSLocalizedString(@"NOTES", nil);
            break;
    }
    
    return sectionName;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows;
    
    switch(section) {
        case 0:
            rows = 1;
            break;
            
        case 1:
            rows = [[self.contactToShow officePhones] count];
            break;
            
        case 2:
            rows = [[self.contactToShow mobilePhones] count];
            break;
            
        case 3:
            rows = [[self.contactToShow faxes] count];
            break;
            
        case 4:
            rows = [[self.contactToShow homePhones] count];
            break;
            
        case 5:
            rows = ([self isDefined:[self.contactToShow email]] ? 1 : 0);
            break;
            
        case 6:
            rows = ([self isDefined:[self.contactToShow getFormattedFullAddress]] ? 1 : 0);
            break;
            
        case 7:
            rows = ([self isDefined:[self.contactToShow homePageUrl]] ? 1 : 0);
            break;
            
        case 8:
        default:
            rows = ([self isDefined:[self.contactToShow notes]] ? 1 : 0);
            break;
    }
    
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        return 80;
    } else if ([indexPath section] == 6) {
        return 75;
    }
    return 44;
}

-(BOOL)isDefined:(NSString *)string {
    return (string != nil && ![string isEqualToString:@""] ? YES : NO);
}

-(UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if ([indexPath section] == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:CONTACT_DETAILS_CELL];
        
        UIImageView *avatar = (UIImageView *) [cell viewWithTag:CONTACT_DETAILS_IMAGE];
        UILabel *name = (UILabel *) [cell viewWithTag:CONTACT_DETAILS_NAME];
        UILabel *surname = (UILabel *) [cell viewWithTag:CONTACT_DETAILS_SURNAME];
        UILabel *company = (UILabel *) [cell viewWithTag:CONTACT_DETAILS_COMPANY];
        
        if ([self.contactToShow image]) {
            avatar.image = [self.contactToShow image];
        } else {
            avatar.image = self.defaultAvatar;
        }
        name.text = [self.contactToShow name];
        surname.text = [self.contactToShow surname];
        company.text = [self.contactToShow company];
        
    } else if ([indexPath section] ==  6) {
        cell = [tableView dequeueReusableCellWithIdentifier:ADDRESS_CELL];
        
        NSArray *lines = [[self.contactToShow getFormattedFullAddress] componentsSeparatedByString:@"\n"];
        
        UILabel *line1 = (UILabel *)[cell viewWithTag:ADDRESS_CELL_LINE1];
        UILabel *line2 = (UILabel *)[cell viewWithTag:ADDRESS_CELL_LINE2];
        UILabel *line3 = (UILabel *)[cell viewWithTag:ADDRESS_CELL_LINE3];
        
        if ([lines count] > 0) {
            line1.text = [lines objectAtIndex:0];
        } else {
            line1.text = nil;
        }
        
        if ([lines count] > 1) {
            line2.text = [lines objectAtIndex:1];
        } else {
            line2.text = nil;
        }
        
        if ([lines count] > 2) {
            line3.text = [lines objectAtIndex:2];
        } else {
            line3.text = nil;
        }
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:NUMBER_CELL];
        cell.textLabel.text = [self valueForCellAtIndexPath:indexPath];
    }
    
    return cell;
}

-(NSString *)valueForCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *value = nil;
    switch ([indexPath section]) {
        case 1:
            value = [[self.contactToShow officePhones] objectAtIndex:indexPath.row];
            break;
            
        case 2:
            value = [[self.contactToShow mobilePhones] objectAtIndex:indexPath.row];
            break;
            
        case 3:
            value = [[self.contactToShow faxes] objectAtIndex:indexPath.row];
            break;
            
        case 4:
            value = [[self.contactToShow homePhones] objectAtIndex:indexPath.row];
            break;
            
        case 5:
            value = [self.contactToShow email];
            break;
            
        case 6:
            value = [self.contactToShow getFormattedFullAddress];
            break;
            
        case 7:
            value = [self.contactToShow homePageUrl];
            break;
            
        case 8:
        default:
            value = [self.contactToShow notes];
            break;
    }
    
    return value;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] >= 1 && [indexPath section] <= 4) { //Phone number selected
        self.numberActionSheet.phoneNumber = [self valueForCellAtIndexPath:indexPath];
        [self.numberActionSheet showInViewController:self];
        
    } else if ([indexPath section] == 5) { //Email selected
        self.emailActionSheet.email = [self valueForCellAtIndexPath:indexPath];
        [self.emailActionSheet showInViewController:self];
        
    } else if ([indexPath section] == 6) { //Address selected
        self.mapsActionSheet.address = [self.contactToShow getFormattedFullAddress];
        [self.mapsActionSheet showInViewController:self];
        
    } else if ([indexPath section] == 7) { //Website address selected
        self.urlActionSheet.url = [self.contactToShow homePageUrl];
        [self.urlActionSheet showInViewController:self];
    }
}

/*- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    return 0.0001f;
}*/

/*- (CGFloat)tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section
{
    if ([self tableView:tableView titleForHeaderInSection:section]) {
        return 40;
    }
    return 0.0001f;
}*/

@end
