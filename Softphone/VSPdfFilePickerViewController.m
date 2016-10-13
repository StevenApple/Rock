//
//  VSPdfFilePickerViewController.m
//  Softphone
//
//  Created by Alex on 23/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import "VSPdfFilePickerViewController.h"

@interface VSPdfFilePickerViewController ()

@property (strong, nonatomic) NSString *documentsDirectory;
@property (strong, nonatomic) NSString *inboxDirectory;
@property (strong, nonatomic) NSPredicate *pdfPredicate;
@property (strong, nonatomic) NSMutableArray *pdfFiles;

@end

@implementation VSPdfFilePickerViewController

- (NSString *)documentsDirectory
{
    if (_documentsDirectory == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask,
                                                             YES);
        _documentsDirectory = [paths objectAtIndex:0];
    }
    
    return _documentsDirectory;
}

- (NSPredicate *)pdfPredicate
{
    if (_pdfPredicate == nil) {
        _pdfPredicate = [NSPredicate predicateWithFormat:@"self ENDSWITH '.pdf'"];
    }
    
    return _pdfPredicate;
}

- (NSMutableArray *)pdfFiles
{
    if (_pdfFiles == nil) {
        _pdfFiles = [NSMutableArray arrayWithCapacity:20];
    }
    
    return _pdfFiles;
}

- (NSArray *)PDFInDirectory:(NSString *)directoryPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:directoryPath
                                                            error:nil];
    
    return [dirContents filteredArrayUsingPredicate:self.pdfPredicate];
}

- (void)populateAllPdfsFromDocumentsAndInboxDirectory
{
    [self.pdfFiles removeAllObjects];
    
    [self populatePDFfilesInFolderAtPath:self.documentsDirectory];
    
    NSString *inboxDirectory = [self.documentsDirectory stringByAppendingPathComponent:@"Inbox"];
    [self populatePDFfilesInFolderAtPath:inboxDirectory];
    
    [self sortPdfFilesArray];
}

- (void)populatePDFfilesInFolderAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir) {
        NSArray *array = [self PDFInDirectory:path];
        
        if (array && [array count] > 0) {
            for (NSString *fileName in array) {
                [self.pdfFiles addObject:[path stringByAppendingPathComponent:fileName]];
            }
        }
    }
}

- (void)sortPdfFilesArray
{
    if ([self.pdfFiles count] > 0) {
        [self.pdfFiles sortUsingComparator:^NSComparisonResult(id a, id b) {
            
            if (![a isKindOfClass:[NSString class]] || ![b isKindOfClass:[NSString class]]) {
                return ([a compare:b]);
                
            } else {
                NSString *aString = (NSString*) a;
                NSString *bString = (NSString*) b;
                return [aString compare:bString options:NSCaseInsensitiveSearch];
            }
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"SELECT_PDF", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self populateAllPdfsFromDocumentsAndInboxDirectory];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.pdfFiles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"Cell"];
    }
    
    cell.imageView.image = [UIImage imageNamed:@"Icon-PDF.png"];
    cell.textLabel.text = [[self.pdfFiles objectAtIndex:[indexPath row]] lastPathComponent];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:NOTIFICATION_NAME_SELECTED_PDF
     object:[self.pdfFiles objectAtIndex:[indexPath row]]];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self deleteFileAtPath:[self.pdfFiles objectAtIndex:[indexPath row]]];
        [self.pdfFiles removeObjectAtIndex:[indexPath row]];
        [self.tableView reloadData];
    }
}

-(void)deleteFileAtPath:(NSString *)path
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path isDirectory:NULL]) {
        [fileManager removeItemAtPath:path error:&error];
    }
}

@end
