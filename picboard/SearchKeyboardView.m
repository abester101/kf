//
//  SearchKeyboardView.m
//  KeyFeed
//
//  Created by Andrew Milham on 8/25/15.
//  Copyright (c) 2015 jackrogers. All rights reserved.
//

#import "SearchKeyboardView.h"
#import "KeyButton.h"

@interface SearchKeyboardView ()

@property (strong, nonatomic) IBOutletCollection(KeyButton) NSArray *keyButtons;
@property (strong, nonatomic) IBOutlet KeyButton *goButton;
@property (strong, nonatomic) IBOutlet KeyButton *hashButton;

@end


@implementation SearchKeyboardView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self=[super initWithCoder:aDecoder]){
        [self commonInit];
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.goButton.titleLabel.font = [UIFont boldSystemFontOfSize:18]; //[UIFont fontWithName:@"Hiragino Kaku Gothic ProN" size:18]; //
    //[self.goButton setTitle:[[NSString alloc] initWithUTF8String:"\xF0\x9F\x94\x8D"]];
    //[self.goButton setTitle:@"GO"];

    self.hashButton.titleLabel.font = [UIFont boldSystemFontOfSize:22];
}

-(void)commonInit{
    
}

-(void)setTextField:(UITextField *)textField{
    _textField = textField;
}

- (IBAction)tapKeyButton:(KeyButton *)sender {
    if(self.delegate&&[self.delegate respondsToSelector:@selector(searchKeyboard:tappedKey:)]){
        [self.delegate searchKeyboard:self tappedKey:sender.title.lowercaseString];
    }
}


- (IBAction)tapGo:(id)sender {
    if(self.delegate&&[self.delegate respondsToSelector:@selector(searchKeyboardTappedGo:)]){
        [self.delegate searchKeyboardTappedGo:self];
    }
}

@end
