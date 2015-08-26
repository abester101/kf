//
//  FakeTextField.h
//  KeyFeed
//
//  Created by Andrew Milham on 8/25/15.
//  Copyright (c) 2015 jackrogers. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FakeTextFieldDelegate;

@interface FakeTextField : UIView

@property (strong, nonatomic) NSString *textValue;
@property (strong, nonatomic) NSString *placeholder;

@property (strong, nonatomic) id<FakeTextFieldDelegate> delegate;

@property (strong, nonatomic) UILabel *label;

@property (assign, nonatomic) BOOL showsCursor;

@end

@protocol FakeTextFieldDelegate <NSObject>

@optional

-(void)tappedFakeTextField:(FakeTextField*)fakeTextField;
-(void)tappedFakeTextFieldClearButton:(FakeTextField*)fakeTextField;

@end