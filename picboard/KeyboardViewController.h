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
#import "Masonry.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#define APP_GROUP @"group.KeyFeed.KeyFeed"

#define APP_ID @"4efbf1dd9a1b4a058a4c3772876d9400"
#define PROMO_TEXT @"\n\nSent via KeyFeed - www.apple.co/1DbnRU3"

#import "RepeatingButton.h"


@interface InstagramObject : NSObject

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *caption;
@property (strong, nonatomic) NSString *link;
@property (strong, nonatomic) NSString *photoID;
@property (strong, nonatomic) NSString *photoURLString;
@property (assign, nonatomic) BOOL liked;

@property (strong, nonatomic) NSString *localPhoto;

-(instancetype)initWithUsername:(NSString*)username caption:(NSString*)caption link:(NSString*)link photoID:(NSString*)photoID localPhoto:(NSString*)localPhoto;

@end


@interface KeyboardViewController : UIInputViewController <IGSessionDelegate, NSURLConnectionDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) Instagram *instagram;

@property (strong, nonatomic) NSMutableOrderedSet *instagramObjects;

@property (strong, nonatomic) NSMutableArray *instaLinks;
@property (strong, nonatomic) NSMutableArray *instaNames;
@property (strong, nonatomic) NSMutableArray *instaText;
@property (strong, nonatomic) NSMutableArray *instaImageUrls;
@property (strong, nonatomic) NSMutableArray *photoID;
@property (strong, nonatomic) NSMutableArray *hearts;
@property (strong, nonatomic) UIScrollView *instaScrollView;
@property (strong, nonatomic) UIActivityIndicatorView *loadingSpinner;
@property (strong, nonatomic) RepeatingButton *backspaceButton;
@property (strong, nonatomic) UIView *shareInstructionView;
@property (strong, nonatomic) UILabel *shareInstructionLabel;
@property (strong, nonatomic) NSTimer *shareInstructionTimer;
@property (nonatomic) BOOL loggedInInsta;
@property (nonatomic) BOOL reachable;
@property (nonatomic) BOOL loadingNewImages;
@property (nonatomic) int numberOfImagesAlreadyLoaded;
@property (nonatomic) BOOL decimalKeyboardLoaded;
@property (nonatomic) BOOL halfFrame;

@end
