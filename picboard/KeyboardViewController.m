
//
//  KeyboardViewController.m
//  picboard
//
//  Created by John Rogers on 11/21/14.
//  Copyright (c) 2014 jackrogers. All rights reserved.
//

#import "KeyboardViewController.h"
#import "Heap.h"

@interface KeyboardViewController ()
@property (nonatomic, strong) UIButton *nextKeyboardButton;
@property (nonatomic, strong) NSMutableArray *keyboardButtons;
@property (nonatomic, strong) NSArray *symbols;
@property (nonatomic, strong) UILabel *textLabelFullAccess;
@property (nonatomic, strong) UILabel *textLabelFullAccess2;
@end

@implementation KeyboardViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    // Add custom view sizing constraints here
}

- (BOOL)isOpenAccessGranted
{
    return [UIPasteboard generalPasteboard];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Fabric with:@[CrashlyticsKit]];
    
    [Heap setAppId:@"727469615"];
    
    // Visualizer can't be enabled in keyboard extension
#ifdef DEBUG
//    [Heap enableVisualizer];
#endif
    
    
    // Allocate a reachability object
    _instaLinks = [NSMutableArray array];
    _instaNames = [NSMutableArray array];
    _instaText = [NSMutableArray array];
    _photoID = [NSMutableArray array];
    _numberOfImagesAlreadyLoaded = 0;
    
    double width = [[UIScreen mainScreen] bounds].size.width;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    // Perform custom UI setup here
    
    UIImage *globeImage = [UIImage imageNamed:@"backbutton.png"];
    
    self.nextKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nextKeyboardButton.frame = CGRectMake(0.0, 0.0, 37.0, 33.0);
    [self.nextKeyboardButton setBackgroundImage:globeImage forState:UIControlStateNormal];
    [self.nextKeyboardButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.nextKeyboardButton addTarget:self action:@selector(nextInputMode:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.nextKeyboardButton];
    
    NSLayoutConstraint *nextKeyboardButtonLeftSideConstraint = [NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:8.0];
    NSLayoutConstraint *nextKeyboardButtonBottomConstraint = [NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.view bringSubviewToFront:self.nextKeyboardButton];
    [self.view addConstraints:@[nextKeyboardButtonLeftSideConstraint, nextKeyboardButtonBottomConstraint]];
    
    self.loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:self.loadingSpinner];
    [self.loadingSpinner startAnimating];
    [self.loadingSpinner setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSLayoutConstraint *centerXConstraint =
    [NSLayoutConstraint constraintWithItem:self.loadingSpinner
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.0
                                  constant:0.0];
    NSLayoutConstraint *spinnerBottomConstraint = [NSLayoutConstraint constraintWithItem:self.loadingSpinner
                                                                               attribute:NSLayoutAttributeBottom
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.view
                                                                               attribute:NSLayoutAttributeBottom
                                                                              multiplier:1.0
                                                                                constant:-9.0];
    [self.view bringSubviewToFront:self.loadingSpinner];
    [self.view addConstraints:@[centerXConstraint, spinnerBottomConstraint]];
    
    _backspaceButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 21)];
    [_backspaceButton setBackgroundImage:[UIImage imageNamed:@"backspace"] forState:UIControlStateNormal];
    [_backspaceButton addTarget:self action:@selector(backspacePressed:) forControlEvents:UIControlEventTouchUpInside];
    [_backspaceButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:_backspaceButton];
    
    NSLayoutConstraint *backspaceRightConstraint =
    [NSLayoutConstraint constraintWithItem:_backspaceButton
                                 attribute:NSLayoutAttributeRight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeRight
                                multiplier:1.0
                                  constant:-4.0];
    NSLayoutConstraint *backspaceBottomConstraint = [NSLayoutConstraint constraintWithItem:_backspaceButton
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self.view
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                multiplier:1.0
                                                                                  constant:-5.0];
    [self.view addConstraints:@[backspaceRightConstraint, backspaceBottomConstraint]];
    [self.view bringSubviewToFront:_backspaceButton];
    
    _instaScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, 180)];
    _instaScrollView.delegate = self;
    [self.view addSubview:_instaScrollView];
    
    if (![self isOpenAccessGranted]) {
        [self displayFullAccessMessage];
    } else {
        Reachability *reach = [Reachability reachabilityWithHostname:@"www.google.com"];
        reach.reachableBlock = ^(Reachability*reach) {
            NSString *sessionKey = [[[NSUserDefaults alloc] initWithSuiteName:@"group.KeyFeed.KeyFeed"] objectForKey:@"accessToken"];
            if (!sessionKey) {
                [self displayLoginToInstagramMessage];
            } else {
                if (sessionKey) {
                    _textLabelFullAccess.hidden = YES;
                    _textLabelFullAccess2.hidden = YES;
                    for (UIButton *button in _keyboardButtons) {
                        button.hidden = YES;
                    }
                    [self getPicsFromInsta];
                    _reachable = YES;
                }
            }
        };
        reach.unreachableBlock = ^(Reachability*reach) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!_decimalKeyboardLoaded) {
                    [self loadDecimalKeyboard];
                    _decimalKeyboardLoaded = YES;
                }
                _textLabelFullAccess = [[UILabel alloc] initWithFrame:CGRectMake(12, 125, (width/2)-6, 80)];
                _textLabelFullAccess.text = @"Please check your internet connection.";
                _textLabelFullAccess.font = [UIFont systemFontOfSize:14];
                _textLabelFullAccess.numberOfLines = 0;
                [self.view addSubview:_textLabelFullAccess];
                self.loadingSpinner.hidden = YES;
                _reachable = NO;
            });
        };
        reach.failedBlock = ^(Reachability*reach) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self displayFullAccessMessage];
            });
        };
        [reach startNotifier];
    }
}

