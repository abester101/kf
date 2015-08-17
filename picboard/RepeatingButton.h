//
//  RepeatingButton.h
//  KeyFeed
//
//  Created by Andrew Milham on 8/17/15.
//  Copyright (c) 2015 jackrogers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepeatingButton : UIButton

@property (assign, atomic) NSTimeInterval autorepeatStartDelay;
@property (assign, nonatomic) NSTimeInterval autorepeatPressDelay;

@property (weak, nonatomic) id<NSObject> repeatTarget;
@property (assign, nonatomic) SEL repeatTargetAction;


@end
