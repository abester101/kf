//
//  RepeatingButton.m
//  KeyFeed
//
//  Created by Andrew Milham on 8/17/15.
//  Copyright (c) 2015 jackrogers. All rights reserved.
//

#import "RepeatingButton.h"

@interface RepeatingButton ()

@property (assign, nonatomic) NSTimeInterval beganPress;

@end

@implementation RepeatingButton

-(id)initWithCoder:(NSCoder*)aDecoder
{
    if(self=[super initWithCoder:aDecoder]) {
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

-(void)commonInit{
    [self addTarget:self action:@selector(beginTouch:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(endTouch:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    
    _autorepeatStartDelay = 0.25f;
    _autorepeatPressDelay = 0.07f;
}

-(void)beginTouch:(id)sender{
    _beganPress = [NSDate timeIntervalSinceReferenceDate];
    [self performTouchAction:sender];
    [self performSelector:@selector(performAutorepeat:) withObject:sender afterDelay:self.autorepeatStartDelay];
    
}

-(void)endTouch:(id)sender{
    _beganPress = 0;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performAutorepeat:) object:self];
}


-(void)performTouchAction:(id)sender{
    [self.repeatTarget performSelector:self.repeatTargetAction withObject:sender];
}

-(void)performAutorepeat:(id)sender
{
    if(self.autorepeatPressDelay<=0){
        self.autorepeatPressDelay = 0.07f;
    }
    if(_beganPress){
        [self performTouchAction:sender];
        [self performSelector:@selector(performAutorepeat:) withObject:sender afterDelay:self.autorepeatPressDelay];
    }
    
}

@end
