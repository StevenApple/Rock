//
//  TAMessageTableViewCell.m
//
//  Created by Tidal ArtWorks on 18/02/13.
//  Copyright (c) 2013 Tidal ArtWorks. All rights reserved.
//

#import "TAMessageTableViewCell.h"

#pragma mark - Class -

@interface TAMessageTableViewCell ()

@property (strong, nonatomic) NSString      *bubbleImageName;
@property (strong, nonatomic) UIImageView   *bubbleView;
@property (strong, nonatomic) UILabel       *bubbleLabel;
@property (strong, nonatomic) UILabel       *dateLabel;
@property (assign, nonatomic) CGSize         bubbleLabelOptimalSize;
@property (assign, nonatomic) TAMessageStyle messageStyle;

@end

@implementation TAMessageTableViewCell

{} // Only here to avoid problem in XCode navigator

#pragma mark - Class methods -

+ (BOOL)requiresConstraintBasedLayout {
    
    return YES;
}

+ (CGSize)requiredLabelSizeForText:(NSString *)text {
    
    static UILabel *testLabel;
    static CGSize   testSize;
    
    if (!testLabel) {
        
        testLabel = [[UILabel alloc] init];
        testLabel.font = BUBBLE_TEXT_FONT;
        testLabel.lineBreakMode = NSLineBreakByWordWrapping;
        testLabel.numberOfLines = 0;
    }
    
    if (![testLabel.text isEqualToString:text]) {
        
        testLabel.text = text;
        testSize = [testLabel sizeThatFits:CGSizeMake(BUBBLE_TEXT_MAX_WIDTH, BUBBLE_TEXT_MAX_HEIGHT)];
    }
    
    return testSize;
}

+ (CGFloat)requiredCellHeightForText:(NSString *)text {
    
    return BUBBLE_IMAGE_TOP_PADDING + BUBBLE_TEXT_TOP_PADDING + [TAMessageTableViewCell requiredLabelSizeForText:text].height + BUBBLE_TEXT_BOTTOM_PADDING + BUBBLE_IMAGE_BOTTOM_PADDING + 1 + DATE_LABEL_HEIGHT;
}

#pragma mark - Initializers -

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.textLabel.hidden = YES;
    }
    
    return self;
}

#pragma mark - Setters -

- (void)setBubbleImageNamed:(NSString *)bubbleImageName andStyle:(TAMessageStyle)messageStyle {
    
    if (messageStyle == _messageStyle && [bubbleImageName isEqualToString:_bubbleImageName])
        return;
    
    self.bubbleImageName = bubbleImageName;
    self.messageStyle = messageStyle;
    
    if (self.bubbleView)
        [self.bubbleView removeFromSuperview];
    
    if (messageStyle == TAMessageStyleLeft)
        self.bubbleView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:bubbleImageName] stretchableImageWithLeftCapWidth:BUBBLE_IMAGE_BORDER_EDGE_CAP topCapHeight:BUBBLE_IMAGE_TOP_CAP]];
    else
        self.bubbleView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:bubbleImageName] stretchableImageWithLeftCapWidth:BUBBLE_IMAGE_FREE_EDGE_CAP topCapHeight:BUBBLE_IMAGE_TOP_CAP]];
    
    // Image has changed... trigger new constraints creation (also for bubble view)
    self.messageText = self.messageText;
}

