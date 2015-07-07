//
//  KeyboardViewController.h
//  picboard
//
//  Created by John Rogers on 11/21/14.
//  Copyright (c) 2014 jackrogers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instagram.h"

#import "Reachability.h"
#import "DecimalViewController.h"
#import "Masonry.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#define APP_ID @"4efbf1dd9a1b4a058a4c3772876d9400"

@interface KeyboardViewController : UIInputViewController <IGSessionDelegate, NSURLConnectionDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) Instagram *instagram;
@property (strong, nonatomic) NSMutableArray *instaLinks;
@property (strong, nonatomic) NSMutableArray *instaNames;
@property (strong, nonatomic) NSMutableArray *instaText;
@property (strong, nonatomic) NSMutableArray *photoID;
@property (strong, nonatomic) NSMutableArray *hearts;
@property (strong, nonatomic) UIScrollView *instaScrollView;
@property (strong, nonatomic) UIActivityIndicatorView *loadingSpinner;
@property (strong, nonatomic) UIButton *backspaceButton;
@property (nonatomic) BOOL loggedInInsta;
@property (nonatomic) BOOL reachable;
@property (nonatomic) BOOL loadingNewImages;
@property (nonatomic) int numberOfImagesAlreadyLoaded;
@property (nonatomic) BOOL decimalKeyboardLoaded;

@end
