//
//  VSNetworkTestTableViewCell.h
//  Softphone
//
//  Created by Alex Gotev on 23/01/15.
//  Copyright (c) 2015 voismart. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VSNetworkTestCellStatus) {
    VSNetworkTestCellIdle,
    VSNetworkTestCellLoading,
    VSNetworkTestCellSuccess,
    VSNetworkTestCellFailure
};

@interface VSNetworkTestTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *subtitle;
@property (weak, nonatomic) IBOutlet UIImageView *resultIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (assign, nonatomic) VSNetworkTestCellStatus status;

@end
