//
//  FakeTextField.m
//  KeyFeed
//
//  Created by Andrew Milham on 8/25/15.
//  Copyright (c) 2015 jackrogers. All rights reserved.
//

#import "FakeTextField.h"
#import "KeyButton.h"

@interface FakeTextField ()


@property (strong, nonatomic) UIButton *clearButton;

@property (strong, nonatomic) UIView *cursor;


@end

@implementation FakeTextField

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

-(void)commonInit{
    
    
    self.layer.cornerRadius = 8;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [UIColor colorWithWhite:0.9f alpha:1.0f].CGColor;
    self.layer.masksToBounds = YES;
    
    self.label = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 28, 0)];
    self.label.text = self.placeholder;
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.textColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
    self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.label];
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)]];
    
    self.clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.clearButton.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
    [self.clearButton setTitle:@"✕" forState:UIControlStateNormal];
    [self.clearButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [self.clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.clearButton addTarget:self action:@selector(tapClearButton:) forControlEvents:UIControlEventTouchUpInside];
    self.clearButton.frame = CGRectMake(self.bounds.size.width - (self.bounds.size.height - 8) - 6, 4, self.bounds.size.height - 8, self.bounds.size.height - 8);
    [self.clearButton setBackgroundImage:[[self.clearButton.backgroundColor darkerColor] image] forState:UIControlStateHighlighted];
    self.clearButton.layer.masksToBounds = YES;
    self.clearButton.hidden = YES;
    [self addSubview:self.clearButton];
    
    self.cursor = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1.5, 18)];
    self.cursor.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    self.cursor.hidden = YES;
    [self addSubview:self.cursor];
    
    [self pulseCursor];
}

-(void)pulseCursor{
    if(self.cursor.alpha==1.0f){
        [UIView animateWithDuration:0.1f delay:0.35 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            
            self.cursor.alpha = 0.0f;
            
        } completion:^(BOOL finished) {
            
            [self pulseCursor];
            
        }];
    } else {
        
        [UIView animateWithDuration:0.05f delay:0.2 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            
            self.cursor.alpha = 1.0f;
            
        } completion:^(BOOL finished) {
            
            [self pulseCursor];
            
        }];
        
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.label.frame = CGRectInset(self.bounds, 28, 0);
    self.clearButton.frame = CGRectMake(self.bounds.size.width - (self.bounds.size.height - 8) - 6, 4, self.bounds.size.height - 8, self.bounds.size.height - 8);
    self.clearButton.layer.cornerRadius = self.clearButton.frame.size.height/2;
}

-(void)setTextValue:(NSString *)textValue{
    _textValue = textValue;
    if(textValue.length){
        self.label.text = textValue;
        self.label.textColor = [UIColor blackColor];
        self.clearButton.hidden = NO;
    } else {
        if(!_showsCursor){
            self.label.text = _placeholder;
            self.clearButton.hidden = YES;
        } else {
            self.label.text = @"";
            self.clearButton.hidden = NO;
        }
        self.label.textColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
        
    }
    [self updateCursor];
}

-(void)setPlaceholder:(NSString *)placeholder{
    _placeholder = placeholder;
    if(![_textValue length]){
        self.label.text = placeholder;
        self.label.textColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
    }
}

-(void)setShowsCursor:(BOOL)showsCursor{
    _showsCursor = showsCursor;
    
    if(_showsCursor){
        if(self.textValue.length){
        
        } else {
            self.label.text = @"";
            
        }
        self.clearButton.hidden = NO;
    } else {
        if(!self.textValue.length){
            self.label.text = _placeholder;
            self.clearButton.hidden = YES;
        }
    }
    [self updateCursor];
}

-(void)updateCursor{
    if(_showsCursor){
        
        self.cursor.center = CGPointMake(self.bounds.size.width/2 + ([self.label.text sizeWithAttributes:@{NSFontAttributeName:self.label.font}].width/2) + 1, self.bounds.size.height/2);
        
        
        if(self.cursor.hidden){
            self.cursor.hidden = NO;
        }
    } else {
        if(!self.cursor.hidden){
            self.cursor.hidden = YES;
        }
    }
}

-(void)tapped:(UITapGestureRecognizer*)recognizer{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(tappedFakeTextField:)]){
        [self.delegate tappedFakeTextField:self];
    }
}

-(void)tapClearButton:(id)sender{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(tappedFakeTextFieldClearButton:)]){
        [self.delegate tappedFakeTextFieldClearButton:self];
    }
}

@end
