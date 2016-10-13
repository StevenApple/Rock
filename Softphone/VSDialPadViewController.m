//
//  VSDialPadViewController.m
//  Softphone
//
//  Created by Alex Gotev on 11/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import "VSDialPadViewController.h"
#import "PJSipWrapper.h"
#import "VSUtility.h"

@interface VSDialPadViewController ()

@property (weak, nonatomic) IBOutlet UILabel *numberToCallLabel;
@property (weak, nonatomic) IBOutlet UILabel *registrationStatusLabel;
@property (strong, nonatomic) PJSipNotificationsReceiver *sipNotifications;

@end

@implementation VSDialPadViewController

-(PJSipNotificationsReceiver *)sipNotifications
{
    if (_sipNotifications == nil) {
        _sipNotifications = [[PJSipNotificationsReceiver alloc] init];
        _sipNotifications.delegate = self;
    }
    
    return _sipNotifications;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setRegistrationStatusLabel];
    self.numberToCallLabel.text = @"";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.sipNotifications registerObserver];
    [self setRegistrationStatusLabel];
    self.numberToCallLabel.text = @"";
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.sipNotifications unregisterObserver];
    [super viewWillDisappear:animated];
}

-(void)setRegistrationStatusLabel
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *sipUser = [[PJSipWrapper sharedInstance] getSipUser];
        NSString *text;
        UIColor *textColor;
        
        if ([[PJSipWrapper sharedInstance] isRegistered]) {
            text = [NSString stringWithFormat:NSLocalizedString(@"VOIP_REGISTERED", nil), sipUser];
            textColor = [UIColor colorWithRed:0.051 green:0.441 blue:0 alpha:1];
        } else {
            if (sipUser == nil || [sipUser isEqualToString:@""]) {
                text = NSLocalizedString(@"VOIP_UNREGISTERED", nil);
            } else {
                text = [NSString stringWithFormat:NSLocalizedString(@"VOIP_UNREGISTERED_2", nil), sipUser];
            }
            textColor = [UIColor redColor];
        }
        
        [self.registrationStatusLabel setText:text];
        [self.registrationStatusLabel setTextColor:textColor];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)on1tap:(id)sender {
    self.numberToCallLabel.text = [NSString stringWithFormat:@"%@1",self.numberToCallLabel.text];
}

- (IBAction)on2tap:(id)sender {
    self.numberToCallLabel.text = [NSString stringWithFormat:@"%@2",self.numberToCallLabel.text];
}

- (IBAction)on3tap:(id)sender {
    self.numberToCallLabel.text = [NSString stringWithFormat:@"%@3",self.numberToCallLabel.text];
}

- (IBAction)on4tap:(id)sender {
    self.numberToCallLabel.text = [NSString stringWithFormat:@"%@4",self.numberToCallLabel.text];
}

- (IBAction)on5tap:(id)sender {
    self.numberToCallLabel.text = [NSString stringWithFormat:@"%@5",self.numberToCallLabel.text];
}

- (IBAction)on6tap:(id)sender {
    self.numberToCallLabel.text = [NSString stringWithFormat:@"%@6",self.numberToCallLabel.text];
}

- (IBAction)on7tap:(id)sender {
    self.numberToCallLabel.text = [NSString stringWithFormat:@"%@7",self.numberToCallLabel.text];
}

- (IBAction)on8tap:(id)sender {
    self.numberToCallLabel.text = [NSString stringWithFormat:@"%@8",self.numberToCallLabel.text];
}

- (IBAction)on9tap:(id)sender {
    self.numberToCallLabel.text = [NSString stringWithFormat:@"%@9",self.numberToCallLabel.text];
}

- (IBAction)onAsteriskTap:(id)sender {
    self.numberToCallLabel.text = [NSString stringWithFormat:@"%@*",self.numberToCallLabel.text];
}

- (IBAction)on0tap:(id)sender {
    self.numberToCallLabel.text = [NSString stringWithFormat:@"%@0",self.numberToCallLabel.text];
}

- (IBAction)onHashTap:(id)sender {
    self.numberToCallLabel.text = [NSString stringWithFormat:@"%@#",self.numberToCallLabel.text];
}

- (IBAction)onCallTap:(id)sender {
    [VSUtility makeCallTo:self.numberToCallLabel.text];
}

- (IBAction)onDeleteTap:(id)sender
{
    NSUInteger length = self.numberToCallLabel.text.length;
    if (length > 0)
        self.numberToCallLabel.text = [self.numberToCallLabel.text substringToIndex:length - 1];
}

#pragma mark - Sip Events

-(void)onAccountRegistered:(int)accountId
{
    [self setRegistrationStatusLabel];
}

-(void)onAccountUnregistered:(int)accountId
{
    [self setRegistrationStatusLabel];
}

-(void)onIncomingCallWithId:(int)callId
                    account:(int)accountId
            fromDisplayName:(NSString *)displayName
                  andSipURI:(NSString *)sipURI
{
    //DO NOTHING
}

-(void)onMissedIncomingCallFromDisplayName:(NSString *)displayName andSipURI:(NSString *)sipURI
{
    //DO NOTHING
}

-(void)onIncomingDTMFdigit:(NSString *)dtmfDigit fromCallWithId:(int)callId
{
    //DO NOTHING
}

-(void)onCallTerminatedWithId:(int)callId
{
    //DO NOTHING
}

-(void)onCallInProgressWithId:(int)callId displayName:(NSString *)displayName andSipURI:(NSString *)sipURI
{
    //DO NOTHING
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