- (void)setMessageText:(NSString *)messageText withDate:(NSString *)dateText {
    
    if ((!messageText && !_messageText) || (messageText && [messageText isEqualToString:_messageText]))
        return;
    
    _messageText = messageText;
    
    if (!self.bubbleView)
        return;
    
    if (self.bubbleLabel)
        [self.bubbleLabel removeFromSuperview];
    else {
        
        self.bubbleLabel = [[UILabel alloc] init];
        self.bubbleLabel.font = BUBBLE_TEXT_FONT;
        self.bubbleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.bubbleLabel.numberOfLines = 0;
        self.bubbleLabel.backgroundColor = [UIColor clearColor];
    }
    
    self.bubbleLabel.text = messageText;
    
    if (self.dateLabel)
        [self.dateLabel removeFromSuperview];
    else {
        
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.font = DATE_TEXT_FONT;
        self.dateLabel.textAlignment = (self.messageStyle == TAMessageStyleLeft ? NSTextAlignmentLeft : NSTextAlignmentRight);
        self.dateLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.dateLabel.backgroundColor = [UIColor clearColor];
    }
    
    self.dateLabel.text = dateText;
    
    [self.contentView addSubview:self.bubbleView];
    [self.contentView addSubview:self.bubbleLabel];
    [self.contentView addSubview:self.dateLabel];
    [self.contentView sendSubviewToBack:self.bubbleView];
    
    CGSize bubbleLabelSize = [TAMessageTableViewCell requiredLabelSizeForText:messageText];
    CGSize dateLabelSize = CGSizeMake(DATE_LABEL_WIDTH, DATE_LABEL_HEIGHT);
    
    // Define generic constraints
    self.bubbleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.dateLabel.translatesAutoresizingMaskIntoConstraints   = NO;
    self.bubbleView.translatesAutoresizingMaskIntoConstraints  = NO;
    
    NSLayoutConstraint *bubbleLabelWidth = [NSLayoutConstraint constraintWithItem:self.bubbleLabel
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:0
                                                                         constant:bubbleLabelSize.width];
    
    NSLayoutConstraint *bubbleLabelHeight = [NSLayoutConstraint constraintWithItem:self.bubbleLabel
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:0
                                                                          constant:bubbleLabelSize.height];
    
    NSLayoutConstraint *dateLabelWidth = [NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:0
                                                                         constant:dateLabelSize.width];
    
    NSLayoutConstraint *dateLabelHeight = [NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:0
                                                                          constant:dateLabelSize.height];
    
    NSLayoutConstraint *bubbleViewWidth = [NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.bubbleLabel
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1
                                                                        constant:BUBBLE_TEXT_BORDER_EDGE_PADDING + BUBBLE_TEXT_FREE_EDGE_PADDING];
    
    NSLayoutConstraint *bubbleViewHeight = [NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.bubbleLabel
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1
                                                                         constant:BUBBLE_TEXT_TOP_PADDING + BUBBLE_TEXT_BOTTOM_PADDING];
    
    NSLayoutConstraint *bubbleViewTopEdge = [NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.contentView
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1
                                                                          constant:BUBBLE_IMAGE_TOP_PADDING];
    
    NSLayoutConstraint *bubbleLabelTopEdge = [NSLayoutConstraint constraintWithItem:self.bubbleLabel
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.bubbleView
                                                                          attribute:NSLayoutAttributeTop
                                                                         multiplier:1
                                                                           constant:BUBBLE_TEXT_TOP_PADDING];
    
    NSLayoutConstraint *bubbleViewEdge = [NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                      attribute:(self.messageStyle == TAMessageStyleLeft ? NSLayoutAttributeLeft : NSLayoutAttributeRight)
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.contentView
                                                                      attribute:(self.messageStyle == TAMessageStyleLeft ? NSLayoutAttributeLeft : NSLayoutAttributeRight)
                                                                     multiplier:1
                                                                       constant:0];
    
    NSLayoutConstraint *bubbleLabelEdge = [NSLayoutConstraint constraintWithItem:self.bubbleLabel
                                                                       attribute:(self.messageStyle == TAMessageStyleLeft ? NSLayoutAttributeLeft : NSLayoutAttributeRight)
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.bubbleView
                                                                       attribute:(self.messageStyle == TAMessageStyleLeft ? NSLayoutAttributeLeft : NSLayoutAttributeRight)
                                                                      multiplier:1
                                                                        constant:(self.messageStyle == TAMessageStyleLeft ? 1 : -1) * BUBBLE_TEXT_BORDER_EDGE_PADDING];
    
    NSLayoutConstraint *dateLabelTopEdge = [NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.bubbleView
                                                                          attribute:NSLayoutAttributeBottom
                                                                         multiplier:1
                                                                           constant:0];
    
    NSLayoutConstraint *dateLabelEdge = [NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                       attribute:(self.messageStyle == TAMessageStyleLeft ? NSLayoutAttributeLeft : NSLayoutAttributeRight)
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.bubbleView
                                                                       attribute:(self.messageStyle == TAMessageStyleLeft ? NSLayoutAttributeLeft : NSLayoutAttributeRight)
                                                                      multiplier:1
                                                                        constant:(self.messageStyle == TAMessageStyleLeft ? 1 : -1) * (BUBBLE_TEXT_BORDER_EDGE_PADDING / 2)];
    

    
    [self.contentView addConstraints:@[bubbleLabelWidth, bubbleLabelHeight, bubbleViewWidth, bubbleViewHeight, dateLabelWidth, dateLabelHeight, bubbleViewEdge, bubbleViewTopEdge, bubbleLabelEdge, bubbleLabelTopEdge, dateLabelTopEdge, dateLabelEdge]];
    [self.contentView setNeedsLayout];
}

@end
