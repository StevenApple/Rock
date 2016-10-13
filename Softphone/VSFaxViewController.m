//
//  VSFaxViewController.m
//  Softphone
//
//  Created by Alex on 23/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import "VSFaxViewController.h"
#import "VSInsertNumberActionSheetDelegate.h"
#import "VSLoadFaxNumbersActionSheetDelegate.h"
#import "VSPdfFilePickerViewController.h"
#import "VSUtility.h"
#import "AppDelegate.h"
#import "VoiSmartWebServicesFactory.h"
#import "VSConfiguration.h"

@interface VSFaxViewController () <VoiSmartWebServiceDelegate>

@property (nonatomic, strong) NSString *senderNumber;
@property (nonatomic, strong) VSInsertNumberActionSheetDelegate *insertNumber;
@property (nonatomic, strong) VSLoadFaxNumbersActionSheetDelegate *loadFaxNumbers;
@property (nonatomic, strong) NSMutableArray *recipientNumbers;
@property (nonatomic, strong) NSMutableArray *recipientNames;
@property (nonatomic, strong) NSString *selectedPdf;

@end

@implementation VSFaxViewController

- (VSInsertNumberActionSheetDelegate *)insertNumber
{
    if (_insertNumber == nil) {
        _insertNumber = [[VSInsertNumberActionSheetDelegate alloc] init];
    }
    
    return _insertNumber;
}

- (NSMutableArray *)recipientNames
{
    if (_recipientNames == nil) {
        _recipientNames = [NSMutableArray arrayWithCapacity:10];
    }
    
    return _recipientNames;
}

- (NSMutableArray *)recipientNumbers
{
    if (_recipientNumbers == nil) {
        _recipientNumbers = [NSMutableArray arrayWithCapacity:10];
    }
    
    return _recipientNumbers;
}

- (VSLoadFaxNumbersActionSheetDelegate *)loadFaxNumbers
{
    if (_loadFaxNumbers == nil) {
        _loadFaxNumbers = [[VSLoadFaxNumbersActionSheetDelegate alloc] init];
    }
    
    return _loadFaxNumbers;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"SEND_FAX", nil);
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(userPickedPDFtoSend:)
     name:NOTIFICATION_NAME_SELECTED_PDF
     object:nil];
    
    /*VSAppDelegate *appDelegate = (VSAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.faxViewController = self;*/
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    /*VSAppDelegate *appDelegate = (VSAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.faxViewController = nil;*/
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    
    switch(section) {
        case 0:
            title = NSLocalizedString(@"PDF_FILE", nil);
            break;
            
        case 1:
            title = NSLocalizedString(@"SENDER", nil);
            break;
            
        case 2:
            title = NSLocalizedString(@"RECIPIENTS", nil);
            break;
            
        default:
            title = @"";
            break;
    }
    
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows;
    
    switch(section) {
        case 0:
            rows = 1;
            break;
            
        case 1:
            rows = 1;
            break;
            
        case 2:
            rows = 1 + [self.recipientNumbers count];
            break;
            
        default:
            rows = 0;
            break;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch ([indexPath section]) {
        case 0: //Currently selected PDF file name
            cell = [tableView dequeueReusableCellWithIdentifier:@"CommandCell"];
            if (self.selectedPdf && [self.selectedPdf length] > 0) {
                cell.textLabel.text = [self.selectedPdf lastPathComponent];
            } else {
                cell.textLabel.text = NSLocalizedString(@"SELECT_PDF_TO_SEND", nil);
            }
            break;
            
        case 1: //Currently selected FAX sender number
            cell = [tableView dequeueReusableCellWithIdentifier:@"CommandCell"];
            if (self.senderNumber == nil || [self.senderNumber isEqualToString:@""]) {
                cell.textLabel.text = NSLocalizedString(@"SELECT_NUMBER", nil);
            } else {
                cell.textLabel.text = self.senderNumber;
            }
            break;
            
        case 2: //Currently added recipients
            if ([indexPath row] == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"CommandCell"];
                cell.textLabel.text = NSLocalizedString(@"ADD_RECIPIENT", nil);
                cell.accessoryView = nil;
                
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"SubtitleCell"];
                cell.textLabel.text = [self.recipientNumbers objectAtIndex:[indexPath row] - 1];
                cell.detailTextLabel.text = [self.recipientNames objectAtIndex:[indexPath row] - 1];
                //TODO: accessory view to delete the row
            }
            break;
            
        default:
            cell = [tableView dequeueReusableCellWithIdentifier:@"SubtitleCell"];
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
            cell.accessoryView = nil;
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:[NSIndexPath indexPathForRow:0 inSection:0]]) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self onSelectPDF];
        
    } else if ([indexPath isEqual:[NSIndexPath indexPathForRow:0 inSection:2]]) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self onAddRecipient];
        
    } else if ([indexPath isEqual:[NSIndexPath indexPathForRow:0 inSection:1]]) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self onSelectFaxSender];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Enable only inserted recipients to be deleted
    return ([indexPath row] > 0 && [indexPath section] == 2);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //Perform deletion of only the added recipients
        if ([indexPath row] > 0 && [indexPath section] == 2) {
            [self onDeleteRecipientAtRow:[indexPath row]];
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (void)onSelectPDF
{
    
    VSPdfFilePickerViewController *pdfPicker =
    (VSPdfFilePickerViewController *)[VSUtility getViewControllerWithIdentifier:@"PDFfilePicker" fromStorybordNamed:@"Main"];
    pdfPicker.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:pdfPicker animated:YES];
}

