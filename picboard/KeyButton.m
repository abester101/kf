//
//  KeyButton.m
//  KeyFeed
//
//  Created by Andrew Milham on 8/25/15.
//  Copyright (c) 2015 jackrogers. All rights reserved.
//

#import "KeyButton.h"


@implementation  UIColor (KeyButton)

- (UIColor *)lighterColorRemoveSaturation:(CGFloat)removeS
                              resultAlpha:(CGFloat)alpha {
    CGFloat h,s,b,a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a]) {
        return [UIColor colorWithHue:h
                          saturation:MAX(s - removeS, 0.0)
                          brightness:b
                               alpha:alpha == -1? a:alpha];
    }
    return nil;
}

-(UIColor*)lighterColor {
    return [self lighterColorRemoveSaturation:0.5
                                  resultAlpha:-1];
}

-(UIColor*)darkerColor{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:b * 0.75
                               alpha:a];
    return nil;
}

-(UIColor*)inverseColor{
        CGFloat r,g,b,a;
        [self getRed:&r green:&g blue:&b alpha:&a];
        return [UIColor colorWithRed:1.-r green:1.-g blue:1.-b alpha:a];
}

-(UIImage*)image{
    CGRect rect = CGRectMake(0,0,1,1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,[self CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


@end



@implementation KeyButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)init{
    if(self=[super init]){
        [self commonInit];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if(self=[super initWithFrame:frame]){
        [self commonInit];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self=[super initWithCoder:aDecoder]){
        [self commonInit];
    }
    return self;
}

-(void)commonInit{
    //self.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    if(_titleColor){
        [self setTitleColor:_titleColor forState:UIControlStateNormal];
    }
    if(_highlightedTitleColor){
        [self setTitleColor:_highlightedTitleColor forState:UIControlStateHighlighted];
    }
    [self setTitle:_title forState:UIControlStateNormal];
//    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.layer.cornerRadius = 4;
    self.layer.masksToBounds = YES;
    self.clipsToBounds = YES;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:backgroundColor];
    if(!_highlightedBackgroundColor){
        self.highlightedBackgroundColor = [backgroundColor darkerColor];
    }
}

-(void)prepareForInterfaceBuilder{
    if(_titleColor){
        [self setTitleColor:_titleColor forState:UIControlStateNormal];
    }
    if(_highlightedTitleColor){
        [self setTitleColor:_highlightedTitleColor forState:UIControlStateHighlighted];
    }
    [self setTitle:_title forState:UIControlStateNormal];
}

-(void)setTitle:(NSString *)title{
    _title = title;
    
    [self setTitle:title forState:UIControlStateNormal];
}

-(void)setTitleColor:(UIColor *)titleColor{
    _titleColor = titleColor;
    [self setTitleColor:titleColor forState:UIControlStateNormal];
}

-(void)setHighlightedTitleColor:(UIColor *)highlightedTitleColor{
    _highlightedTitleColor = highlightedTitleColor;
    [self setTitleColor:highlightedTitleColor forState:UIControlStateHighlighted];
}

-(void)setHighlightedBackgroundColor:(UIColor *)highlightedBackgroundColor{
    _highlightedBackgroundColor = highlightedBackgroundColor;
    [self setBackgroundImage:[highlightedBackgroundColor image] forState:UIControlStateHighlighted];
}

@end
