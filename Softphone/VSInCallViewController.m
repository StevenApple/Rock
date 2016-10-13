//
//  VSInCallViewController.m
//  Softphone
//
//  Created by Alex Gotev on 11/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import "VSInCallViewController.h"

@interface VSInCallViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *displayLabel;
@property (weak, nonatomic) IBOutlet UIButton *dtmf1button;
@property (weak, nonatomic) IBOutlet UIButton *dialPadOrDtmf2button;
@property (weak, nonatomic) IBOutlet UIButton *dtmf3button;
@property (weak, nonatomic) IBOutlet UIButton *dtmf4button;
@property (weak, nonatomic) IBOutlet UIButton *holdOrDtmf5button;
@property (weak, nonatomic) IBOutlet UIButton *dtmf6button;
@property (weak, nonatomic) IBOutlet UIButton *dtmf7button;
@property (weak, nonatomic) IBOutlet UIButton *transferOrDtmf8button;
@property (weak, nonatomic) IBOutlet UIButton *dtmf9button;
@property (weak, nonatomic) IBOutlet UIButton *dtmfAsteriskButton;
@property (weak, nonatomic) IBOutlet UIButton *loudSpeakerOrDtmf0button;
@property (weak, nonatomic) IBOutlet UIButton *dtmfPoundButton;
@property (weak, nonatomic) IBOutlet UIButton *muteOrHideDialPadButton;

@property (assign, nonatomic) BOOL dialPadMode;
@property (assign, nonatomic) BOOL callIsHold;
@property (assign, nonatomic) BOOL callIsMute;
@property (assign, nonatomic) BOOL loudspeakerIsOn;
@property (strong, nonatomic) UIColor *normalColor;
@property (strong, nonatomic) UIColor *selectedColor;

@end

@implementation VSInCallViewController

- (UIColor *)normalColor
{
    if (_normalColor == nil) {
        _normalColor = [UIColor colorWithRed:0.004 green:0.5 blue:0.998 alpha:1];
    }
    
    return _normalColor;
}

- (UIColor *)selectedColor
{
    if (_selectedColor == nil) {
        _selectedColor = [UIColor colorWithRed:0.051 green:0.441 blue:0 alpha:1];
    }

    return _selectedColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dialPadMode = NO;
    self.callIsHold = NO;
    self.callIsMute = NO;
    self.loudspeakerIsOn = NO;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self hideDialPad];
    self.dialPadMode = NO;
    self.callIsHold = NO;
    self.callIsMute = NO;
    self.loudspeakerIsOn = NO;
    [self.holdOrDtmf5button setBackgroundColor:self.normalColor];
    [self.muteOrHideDialPadButton setBackgroundColor:self.normalColor];
    [self.loudSpeakerOrDtmf0button setBackgroundColor:self.normalColor];
    [self.nameLabel setText:self.displayName];
    [self.displayLabel setText:@""];
}

-(void)hideDialPad
{
    BOOL hidden = YES;

    self.dtmf1button.hidden = hidden;
    self.dtmf3button.hidden = hidden;
    self.dtmf4button.hidden = hidden;
    self.dtmf6button.hidden = hidden;
    self.dtmf7button.hidden = hidden;
    self.dtmf9button.hidden = hidden;
    self.dtmfAsteriskButton.hidden = hidden;
    self.dtmfPoundButton.hidden = hidden;
    
    //Setup labels
    [self.dialPadOrDtmf2button setTitle:NSLocalizedString(@"DIAL_PAD", nil) forState:UIControlStateNormal];
    [self.holdOrDtmf5button setTitle:NSLocalizedString(@"HOLD", nil) forState:UIControlStateNormal];
    [self.transferOrDtmf8button setTitle:NSLocalizedString(@"TRANSFER", nil) forState:UIControlStateNormal];
    [self.loudSpeakerOrDtmf0button setTitle:NSLocalizedString(@"LOUDSPEAKER", nil) forState:UIControlStateNormal];
    [self.muteOrHideDialPadButton setTitle:NSLocalizedString(@"MUTE", nil) forState:UIControlStateNormal];
    
    //Adjust background color of toggle buttons
    if (self.callIsHold) {
        [self.holdOrDtmf5button setBackgroundColor:self.selectedColor];
    } else {
        [self.holdOrDtmf5button setBackgroundColor:self.normalColor];
    }
    
    
    self.dialPadMode = NO;
}

-(void)showDialPad
{
    BOOL hidden = NO;
    
    self.dtmf1button.hidden = hidden;
    self.dtmf3button.hidden = hidden;
    self.dtmf4button.hidden = hidden;
    self.dtmf6button.hidden = hidden;
    self.dtmf7button.hidden = hidden;
    self.dtmf9button.hidden = hidden;
    self.dtmfAsteriskButton.hidden = hidden;
    self.dtmfPoundButton.hidden = hidden;
    
    //Setup labels
    [self.dialPadOrDtmf2button setTitle:@"2 abc" forState:UIControlStateNormal];
    [self.holdOrDtmf5button setTitle:@"5 jkl" forState:UIControlStateNormal];
    [self.transferOrDtmf8button setTitle:@"8 tuv" forState:UIControlStateNormal];
    [self.loudSpeakerOrDtmf0button setTitle:@"0" forState:UIControlStateNormal];
    [self.muteOrHideDialPadButton setTitle:NSLocalizedString(@"BACK", nil) forState:UIControlStateNormal];
    
    //Adjust background color of toggle buttons
    [self.holdOrDtmf5button setBackgroundColor:self.normalColor];
    
    self.dialPadMode = YES;
}

