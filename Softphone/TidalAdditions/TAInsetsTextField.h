//
//  TAInsetsTextField.h
//
//  Created by Tidal ArtWorks on 21/02/13.
//  Copyright (c) 2013 Tidal ArtWorks. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Class -

@interface TAInsetsTextField : UITextField

{} // Only here to avoid problem in XCode navigator

#pragma mark - Properties -

@property (assign, nonatomic) UIEdgeInsets textEdgeInsets;
@property (assign, nonatomic) UIEdgeInsets clearButtonEdgeInsets;

@end
