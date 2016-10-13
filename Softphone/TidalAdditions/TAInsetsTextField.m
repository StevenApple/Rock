//
//  TAInsetsTextField.m
//
//  Created by Tidal ArtWorks on 21/02/13.
//  Copyright (c) 2013 Tidal ArtWorks. All rights reserved.
//

#import "TAInsetsTextField.h"

#pragma mark - Class -

@interface TAInsetsTextField ()

@end

@implementation TAInsetsTextField

{} // Only here to avoid problem in XCode navigator

#pragma mark - Initializers -

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self)
        [self zeroDefaults];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self)
        [self zeroDefaults];
    
    return self;
}

#pragma mark - Defaults -

- (void)zeroDefaults {
    
    self.textEdgeInsets = UIEdgeInsetsZero;
    self.clearButtonEdgeInsets = UIEdgeInsetsZero;
}

#pragma mark - UITextField extensions -

- (CGRect)textRectForBounds:(CGRect)bounds {
    
	return UIEdgeInsetsInsetRect([super textRectForBounds:bounds], _textEdgeInsets);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    
	return [self textRectForBounds:bounds];
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
    
	CGRect rect = [super clearButtonRectForBounds:bounds];
	return CGRectMake(rect.origin.x + _clearButtonEdgeInsets.right, rect.origin.y + _clearButtonEdgeInsets.top, rect.size.width, rect.size.height);
}

@end
