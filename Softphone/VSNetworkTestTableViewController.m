//
//  VSNetworkTestTableViewController.m
//  Softphone
//
//  Created by Alex Gotev on 23/01/15.
//  Copyright (c) 2015 voismart. All rights reserved.
//

#import "VSNetworkTestTableViewController.h"
#import "VSNetworkTestTableViewCell.h"
#import "VSConfiguration.h"



@interface VSNetworkTestTableViewController ()

@property (assign, nonatomic) VSNetworkTestCellStatus webServicePortStatus;
@property (assign, nonatomic) VSNetworkTestCellStatus sipPortStatus;
@property (assign, nonatomic) VSNetworkTestCellStatus jabberPortStatus;
@property (strong, nonatomic) GCDAsyncSocket *webServiceSocket;
@property (strong, nonatomic) GCDAsyncSocket *sipSocket;
@property (strong, nonatomic) GCDAsyncSocket *jabberSocket;

@end

@implementation VSNetworkTestTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"NETWORK_TEST", nil);
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (GCDAsyncSocket *)newAsyncSocket
{
    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    socket.delegate = self;
    return socket;
}

-(GCDAsyncSocket *)webServiceSocket
{
    if (_webServiceSocket == nil) {
        _webServiceSocket = [self newAsyncSocket];
    }
    
    return _webServiceSocket;
}

-(GCDAsyncSocket *)sipSocket
{
    if (_sipSocket == nil) {
        _sipSocket = [self newAsyncSocket];
    }
    
    return _sipSocket;
}

-(GCDAsyncSocket *)jabberSocket
{
    if (_jabberSocket == nil) {
        _jabberSocket = [self newAsyncSocket];
    }
    
    return _jabberSocket;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    VSAccountConfig *account = [VSConfiguration sharedInstance].accountConfig;
    VSPersistentSipAccountConfig *sipConfig = [VSConfiguration sharedInstance].sipConfig;
    VSXmppAccountConfig *xmppConfig = [VSConfiguration sharedInstance].xmppConfig;
    
    NSString *xmppServer = xmppConfig.server;
    if (xmppServer == nil || [xmppServer isEqualToString:@""]) {
        xmppServer = sipConfig.host;
    }
    
    self.webServicePortStatus = VSNetworkTestCellLoading;
    self.sipPortStatus = VSNetworkTestCellLoading;
    self.jabberPortStatus = VSNetworkTestCellLoading;
    
    [self.tableView reloadData];
    
    NSError *webServiceSocketError;
    if (![self.webServiceSocket connectToHost:account.pbxAddress onPort:443 withTimeout:10 error:&webServiceSocketError]) {
        NSLog(@"Web service socket connection error: %@", webServiceSocketError);
    }
    
    NSError *sipSocketError;
    if (![self.sipSocket connectToHost:sipConfig.host onPort:sipConfig.port withTimeout:10 error:&sipSocketError]) {
        NSLog(@"SIP socket connection error: %@", sipSocketError);
    }
    
    NSError *jabberSocketError;
    if (![self.jabberSocket connectToHost:xmppServer onPort:xmppConfig.port withTimeout:10 error:&jabberSocketError]) {
        NSLog(@"Jabber socket connection error: %@", jabberSocketError);
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.webServiceSocket disconnect];
    [self.sipSocket disconnect];
    [self.jabberSocket disconnect];
    [super viewWillDisappear:animated];
}

#pragma mark - GCDAsyncSocket Delegate

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    if (sock == self.webServiceSocket) {
        self.webServicePortStatus = VSNetworkTestCellSuccess;
        [self.webServiceSocket disconnect];
    
    } else if (sock == self.jabberSocket) {
        self.jabberPortStatus = VSNetworkTestCellSuccess;
        [self.jabberSocket disconnect];
    
    } else if (sock == self.sipSocket) {
        self.sipPortStatus = VSNetworkTestCellSuccess;
        [self.sipSocket disconnect];
    }
    
    [self.tableView reloadData];
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (!err) return;

    if (sock == self.webServiceSocket) {
        self.webServicePortStatus = VSNetworkTestCellFailure;
    } else if (sock == self.jabberSocket) {
        self.jabberPortStatus = VSNetworkTestCellFailure;
    } else if (sock == self.sipSocket) {
        self.sipPortStatus = VSNetworkTestCellFailure;
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VSNetworkTestTableViewCell *networkCell = [tableView dequeueReusableCellWithIdentifier:@"NetworkTestCell" forIndexPath:indexPath];
    
    VSAccountConfig *account = [VSConfiguration sharedInstance].accountConfig;
    VSPersistentSipAccountConfig *sipConfig = [VSConfiguration sharedInstance].sipConfig;
    VSXmppAccountConfig *xmppConfig = [VSConfiguration sharedInstance].xmppConfig;
    
    switch (indexPath.row) {
        case 0: //Web service port
            [networkCell.label setText:@"Orchestra Web Services"];
            [networkCell.subtitle setText:[NSString stringWithFormat:@"TCP 443, host: %@", account.pbxAddress]];
            networkCell.status = self.webServicePortStatus;
            break;
            
        case 1: //Sip port
            [networkCell.label setText:@"SIP Server"];
            [networkCell.subtitle setText:[NSString stringWithFormat:@"TCP %ld, host: %@", (long)sipConfig.port, sipConfig.host]];
            networkCell.status = self.sipPortStatus;
            break;
            
        case 2: //Jabber port
        default:
            [networkCell.label setText:@"Jabber Server"];
            NSString *xmppServer = xmppConfig.server;
            if (xmppServer == nil || [xmppServer isEqualToString:@""]) {
                xmppServer = sipConfig.host;
            }
            [networkCell.subtitle setText:[NSString stringWithFormat:@"TCP %ld, host: %@", (long)xmppConfig.port, xmppServer]];
            networkCell.status = self.jabberPortStatus;
            break;
    }
    
    return networkCell;
}

@end