- (void)displayFullAccessMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        double width = [[UIScreen mainScreen] bounds].size.width;
        _textLabelFullAccess = [[UILabel alloc] initWithFrame:CGRectMake(12, 125, (width/2)-6, 40)];
        _textLabelFullAccess.text = @"Please enable full access. See instructions in main app.";
        _textLabelFullAccess.numberOfLines = 0;
        _textLabelFullAccess.font = [UIFont systemFontOfSize:12];
        [self.view addSubview:_textLabelFullAccess];
        [self.view addSubview:_textLabelFullAccess2];
        self.loadingSpinner.hidden = YES;
        if (!_decimalKeyboardLoaded) {
            [self loadDecimalKeyboard];
        }
        _decimalKeyboardLoaded = YES;
    });
}

- (void)displayLoginToInstagramMessage {
    NSString *sessionKey = [[[NSUserDefaults alloc] initWithSuiteName:@"group.KeyFeed.KeyFeed"] objectForKey:@"accessToken"];
    if (!sessionKey) {
        _loggedInInsta = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            double width = [[UIScreen mainScreen] bounds].size.width;
            _textLabelFullAccess = [[UILabel alloc] initWithFrame:CGRectMake(12, 125, (width/2)-6, 40)];
            _textLabelFullAccess.text = @"Please log in to instagram.";
            _textLabelFullAccess2 = [[UILabel alloc] initWithFrame:CGRectMake(12, 145, (width/2)-6, 40)];
            _textLabelFullAccess2.text = @"See instructions in main app.";
            _textLabelFullAccess.textColor = [UIColor colorWithWhite:0.70 alpha:1.0];
            _textLabelFullAccess2.textColor = [UIColor colorWithWhite:0.70 alpha:1.0];
            [self.view addSubview:_textLabelFullAccess];
            [self.view addSubview:_textLabelFullAccess2];
            self.loadingSpinner.hidden = YES;
            if (!_decimalKeyboardLoaded) {
                [self loadDecimalKeyboard];
            }
            _decimalKeyboardLoaded = YES;
        });
    } else {
        _loggedInInsta = YES;
    }
}

- (void)loadDecimalKeyboard {
    NSLog(@"load decimal keyboard");
    NSArray *rows = @[@[@"onebutton.png", @"twobutton.png", @"threebutton.png", @"fourbutton.png"], @[@"fivebutton.png", @"sixbutton.png", @"sevenbutton.png", @"eightbutton.png"], @[@"ninebutton.png", @"zerobutton.png", @"^button.png", @"asteriskbutton.png"], @[@"+button.png", @"dashbutton.png", @"slashbutton.png", @"=button.png"]];
    _symbols = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0", @"^", @"*", @"+", @"-", @"/", @"="];
    
    double width = [[UIScreen mainScreen] bounds].size.width;
    int dist = (width - 230)/8;
    
    int rowNumber = 0;
    int counter = 0;
    for (NSArray *row in rows) {
        for (int i=0; i<row.count; i++) {
            NSString *buttonName = row[i];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.view addSubview:button];
            button.frame = CGRectMake(0, 46*rowNumber, 28.0, 25.0);
            [button setBackgroundImage:[UIImage imageNamed:buttonName] forState:UIControlStateNormal];
            [button setTranslatesAutoresizingMaskIntoConstraints:NO];
            button.tag = counter;
            [button addTarget:self action:@selector(insertSymbol:) forControlEvents:UIControlEventTouchUpInside];
            [_keyboardButtons addObject:button];
            [self.view bringSubviewToFront:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_top).with.offset(5.0 + 34*rowNumber); //with is an optional semantic filler
                make.left.equalTo(self.view.mas_left).with.offset(6 + (dist+28)*i);
            }];
            counter++;
        }
        rowNumber++;
    }
    [self getSamplePics];

}

