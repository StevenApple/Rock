//
//  VSChatListCell.h
//  Softphone
//
//  Created by Alex Gotev on 22/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VSChatListCellDelegate;

@interface VSChatListCell : UITableViewCell <UIGestureRecognizerDelegate>

@property (weak, nonatomic) id<VSChatListCellDelegate> delegate;
@property (strong, nonatomic) NSString *userJabberId;

@property (weak, nonatomic) IBOutlet UIView *contactOnlineStatusIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *contactAvatar;
@property (weak, nonatomic) IBOutlet UILabel *contactName;
@property (weak, nonatomic) IBOutlet UILabel *contactStatusMessage;
@property (weak, nonatomic) IBOutlet UIImageView *callContact;
@property (weak, nonatomic) IBOutlet UIImageView *unreadMessagesIndicator;

@end

@protocol VSChatListCellDelegate <NSObject>

- (void)userTappedOnCallContact:(VSChatListCell *)contactCell;

@end