- (IBAction)onDtmf1Tap:(id)sender {
    self.displayLabel.text = [NSString stringWithFormat:@"%@1", self.displayLabel.text];
    [[PJSipWrapper sharedInstance] sendDTMF:@"1" toCallWithId:self.callId];
}

- (IBAction)onDialPadShowOrDtmf2Tap:(id)sender {
    if (self.dialPadMode) {
        self.displayLabel.text = [NSString stringWithFormat:@"%@2", self.displayLabel.text];
        [[PJSipWrapper sharedInstance] sendDTMF:@"2" toCallWithId:self.callId];
    } else {
        [self showDialPad];
    }
}

- (IBAction)onDtmf3Tap:(id)sender {
    self.displayLabel.text = [NSString stringWithFormat:@"%@3", self.displayLabel.text];
    [[PJSipWrapper sharedInstance] sendDTMF:@"3" toCallWithId:self.callId];
}

- (IBAction)onDtmf4Tap:(id)sender {
    self.displayLabel.text = [NSString stringWithFormat:@"%@4", self.displayLabel.text];
    [[PJSipWrapper sharedInstance] sendDTMF:@"4" toCallWithId:self.callId];
}

- (IBAction)onHoldOrDtmf5Tap:(id)sender {
    if (self.dialPadMode) {
        self.displayLabel.text = [NSString stringWithFormat:@"%@5", self.displayLabel.text];
        [[PJSipWrapper sharedInstance] sendDTMF:@"5" toCallWithId:self.callId];
    } else {
        if (self.callIsHold) {
            NSLog(@"UnHoldCall");
            [[PJSipWrapper sharedInstance] unholdCallWithId:self.callId];
            [self.holdOrDtmf5button setBackgroundColor:self.normalColor];
            self.callIsHold = NO;
        } else {
            NSLog(@"HoldCall");
            [[PJSipWrapper sharedInstance] holdCallWithId:self.callId];
            [self.holdOrDtmf5button setBackgroundColor:self.selectedColor];
            self.callIsHold = YES;
        }
    }
}

- (IBAction)onDtmf6Tap:(id)sender {
    self.displayLabel.text = [NSString stringWithFormat:@"%@6", self.displayLabel.text];
    [[PJSipWrapper sharedInstance] sendDTMF:@"6" toCallWithId:self.callId];
}

- (IBAction)onDtmf7Tap:(id)sender {
    self.displayLabel.text = [NSString stringWithFormat:@"%@7", self.displayLabel.text];
    [[PJSipWrapper sharedInstance] sendDTMF:@"7" toCallWithId:self.callId];
}

- (IBAction)onTransferOrDtmf8Tap:(id)sender {
    if (self.dialPadMode) {
        self.displayLabel.text = [NSString stringWithFormat:@"%@8", self.displayLabel.text];
        [[PJSipWrapper sharedInstance] sendDTMF:@"8" toCallWithId:self.callId];
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TRANSFER_CALL", nil)
                                                         message:NSLocalizedString(@"TRANSFER_CALL_TEXT", nil)
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                               otherButtonTitles:NSLocalizedString(@"TRANSFER_CALL_COMMIT", nil), nil];
        
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField * alertTextField = [alert textFieldAtIndex:0];
        alertTextField.keyboardType = UIKeyboardTypeNumberPad;
        alertTextField.placeholder = @"";
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UITextField *field = [alertView textFieldAtIndex:0];
        [[PJSipWrapper sharedInstance] transferCallWithId:self.callId
                                              toExtension:field.text];
    }
}

- (IBAction)onDtmf9Tap:(id)sender {
    self.displayLabel.text = [NSString stringWithFormat:@"%@9", self.displayLabel.text];
    [[PJSipWrapper sharedInstance] sendDTMF:@"9" toCallWithId:self.callId];
}

- (IBAction)onDtmfAsteriskTap:(id)sender {
    self.displayLabel.text = [NSString stringWithFormat:@"%@*", self.displayLabel.text];
    [[PJSipWrapper sharedInstance] sendDTMF:@"*" toCallWithId:self.callId];
}

- (IBAction)onLoudSpeakerOrDtmf0Tap:(id)sender {
    if (self.dialPadMode) {
        self.displayLabel.text = [NSString stringWithFormat:@"%@0", self.displayLabel.text];
        [[PJSipWrapper sharedInstance] sendDTMF:@"0" toCallWithId:self.callId];
    } else {
        //TODO: loudspeaker
    }
}

- (IBAction)onDtmfPoundTap:(id)sender {
    self.displayLabel.text = [NSString stringWithFormat:@"%@#", self.displayLabel.text];
    [[PJSipWrapper sharedInstance] sendDTMF:@"#" toCallWithId:self.callId];
}

- (IBAction)onMuteOrHideDialPadTap:(id)sender {
    if (self.dialPadMode) {
        [self hideDialPad];
    } else {
        if (self.callIsMute) {
            NSLog(@"UnMuteCall");
            [[PJSipWrapper sharedInstance] unmuteCallWithId:self.callId];
            [self.muteOrHideDialPadButton setBackgroundColor:self.normalColor];
            self.callIsMute = NO;
        } else {
            NSLog(@"MuteCall");
            [[PJSipWrapper sharedInstance] muteCallWithId:self.callId];
            [self.muteOrHideDialPadButton setBackgroundColor:self.selectedColor];
            self.callIsMute = YES;
        }
    }
}

- (IBAction)onHangUpTap:(id)sender {
    [[PJSipWrapper sharedInstance] hangUpCallWithId:self.callId];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