- (void)insertSymbol:(id)sender {
    UIButton *button = (UIButton *)sender;
    int tag = (int)button.tag;
    [self.textDocumentProxy insertText:[_symbols objectAtIndex:tag]];
}

- (void)backspacePressed:(id)sender {
    [self.textDocumentProxy deleteBackward];
}

- (void)nextInputMode:(id)sender {
    [self advanceToNextInputMode];
}

- (BOOL)didLikePhoto:(NSString*)mediaID me:(NSString*)myID {
    
    NSString *sessionKey = [[[NSUserDefaults alloc] initWithSuiteName:@"group.KeyFeed.KeyFeed"] objectForKey:@"accessToken"];
    NSString *url = [NSString stringWithFormat:@"https://api.instagram.com/v1/media/%@/likes?access_token=%@", mediaID, sessionKey];
    NSURL *urlData = [NSURL URLWithString:url];
    NSError *error;
    NSString *page = [NSString stringWithContentsOfURL:urlData
                                              encoding:NSASCIIStringEncoding
                                                 error:&error];
    NSData *data = [page dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
    for (id user in [jsonResponse objectForKey:@"data"]) {
        if ([[user objectForKey:@"id"] isEqualToString:myID]) {
            return YES;
        }
    }
    return NO;
}

- (NSString*)getSelf {
    NSString *sessionKey = [[[NSUserDefaults alloc] initWithSuiteName:@"group.KeyFeed.KeyFeed"] objectForKey:@"accessToken"];
    NSString *url = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/self?access_token=%@", sessionKey];
    NSURL *urlData = [NSURL URLWithString:url];
    NSError *error;
    NSString *page = [NSString stringWithContentsOfURL:urlData
                                              encoding:NSASCIIStringEncoding
                                                 error:&error];
    NSData *data = [page dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
    
    return [[jsonResponse objectForKey:@"data"] objectForKey:@"id"];
}

- (void)addPhotoButton:(NSString*)nameOfImage {
    UIButton *instaButton = [UIButton buttonWithType:UIButtonTypeCustom];
    instaButton.frame = CGRectMake((150 * _numberOfImagesAlreadyLoaded) + 10, 0, 140, 140);
    [instaButton setBackgroundImage:[UIImage imageNamed:nameOfImage] forState:UIControlStateNormal];
    [instaButton setTag:_numberOfImagesAlreadyLoaded];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageButtonPressed:)];
    singleTap.numberOfTapsRequired = 1;
    [instaButton addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoLiked:)];
    doubleTap.numberOfTapsRequired = 2;
    [instaButton addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    UILabel *textView = [[UILabel alloc] initWithFrame:CGRectMake((150 * _numberOfImagesAlreadyLoaded) + 10, 140, 120, 16)];
    textView.text = [_instaNames objectAtIndex:_numberOfImagesAlreadyLoaded];
    textView.textColor = [UIColor colorWithRed:16/255.0f green:56/255.0f blue:138/255.0f alpha:1.0f];
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont systemFontOfSize:14];
    
    UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(150 * _numberOfImagesAlreadyLoaded + 5, 160, 120, 20)];
    description.text = [_instaText objectAtIndex:_numberOfImagesAlreadyLoaded];
    description.textColor = [UIColor blackColor];
    [_instaScrollView addSubview:instaButton];
    [_instaScrollView addSubview:description];
    [_instaScrollView addSubview:textView];
    description.font = [UIFont systemFontOfSize:14];
    [self.view bringSubviewToFront:self.nextKeyboardButton];
    [self.view sendSubviewToBack:_instaScrollView];
    _numberOfImagesAlreadyLoaded++;
}

