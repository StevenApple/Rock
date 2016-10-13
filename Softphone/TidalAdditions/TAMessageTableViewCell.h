//
//  TAMessageTableViewCell.h
//
//  Created by Tidal ArtWorks on 18/02/13.
//  Copyright (c) 2013 Tidal ArtWorks. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Definitions -

#define BUBBLE_BACKGROUND_COLOR             [UIColor colorWithRed:0.859 green:0.886 blue:0.929 alpha:1.0]

#define BUBBLE_IMAGE_BORDER_EDGE_CAP        24.0
#define BUBBLE_IMAGE_FREE_EDGE_CAP          17.0
#define BUBBLE_IMAGE_TOP_CAP                14.0

#define BUBBLE_IMAGE_TOP_PADDING            2.0
#define BUBBLE_IMAGE_BOTTOM_PADDING         2.0

#define BUBBLE_TEXT_FONT                    [UIFont systemFontOfSize:15.0]
#define DATE_TEXT_FONT                      [UIFont systemFontOfSize:11.0]
#define DATE_LABEL_WIDTH                    120
#define DATE_LABEL_HEIGHT                   20
#define BUBBLE_TEXT_MAX_WIDTH               188.0
#define BUBBLE_TEXT_MAX_HEIGHT              CGFLOAT_MAX
#define BUBBLE_TEXT_BORDER_EDGE_PADDING     21.0
#define BUBBLE_TEXT_FREE_EDGE_PADDING       14.0
#define BUBBLE_TEXT_TOP_PADDING             4.0
#define BUBBLE_TEXT_BOTTOM_PADDING          8.0

#pragma mark - Enums -

typedef enum TAMessageStyle : NSUInteger {
    
	TAMessageStyleLeft = 0,
	TAMessageStyleRight
    
} TAMessageStyle;

#pragma mark - Class -

@interface TAMessageTableViewCell : UITableViewCell

{} // Only here to avoid problem in XCode navigator

#pragma mark - Class methods -

+ (CGSize)requiredLabelSizeForText:(NSString *)text;
+ (CGFloat)requiredCellHeightForText:(NSString *)text;

#pragma mark - Properties -

@property (strong, nonatomic) NSString *messageText;

#pragma mark - Setters -

- (void)setBubbleImageNamed:(NSString *)bubbleImageName andStyle:(TAMessageStyle)messageStyle;
- (void)setMessageText:(NSString *)messageText withDate:(NSString *)dateText;

@end
