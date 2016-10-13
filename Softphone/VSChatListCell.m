//
//  VSChatListCell.m
//  Softphone
//
//  Created by Alex Gotev on 22/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import "VSChatListCell.h"

@interface VSChatListCell ()

@end

@implementation VSChatListCell

{} // Only here to avoid problem in XCode navigator

#pragma mark - Initializers -

- (void)commonInitializer {
    self.userInteractionEnabled = YES;
    self.callContact.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(userTappedOnCallContact:)];
    singleTap.numberOfTouchesRequired = 1;
    [singleTap setDelegate:self];
    
    [self removeAllGestureRecognizersFromCallContact];
    [self.callContact addGestureRecognizer:singleTap];
}

- (void) userTappedOnCallContact:(UITapGestureRecognizer *)recognizer
{
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(userTappedOnCallContact:)]) {
            [self.delegate userTappedOnCallContact:self];
        }
    }
}

- (void)dealloc
{
    [self removeAllGestureRecognizersFromCallContact];
}

- (void) removeAllGestureRecognizersFromCallContact
{
    for (UIGestureRecognizer *gesture in self.callContact.gestureRecognizers) {
        [self.callContact removeGestureRecognizer:gesture];
    }
}

- (void)awakeFromNib {
    
    [self commonInitializer];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [self commonInitializer];
    }
    
    return self;
}

@end
