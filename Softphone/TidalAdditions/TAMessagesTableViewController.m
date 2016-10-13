//
//  TAMessagesTableViewController.h
//
//  Created by Tidal ArtWorks on 19/02/13.
//  Copyright (c) 2013 Tidal ArtWorks. All rights reserved.
//

#import "TAMessagesTableViewController.h"
#import "TAMessageTableViewCell.h"

#pragma mark - Definitions -

#define INPUT_BACKGROUND_VIEW_HEIGHT    40.0
#define INPUT_TEXT_BORDER_LEFT_PADDING  6.0
#define INPUT_TEXT_BORDER_RIGHT_PADDING 6.0
#define INPUT_TEXT_TOP_INSET            4.0
#define INPUT_TEXT_LEFT_INSET           12.0
#define INPUT_TEXT_BOTTOM_INSET         0.0
#define INPUT_TEXT_RIGHT_INSET          12.0

#pragma mark - Class -

@interface TAMessagesTableViewController ()

@property (strong, nonatomic) UIImageView *inputBackgroundView;
@property (strong, nonatomic) NSLayoutConstraint *inputBackgroundBottomEdge;
@property (assign, nonatomic) UIInterfaceOrientation lastKnownOrientation;
@property (assign, nonatomic) CGFloat yContentOffset;

@end

@implementation TAMessagesTableViewController

{} // Only here to avoid problem in XCode navigator

#pragma mark - Notifications -

- (void)receivedNotification:(NSNotification *)notification {
    
    if (notification.name == UIKeyboardWillChangeFrameNotification) {
        
        NSTimeInterval animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGRect keyboardBounds = [self.view convertRect:[notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue] toView:nil];
        CGFloat keyboardHeight = keyboardBounds.size.height;
        
        self.inputBackgroundBottomEdge.constant = -keyboardHeight + self.tabBarController.tabBar.frame.size.height;
        
        // Check here if orientation has changed and re-layout before animation
        if (self.lastKnownOrientation != self.interfaceOrientation)
            [self.view layoutIfNeeded];
        
        // Commit now the "real" animation
        [UIView animateWithDuration:animationDuration animations:^{
        
            [self.view layoutIfNeeded];
        }];
    }
    else if (notification.name == UIKeyboardWillHideNotification) {
        
        NSTimeInterval animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        self.inputBackgroundBottomEdge.constant = 0;
        
        
        [UIView animateWithDuration:animationDuration animations:^{
            
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark - View lifecycle -

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource      = self;
    self.tableView.delegate        = self;
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [self.tableView registerClass:[TAMessageTableViewCell class] forCellReuseIdentifier:@"CellBubbleLeft"];
    [self.tableView registerClass:[TAMessageTableViewCell class] forCellReuseIdentifier:@"CellBubbleRight"];
    
    [self.view addSubview:self.tableView];
    
    self.inputBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TAMessagesViewControllerInputBackground"]];
    self.inputBackgroundView.userInteractionEnabled = YES;
    
    [self.view addSubview:self.inputBackgroundView];
    
    self.textField = [[TAInsetsTextField alloc] init];
    self.textField.backgroundColor = [UIColor whiteColor];
    self.textField.background = [[UIImage imageNamed:@"TAMessagesViewControllerTextFieldBackground"] stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    self.textField.delegate = self;
    self.textField.font = [UIFont systemFontOfSize:15.0];
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textField.textEdgeInsets = UIEdgeInsetsMake(INPUT_TEXT_TOP_INSET, INPUT_TEXT_LEFT_INSET, INPUT_TEXT_BOTTOM_INSET, INPUT_TEXT_RIGHT_INSET);
    self.textField.returnKeyType = UIReturnKeySend;
    [self.inputBackgroundView addSubview:self.textField];
    
    // Define generic constraints
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.inputBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *tableLeftEdge = [NSLayoutConstraint constraintWithItem:self.tableView
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1
                                                                      constant:0];
    
    NSLayoutConstraint *tableRightEdge = [NSLayoutConstraint constraintWithItem:self.tableView
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1
                                                                       constant:0];
    
    NSLayoutConstraint *tableTopEdge = [NSLayoutConstraint constraintWithItem:self.tableView
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1
                                                                     constant:0];
    
    NSLayoutConstraint *tableBottomEdge = [NSLayoutConstraint constraintWithItem:self.tableView
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.inputBackgroundView
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1
                                                                        constant:0];
    
    NSLayoutConstraint *inputBackgroundLeftEdge = [NSLayoutConstraint constraintWithItem:self.inputBackgroundView
                                                                               attribute:NSLayoutAttributeLeft
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.view
                                                                               attribute:NSLayoutAttributeLeft
                                                                              multiplier:1
                                                                                constant:0];
    
    NSLayoutConstraint *inputBackgroundRightEdge = [NSLayoutConstraint constraintWithItem:self.inputBackgroundView
                                                                                attribute:NSLayoutAttributeRight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self.view
                                                                                attribute:NSLayoutAttributeRight
                                                                               multiplier:1
                                                                                 constant:0];
    
    NSLayoutConstraint *inputBackgroundHeight = [NSLayoutConstraint constraintWithItem:self.inputBackgroundView
                                                                             attribute:NSLayoutAttributeHeight
                                                                             relatedBy:NSLayoutRelationLessThanOrEqual
                                                                                toItem:nil
                                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                                            multiplier:0
                                                                              constant:INPUT_BACKGROUND_VIEW_HEIGHT];
    
    // This constraint is slight different because it will change when keyboard shows up
    self.inputBackgroundBottomEdge = [NSLayoutConstraint constraintWithItem:self.inputBackgroundView
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1
                                                                   constant:0];
    
    NSLayoutConstraint *textLeftEdge = [NSLayoutConstraint constraintWithItem:self.textField
                                                                    attribute:NSLayoutAttributeLeft
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.inputBackgroundView
                                                                    attribute:NSLayoutAttributeLeft
                                                                   multiplier:1
                                                                     constant:INPUT_TEXT_BORDER_LEFT_PADDING];
    
    NSLayoutConstraint *textRightEdge = [NSLayoutConstraint constraintWithItem:self.textField
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.inputBackgroundView
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1
                                                                      constant:-INPUT_TEXT_BORDER_RIGHT_PADDING];
    
    NSLayoutConstraint *textTopEdge = [NSLayoutConstraint constraintWithItem:self.textField
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.inputBackgroundView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1
                                                                    constant:0];
    
    NSLayoutConstraint *textBottomEdge = [NSLayoutConstraint constraintWithItem:self.textField
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.inputBackgroundView
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1
                                                                       constant:0];
    
    [self.view addConstraints:@[tableLeftEdge, tableRightEdge, tableTopEdge, tableBottomEdge, inputBackgroundLeftEdge, inputBackgroundRightEdge, inputBackgroundHeight, self.inputBackgroundBottomEdge, textLeftEdge, textRightEdge, textTopEdge, textBottomEdge]];
    [self.view setNeedsLayout];
    
    self.lastKnownOrientation = self.interfaceOrientation;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - Table view data source -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // This method should be overridden by subclasses
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // This method should be overridden by subclasses
    return 0;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    self.lastKnownOrientation = self.interfaceOrientation;
}

#pragma mark - Scrollview delegate -

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    self.yContentOffset = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (self.yContentOffset > scrollView.contentOffset.y)
        [self.textField resignFirstResponder];
        
    self.yContentOffset = -1;
}

@end