- (void)getSamplePics {
    [_instaLinks addObject:@"http://instagram.com/p/xMwv8DQ1eT"];
    [_instaNames addObject:@"biddythehedgehog"];
    [_instaText addObject:@"Thanks @triciakibler for making me look so good!!! #biddythehedgehog #biddythehedgehogart #ink #watercolor #triciapaints"];
    [_instaLinks addObject:@"http://instagram.com/p/w6q99qoaJa"];
    [_instaNames addObject:@"nasa"];
    [_instaText addObject:@"Holiday Lights on the Sun: The sun emitted a significant solar flare, peaking at 7:28 p.m. EST on Dec. 19, 2014. Our Solar Dynamics Observatory, which watches the sun constantly, captured an image of the event. Solar flares are powerful bursts of radiation. Harmful radiation from a flare cannot pass through Earth's atmosphere to physically affect humans on the ground, however -- when intense enough -- they can disturb the atmosphere in the layer where GPS and communications signals travel. This flare is classified as an X1.8-class flare. X-class denotes the most intense flares, while the number provides more information about its strength. An X2 is twice as intense as an X1, an X3 is three times as intense, etc."];
    [_instaLinks addObject:@"http://instagram.com/p/wrx-Y5wii3"];
    [_instaNames addObject:@"whitehouse"];
    [_instaText addObject:@"President Obama just took action to protect one of our greatest national treasures: Alaska's Bristol Bay."];
    [_instaLinks addObject:@"http://instagram.com/p/vtWKGmyo9E"];
    [_instaNames addObject:@"vervecoffee"];
    [_instaText addObject:@"Nobody inspires adventure and exploration like @chrisburkard . Join us tonight 6/22 6-9pm @sawyersupply as he presents some of his journeys to the Arctic, Tahiti and beyond."];
    [_instaLinks addObject:@"http://instagram.com/p/w6yu9BPxkk"];
    [_instaNames addObject:@"santacruzbicycles"];
    [_instaText addObject:@"Check out this custom #5010CC build from @sohobikeslondon. Highlights include a custom painted 5010CC frame in neon orange, @rockshox suspension and post, XTR Di2 2x11 (single shifter), @chriskingbuzz headset and hubs with @envecomposites M60 rims. Stunning."];
    [_instaLinks addObject:@"http://instagram.com/p/wuLLrMFZ2x"];
    [_instaNames addObject:@"santacruzskateboards"];
    [_instaText addObject:@"Yard Sale! #SantaCruzSkateboards AM Cody Chapman (@coldchapman) snaps an Ollie off of a few recycled goods in the city. 📷:@michaelmcd | @nhs_inc |"];
    [_instaLinks addObject:@"http://instagram.com/p/vo5dXhJfnl"];
    [_instaNames addObject:@"ucsc"];
    [_instaText addObject:@"#TBT Kresge students on a road trip to San Francisco in a classic VW van, circa 1974 #tbtucsc"];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self addPhotoButton:@"hedgehog1.jpg"];
        [self addPhotoButton:@"gasball.jpg"];
        [self addPhotoButton:@"whale.jpg"];
        [self addPhotoButton:@"undersea.jpg"];
        [self addPhotoButton:@"orange.jpg"];
        [self addPhotoButton:@"skateboards.jpg"];
        [self addPhotoButton:@"kresge.jpg"];
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadingSpinner.hidden = YES;
        _loadingNewImages = NO;
        _halfFrame = YES;
        _instaScrollView.contentSize = CGSizeMake(150 * _numberOfImagesAlreadyLoaded, _instaScrollView.contentSize.height);
        _instaScrollView.frame = CGRectMake(_instaScrollView.frame.size.width/2, 0, _instaScrollView.frame.size.width/2, _instaScrollView.frame.size.height);
    });
}

