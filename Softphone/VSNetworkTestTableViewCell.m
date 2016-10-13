//
//  VSNetworkTestTableViewCell.m
//  Softphone
//
//  Created by Alex Gotev on 23/01/15.
//  Copyright (c) 2015 voismart. All rights reserved.
//

#import "VSNetworkTestTableViewCell.h"

@implementation VSNetworkTestTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setStatus:(VSNetworkTestCellStatus)status
{
    switch (status) {
        case VSNetworkTestCellLoading:
            [self setStatusLoading];
            break;
            
        case VSNetworkTestCellFailure:
            [self setStatusFailure];
            break;
            
        case VSNetworkTestCellSuccess:
            [self setStatusSuccess];
            break;
            
        default:
            [self setStatusIdle];
            break;
    }
}

-(void)setStatusIdle
{
    self.activityIndicator.alpha = 0;
    self.resultIndicator.alpha = 0;
    [self.activityIndicator stopAnimating];
    _status = VSNetworkTestCellIdle;
    [self setOkBackgroundColor];
}

- (void)showResultIndicator
{
    self.activityIndicator.alpha = 0;
    self.resultIndicator.alpha = 1;
    [self.activityIndicator stopAnimating];
}

-(void)setStatusSuccess
{
    self.resultIndicator.image = [UIImage imageNamed:@"checkmark.png"];
    [self showResultIndicator];
    _status = VSNetworkTestCellSuccess;
    [self setOkBackgroundColor];
}

-(void)setStatusFailure
{
    self.resultIndicator.image = [UIImage imageNamed:@"delete_sign.png"];
    [self showResultIndicator];
    _status = VSNetworkTestCellFailure;
    [self setWarningBackgroundColor];
}

-(void)setStatusLoading
{
    self.resultIndicator.alpha = 0;
    self.activityIndicator.alpha = 1;
    [self.activityIndicator startAnimating];
    _status = VSNetworkTestCellLoading;
    [self setOkBackgroundColor];
}

-(void)setWarningBackgroundColor
{
    self.backgroundColor = [UIColor yellowColor];
}

-(void)setOkBackgroundColor
{
    self.backgroundColor = [UIColor whiteColor];
}

@end
