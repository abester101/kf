//
//  KeyButton.h
//  KeyFeed
//
//  Created by Andrew Milham on 8/25/15.
//  Copyright (c) 2015 jackrogers. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface KeyButton : UIButton

@property (strong, nonatomic) IBInspectable NSString *title;

@property (strong, nonatomic) IBInspectable UIColor *titleColor;

@property (strong, nonatomic) IBInspectable UIColor *highlightedTitleColor;

@property (strong, nonatomic) IBInspectable UIColor *highlightedBackgroundColor;

@end


@interface UIColor (KeyButton)

-(UIColor*)lighterColorRemoveSaturation:(CGFloat)removeS resultAlpha:(CGFloat)alpha;
-(UIColor*)lighterColor;
-(UIColor*)darkerColor;
-(UIColor*)inverseColor;

-(UIImage*)image;

@end