- (void)getPicsFromInsta {
    _halfFrame = NO;
    self.loadingSpinner.hidden = NO;
    NSString *sessionKey = [[[NSUserDefaults alloc] initWithSuiteName:@"group.KeyFeed.KeyFeed"] objectForKey:@"accessToken"];
    NSLog(@"session key: %@", sessionKey);
    NSString *url;
    if (_photoID.count > 0) {
        url = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@&count=7&max_id=%@", sessionKey, [_photoID lastObject]];
    } else {
        url = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@&count=7", sessionKey];
    }
    
    NSURL *nsurl=[NSURL URLWithString:url];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSString *sessionKey = [[[NSUserDefaults alloc] initWithSuiteName:@"group.KeyFeed.KeyFeed"] objectForKey:@"accessToken"];
        NSLog(@"session key: %@", sessionKey);
        if (sessionKey.length > 0) {
            NSError *error;
            NSString *page = [NSString stringWithContentsOfURL:nsurl
                                                      encoding:NSASCIIStringEncoding
                                                         error:&error];
            NSData *data = [page dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:kNilOptions
                                                                           error:&error];
            for (id obj in [jsonResponse objectForKey:@"data"]) {
                [_instaLinks addObject:[obj objectForKey:@"link"]];
                [_instaNames addObject:[[obj objectForKey:@"user"] objectForKey:@"username"]];
                if ([obj objectForKey:@"caption"] != [NSNull null]) {
                    [_instaText addObject:[[obj objectForKey:@"caption"] objectForKey:@"text"]];
                } else {
                    [_instaText addObject:@""];
                }
                [_photoID addObject:[obj objectForKey:@"id"]];
                NSString *imageURL = [[[obj objectForKey:@"images"] objectForKey:@"low_resolution"] objectForKey:@"url"];
                NSString *url2 = imageURL;
                NSURL *nsurl2=[NSURL URLWithString:url2];
                NSData *imageData = [NSData dataWithContentsOfURL:nsurl2];
                UIImage *image = [UIImage imageWithData:imageData];
                NSString *myID = [self getSelf];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake((150 * _numberOfImagesAlreadyLoaded) + 5, 140, 130, 200)];
                    
                    UIButton *instaButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    instaButton.frame = CGRectMake((150 * _numberOfImagesAlreadyLoaded) + 10, 0, 140, 140);
                    [instaButton setBackgroundImage:image forState:UIControlStateNormal];
                    [instaButton setTag:_numberOfImagesAlreadyLoaded];
                    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageButtonPressed:)];
                    singleTap.numberOfTapsRequired = 1;
                    [instaButton addGestureRecognizer:singleTap];
                    
                    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoLiked:)];
                    doubleTap.numberOfTapsRequired = 2;
                    [instaButton addGestureRecognizer:doubleTap];
                    
                    [singleTap requireGestureRecognizerToFail:doubleTap];
                    UILabel *textView = [[UILabel alloc] initWithFrame:CGRectMake(5, 8, 120, 16)];
                    textView.text = [_instaNames objectAtIndex:_numberOfImagesAlreadyLoaded];
                    textView.textColor = [UIColor colorWithRed:16/255.0f green:56/255.0f blue:138/255.0f alpha:1.0f];
                    textView.backgroundColor = [UIColor clearColor];
                    textView.font = [UIFont systemFontOfSize:14];
                    
                    
                    UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(5, 22, 120, 20)];
                    [description setNumberOfLines:0];
                    description.font = [UIFont systemFontOfSize:14];
                    description.text = [_instaText objectAtIndex:_numberOfImagesAlreadyLoaded];
                    CGSize maximumLabelSize = CGSizeMake(120, FLT_MAX);
                    
                    CGSize expectedLabelSize = [description.text sizeWithFont:description.font constrainedToSize:maximumLabelSize lineBreakMode:description.lineBreakMode];
                    
                    //adjust the label the the new height.
                    CGRect newFrame = description.frame;
                    newFrame.size.height = expectedLabelSize.height;
                    description.frame = newFrame;
                    description.textColor = [UIColor blackColor];
                    [scrollView addSubview:textView];
                    [scrollView addSubview:description];
                    [scrollView setFrame:CGRectMake((150 * _numberOfImagesAlreadyLoaded) + 10, 140, 120, 50)];
                    [scrollView setContentSize:CGSizeMake(120, description.frame.size.height + 35)];
                    [_instaScrollView addSubview:instaButton];
                    [_instaScrollView addSubview:scrollView];
                    if ([self didLikePhoto:[obj objectForKey:@"id"] me:myID]) {
                        NSLog(@"did like photo");
                        UIImageView *heart = [[UIImageView alloc] initWithFrame:CGRectMake(instaButton.center.x - 20, instaButton.center.y - 18, 40, 35)];
                        heart.image = [UIImage imageNamed:@"heart"];
                        [_instaScrollView addSubview:heart];
                        [_hearts addObject:heart];
                    }
                    
                    [self.view bringSubviewToFront:self.nextKeyboardButton];
                    [self.view sendSubviewToBack:_instaScrollView];
                    [_instaScrollView bringSubviewToFront:scrollView];
                    _numberOfImagesAlreadyLoaded++;
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.loadingSpinner.hidden = YES;
                _loadingNewImages = NO;
                _instaScrollView.contentSize = CGSizeMake(150 * _numberOfImagesAlreadyLoaded, _instaScrollView.contentSize.height);
                for (id heart in _hearts) {
                    [_instaScrollView addSubview:heart];
                }
            });
        }
    });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _instaScrollView) {
        if (_reachable) {
            if (scrollView.contentOffset.x > (scrollView.contentSize.width - self.view.frame.size.width)) {
                [self loadMoreImages];
            }
        }
    }
}

