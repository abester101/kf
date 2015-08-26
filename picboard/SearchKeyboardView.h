//
//  SearchKeyboardView.h
//  KeyFeed
//
//  Created by Andrew Milham on 8/25/15.
//  Copyright (c) 2015 jackrogers. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SearchKeyboardViewDelegate;
@interface SearchKeyboardView : UIView

@property (strong, nonatomic) UITextField *textField;

@property (weak, nonatomic) id<SearchKeyboardViewDelegate> delegate;

@end


@protocol SearchKeyboardViewDelegate <NSObject>

@optional

-(void)searchKeyboardTappedGo:(SearchKeyboardView*)searchKeyboardView;
-(void)searchKeyboard:(SearchKeyboardView*)searchKeyboardView tappedKey:(NSString*)key;

@end