- (void)userPickedPDFtoSend:(NSNotification *)notification
{
    [self setSelectedPDFFilePathAndReloadTableView:[notification object]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setSelectedPDFFilePathAndReloadTableView:(NSString *)path
{
    _selectedPdf = path;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)onSelectFaxSender
{
    [self.loadFaxNumbers showInViewController:self onCompletedExecute:^(NSString *faxNumber) {
        self.senderNumber = faxNumber;
        [self.tableView reloadData];
    }];
}

- (void)onAddRecipient
{
    [self.insertNumber showInViewController:self
                    onNumberProvidedExecute:^(NSString *number, NSString *name) {
                        [self.recipientNumbers addObject:number];
                        [self.recipientNames addObject:name];
                        [self.tableView reloadData];
                    }];
}

- (void)onDeleteRecipientAtRow:(NSInteger)row
{
    [self.recipientNumbers removeObjectAtIndex:row - 1];
    [self.recipientNames removeObjectAtIndex:row - 1];
}
- (IBAction)onSendFax:(id)sender {
    if (self.selectedPdf == nil || [self.selectedPdf length] == 0) {
        [VSUtility showMessageDialogWithLocalizedTitle:@"WARNING"
                                   andLocalizedMessage:@"SELECT_PDF_TO_SEND"];
        return;
    }
    
    BOOL isDir;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.selectedPdf isDirectory:&isDir] && !isDir) {
        [VSUtility showMessageDialogWithLocalizedTitle:@"WARNING"
                                   andLocalizedMessage:@"PDF_NOT_EXIST"];
        return;
    }
    
    if (self.senderNumber == nil || [self.senderNumber length] == 0) {
        [VSUtility showMessageDialogWithTitle:@"" andMessage:@"Please select a FAX sender number"];
        return;
    }
    
    if ([self.recipientNumbers count] == 0) {
        [VSUtility showMessageDialogWithLocalizedTitle:@"WARNING"
                                   andLocalizedMessage:@"SELECT_PDF_SENDER"];
        return;
    }
    
    id <VoiSmartWebServices> services = [[[VSConfiguration sharedInstance] accountConfig] getWebServicesInstance];
    
    [services getLicenseAndSendResponseToDelegate:self];
}

- (void)receivedLicenseIsValid:(BOOL)valid
           withWebServiceToken:(NSString *)webServiceToken
                         error:(NSError *)error
{
    if (valid) {
        id<VoiSmartWebServices> services = [[[VSConfiguration sharedInstance]
                                             accountConfig] getWebServicesInstance];
        
        [services sendFaxWithToken:webServiceToken
                           pdfPath:self.selectedPdf
                      senderNumber:self.senderNumber
                             notes:@""
                  recipientNumbers:self.recipientNumbers
                          delegate:self];
    } else {
        [VSUtility showMessageDialogWithLocalizedTitle:@"ERROR"
                                   andLocalizedMessage:@"FAX_SEND_ERROR"];
    }
}

- (void)faxSendingCompletedWithResponseCode:(NSNumber *)code
                                 andMessage:(NSString *)message
{
    if (code.integerValue == 200) {
        [VSUtility showMessageDialogWithLocalizedTitle:@"SEND_FAX"
                                   andLocalizedMessage:@"FAX_SENT_SUCCESSFULLY"];
        
        [self.recipientNumbers removeAllObjects];
        [self.recipientNames removeAllObjects];
        self.selectedPdf = nil;
        [self.tableView reloadData];
        
    } else {
        [VSUtility showMessageDialogWithLocalizedTitle:@"ERROR"
                                   andLocalizedMessage:@"FAX_SEND_ERROR"];
    }
}

- (void)faxProgressChanged:(NSNumber *)percent
{
    NSLog(@"Fax progress: %d", percent.intValue);
}

- (void)faxSendingError:(NSError *)error
{
    [VSUtility showMessageDialogWithLocalizedTitle:@"ERROR"
                               andLocalizedMessage:@"FAX_SEND_ERROR"];
}

@end