- (void)loadMoreImages {
    if (!_loadingNewImages) {
        _loadingNewImages = YES;
        [self getPicsFromInsta];
    }
}

- (void)imageButtonPressed:(id)sender {
    UIButton *button = (UIButton*)[sender view];
    NSInteger tag = button.tag;
    NSLog(@"image pressed with tag: %ld", (long)tag);
    [self.textDocumentProxy insertText:[NSString stringWithFormat:@"%@ %@ ", [_instaLinks objectAtIndex:tag], PROMO_TEXT]];
}

- (void)photoLiked:(id)sender {
    UIButton *button = (UIButton*)[sender view];
    UIImageView *heart = [[UIImageView alloc] initWithFrame:CGRectMake(button.center.x - 20, button.center.y - 18, 40, 35)];
    heart.image = [UIImage imageNamed:@"heart"];
    [_instaScrollView addSubview:heart];
    
    NSInteger tag = button.tag;
    NSLog(@"photo liked with tag: %ld", (long)tag);
    
    //curl -F 'access_token=ACCESS-TOKEN' \
    //https://api.instagram.com/v1/media/{media-id}/likes

    NSString *sessionKey = [[[NSUserDefaults alloc] initWithSuiteName:@"group.KeyFeed.KeyFeed"] objectForKey:@"accessToken"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/media/%@/likes", [_photoID objectAtIndex:tag]]]];
    
    request.HTTPMethod = @"POST";
    NSString *post = [NSString stringWithFormat:@"access_token=%@", sessionKey];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    if(conn) {
        NSLog(@"Connection Successful");
    } else {
        NSLog(@"Connection could not be made");
    }

}

- (void)portrait {
    double width = [[UIScreen mainScreen] bounds].size.width;
    CGRect scrollFrame;
    if (_halfFrame) {
        scrollFrame.origin = _instaScrollView.frame.origin;
        scrollFrame.origin.x = width/2;
        scrollFrame.size = CGSizeMake(self.view.frame.size.width, 180);
        _textLabelFullAccess.frame = CGRectMake(12, 125, (width/2)-6, 80);
    } else {
        scrollFrame.origin = _instaScrollView.frame.origin;
        scrollFrame.size = CGSizeMake(self.view.frame.size.width, 180);
    }
    _instaScrollView.contentSize = CGSizeMake(_instaScrollView.contentSize.width, 180);
    _instaScrollView.frame = scrollFrame;
}

- (void)landscape {
    double width = [[UIScreen mainScreen] bounds].size.width;
    CGRect scrollFrame;
    if (_halfFrame) {
        scrollFrame.origin = _instaScrollView.frame.origin;
        scrollFrame.size = CGSizeMake(self.view.frame.size.width, 125);
        scrollFrame.origin.x = width/2;
        _textLabelFullAccess.frame = CGRectMake(168, 0, (width/4)-18, 80);
    } else {
        scrollFrame.origin = _instaScrollView.frame.origin;
        scrollFrame.size = CGSizeMake(self.view.frame.size.width, 125);
    }
    _instaScrollView.contentSize = CGSizeMake(_instaScrollView.contentSize.width, 125);
    _instaScrollView.frame = scrollFrame;
}

-(void)viewDidLayoutSubviews {
    if (self.view.frame.size.width == ([[UIScreen mainScreen] bounds].size.width*([[UIScreen mainScreen] bounds].size.width<[[UIScreen mainScreen] bounds].size.height))+([[UIScreen mainScreen] bounds].size.height*([[UIScreen mainScreen] bounds].size.width>[[UIScreen mainScreen] bounds].size.height))) {
        [self portrait];
    } else {
        [self landscape];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    
    UIColor *textColor = nil;
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
    [self.nextKeyboardButton setTitleColor:textColor forState:UIControlStateNormal];
}



//NSURL delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    NSLog(@"did recieve response");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    NSLog(@"did recieve data");
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSLog(@"did finish loading");
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"connection did fail");
}



@end
