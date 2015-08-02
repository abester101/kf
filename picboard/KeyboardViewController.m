
//
//  KeyboardViewController.m
//  picboard
//
//  Created by John Rogers on 11/21/14.
//  Copyright (c) 2014 jackrogers. All rights reserved.
//

#import "KeyboardViewController.h"
#import "Heap.h"
#import "InstagramPhotoCollectionViewCell.h"

#define IsEqual(x,y) ((x&&y&&[x isEqual:y])||(!x&&!y)||x==y)

@implementation InstagramObject

-(instancetype)initWithUsername:(NSString *)username caption:(NSString *)caption link:(NSString *)link photoID:(NSString *)photoID localPhoto:(NSString *)localPhoto{
    if(self=[super init]){
        _username = username;
        _caption = caption;
        _link = link;
        _photoID = photoID;
        _localPhoto = localPhoto;
    }
    return self;
}

-(void)setUsername:(NSString *)username{
    if(![username isKindOfClass:[NSNull class]]){
        _username = username;
    }
}
-(void)setCaption:(NSString *)caption{
    if(![caption isKindOfClass:[NSNull class]]){
        _caption = caption;
    }
}
-(void)setLink:(NSString *)link{
    if(![link isKindOfClass:[NSNull class]]){
        _link = link;
    }
}
-(void)setPhotoID:(NSString *)photoID{
    if(![photoID isKindOfClass:[NSNull class]]){
        _photoID = photoID;
    }
}
-(void)setLocalPhoto:(NSString *)localPhoto{
    if(![localPhoto isKindOfClass:[NSNull class]]){
        _localPhoto = localPhoto;
    }
}

- (NSUInteger)hash {
    if(self.link.length){
        return [self.link hash];
    } else if(self.username.length){
        return [self.username hash];
    } else {
        return [super hash];
    }
}

-(BOOL)isEqual:(id)object{
    InstagramObject *obj = object;
    return [object isKindOfClass:[self class]] && IsEqual(self.username,obj.username) && IsEqual(self.caption, obj.caption) && IsEqual(self.link, obj.link) && IsEqual(self.photoID, obj.photoID) && IsEqual(self.localPhoto, obj.localPhoto);
}

@end

@interface KeyboardViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,InstagramPhotoCollectionViewCellDelegate>

@property (nonatomic, strong) UIButton *nextKeyboardButton;
@property (nonatomic, strong) NSMutableArray *keyboardButtons;
@property (nonatomic, strong) NSArray *symbols;
@property (nonatomic, strong) UILabel *textLabelFullAccess;
@property (nonatomic, strong) UILabel *textLabelFullAccess2;

@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) NSString *selfID;

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
    

    
    _instagramObjects = [NSMutableOrderedSet orderedSet];
    
    
    
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
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 4, 0);
//    layout.estimatedItemSize = CGSizeMake(140, 180);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 184) collectionViewLayout:layout];

    
    [self.collectionView registerNib:[UINib nibWithNibName:@"InstagramPhotoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"InstagramPhoto"];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, -1, 0);
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.view addSubview:self.collectionView];
    
    
    if (![self isOpenAccessGranted]) {
        [self displayFullAccessMessage];
    } else {
        Reachability *reach = [Reachability reachabilityWithHostname:@"www.google.com"];
        reach.reachableBlock = ^(Reachability*reach) {
            
            [Heap setAppId:@"727469615"];
            
#ifdef DEBUG
            [Heap startDebug];
#endif
            
            NSString *sessionKey = [[[NSUserDefaults alloc] initWithSuiteName:APP_GROUP] objectForKey:@"accessToken"];
            if (!sessionKey) {
                [self displayLoginToInstagramMessage];
            } else {
                if (sessionKey) {
                    _textLabelFullAccess.hidden = YES;
                    _textLabelFullAccess2.hidden = YES;
                    for (UIButton *button in _keyboardButtons) {
                        button.hidden = YES;
                    }
                    if(!_loadingNewImages){
                        _loadingNewImages = YES;
                        [self getPicsFromInsta];
                    }
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
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
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
    NSString *sessionKey = [[[NSUserDefaults alloc] initWithSuiteName:APP_GROUP] objectForKey:@"accessToken"];
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
    
    NSString *sessionKey = [[[NSUserDefaults alloc] initWithSuiteName:APP_GROUP] objectForKey:@"accessToken"];
    NSString *url = [NSString stringWithFormat:@"https://api.instagram.com/v1/media/%@/likes?access_token=%@", mediaID, sessionKey];
    NSURL *urlData = [NSURL URLWithString:url];
    NSError *error;
    NSString *page = [NSString stringWithContentsOfURL:urlData
                                              encoding:NSASCIIStringEncoding
                                                 error:&error];
    NSData *data = [page dataUsingEncoding:NSUTF8StringEncoding];
    if(data&&!error){
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:kNilOptions
                                                                       error:&error];
        if(!error){
            for (id user in [jsonResponse objectForKey:@"data"]) {
                if (![user[@"id"] isKindOfClass:[NSNull class]]&&[[user objectForKey:@"id"] isEqualToString:myID]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

-(NSString*)selfID{
    if(!_selfID){
        NSString *sessionKey = [[[NSUserDefaults alloc] initWithSuiteName:APP_GROUP] objectForKey:@"accessToken"];
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
        
        _selfID = [[jsonResponse objectForKey:@"data"] objectForKey:@"id"];
    }
    return _selfID;
}



- (void)getSamplePics {
    
    [self.instagramObjects addObject:[[InstagramObject alloc] initWithUsername:@"biddythehedgehog" caption:@"Thanks @triciakibler for making me look so good!!! #biddythehedgehog #biddythehedgehogart #ink #watercolor #triciapaints" link:@"http://instagram.com/p/xMwv8DQ1eT" photoID:nil localPhoto:@"hedgehog1.jpg"]];
    
    [self.instagramObjects addObject:[[InstagramObject alloc] initWithUsername:@"nasa" caption:@"Holiday Lights on the Sun: The sun emitted a significant solar flare, peaking at 7:28 p.m. EST on Dec. 19, 2014. Our Solar Dynamics Observatory, which watches the sun constantly, captured an image of the event. Solar flares are powerful bursts of radiation. Harmful radiation from a flare cannot pass through Earth's atmosphere to physically affect humans on the ground, however -- when intense enough -- they can disturb the atmosphere in the layer where GPS and communications signals travel. This flare is classified as an X1.8-class flare. X-class denotes the most intense flares, while the number provides more information about its strength. An X2 is twice as intense as an X1, an X3 is three times as intense, etc." link:@"http://instagram.com/p/w6q99qoaJa" photoID:nil localPhoto:@"gasball.jpg"]];
    
    [self.instagramObjects addObject:[[InstagramObject alloc] initWithUsername:@"whitehouse" caption:@"President Obama just took action to protect one of our greatest national treasures: Alaska's Bristol Bay." link:@"http://instagram.com/p/wrx-Y5wii3" photoID:nil localPhoto:@"whale.jpg"]];
    
    [self.instagramObjects addObject:[[InstagramObject alloc] initWithUsername:@"vervecoffee" caption:@"Nobody inspires adventure and exploration like @chrisburkard . Join us tonight 6/22 6-9pm @sawyersupply as he presents some of his journeys to the Arctic, Tahiti and beyond." link:@"http://instagram.com/p/vtWKGmyo9E" photoID:nil localPhoto:@"undersea.jpg"]];
    
    [self.instagramObjects addObject:[[InstagramObject alloc] initWithUsername:@"santacruzbicycles" caption:@"Check out this custom #5010CC build from @sohobikeslondon. Highlights include a custom painted 5010CC frame in neon orange, @rockshox suspension and post, XTR Di2 2x11 (single shifter), @chriskingbuzz headset and hubs with @envecomposites M60 rims. Stunning." link:@"http://instagram.com/p/w6yu9BPxkk" photoID:nil localPhoto:@"orange.jpg"]];
    
    [self.instagramObjects addObject:[[InstagramObject alloc] initWithUsername:@"santacruzskateboards" caption:@"Yard Sale! #SantaCruzSkateboards AM Cody Chapman (@coldchapman) snaps an Ollie off of a few recycled goods in the city. 📷:@michaelmcd | @nhs_inc |" link:@"http://instagram.com/p/wuLLrMFZ2x" photoID:nil localPhoto:@"skateboards.jpg"]];
    
    [self.instagramObjects addObject:[[InstagramObject alloc] initWithUsername:@"ucsc" caption:@"#TBT Kresge students on a road trip to San Francisco in a classic VW van, circa 1974 #tbtucsc" link:@"http://instagram.com/p/vo5dXhJfnl" photoID:nil localPhoto:@"kresge.jpg"]];
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadingSpinner.hidden = YES;
        _loadingNewImages = NO;
        _halfFrame = YES;
        
        [self.collectionView reloadData];
        self.collectionView.frame = CGRectMake(self.view.frame.size.width/2, 0, self.view.frame.size.width/2, self.collectionView.frame.size.height);
    });
}

- (void)getPicsFromInsta {
    _halfFrame = NO;
    self.loadingSpinner.hidden = NO;
    NSString *sessionKey = [[[NSUserDefaults alloc] initWithSuiteName:APP_GROUP] objectForKey:@"accessToken"];
//    NSLog(@"session key: %@", sessionKey);
    NSString *url;
    if (self.instagramObjects.count > 0) {
        url = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@&count=7&max_id=%@", sessionKey, [[self.instagramObjects lastObject] photoID]];
    } else {
        url = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@&count=7", sessionKey];
    }
    
    NSURL *nsurl=[NSURL URLWithString:url];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSString *sessionKey = [[[NSUserDefaults alloc] initWithSuiteName:APP_GROUP] objectForKey:@"accessToken"];
//        NSLog(@"session key: %@", sessionKey);
        if (sessionKey.length) {
            NSError *error = nil;
            NSString *page = [NSString stringWithContentsOfURL:nsurl
                                                      encoding:NSASCIIStringEncoding
                                                         error:&error];
            NSData *data = [page dataUsingEncoding:NSUTF8StringEncoding];
            
            if(data&&!error){
                
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:kNilOptions
                                                                               error:&error];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    [self.collectionView performBatchUpdates:^{
                        for (id obj in [jsonResponse objectForKey:@"data"]) {
                            
                            InstagramObject *newPhoto = [[InstagramObject alloc] init];
                            
                            newPhoto.link = obj[@"link"];
                            newPhoto.username = obj[@"user"][@"username"];
                            
                            
                            if (obj[@"caption"] != [NSNull null]) {
                                newPhoto.caption = obj[@"caption"][@"text"];
                            } else {
                                newPhoto.caption = @"";
                            }
                            
                            newPhoto.photoID = obj[@"id"];
                            
                            newPhoto.photoURLString = obj[@"images"][@"low_resolution"][@"url"];
                            
                            if(obj[@"user_has_liked"]&&![obj[@"user_has_liked"] isKindOfClass:[NSNull class]]){
                                newPhoto.liked = [obj[@"user_has_liked"] boolValue];
                            } else {
                                newPhoto.liked = [self didLikePhoto:newPhoto.photoID me:self.selfID];
                            }
                            
                            
                            if(![self.instagramObjects containsObject:newPhoto]){
                                [self.instagramObjects addObject:newPhoto];
                                
                                
                                [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.instagramObjects.count-1 inSection:0]]];
                                
                                
                            }
                        }
                    } completion:^(BOOL finished) {
                        
                    }];
                    
                    
                });
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.loadingSpinner.hidden = YES;
                _loadingNewImages = NO;
                
                [self.collectionView flashScrollIndicators];
                
            });
        }
    });
}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.instagramObjects.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    InstagramPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"InstagramPhoto" forIndexPath:indexPath];
    
    cell.delegate = self;
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

-(void)configureCell:(InstagramPhotoCollectionViewCell*)cell forIndexPath:(NSIndexPath*)indexPath{
    
    InstagramObject *object = self.instagramObjects[indexPath.item];
    
    NSMutableAttributedString *descriptionString = [[NSMutableAttributedString alloc] initWithString:@""];
    
    [descriptionString appendAttributedString:[[NSAttributedString alloc] initWithString:object.username attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:16/255.0f green:56/255.0f blue:138/255.0f alpha:1.0f],NSFontAttributeName:[UIFont systemFontOfSize:14]}]];
    
    [descriptionString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    
    [descriptionString appendAttributedString:[[NSAttributedString alloc] initWithString:object.caption attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:14]}]];
    
    cell.textView.attributedText = descriptionString;
    cell.textView.contentOffset = CGPointMake(0,0);
    
    if(object.photoURLString.length){
        [cell loadImageFromURLString:object.photoURLString];
    } else if(object.localPhoto.length){
        [cell.imageView setImage:[UIImage imageNamed:object.localPhoto]];
    }
    
    cell.heartImageView.hidden = !object.liked;
    
}

#pragma mark - UICollectionViewDelegate Methods

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)collectionViewLayout;
    
    return CGSizeMake(140, collectionView.frame.size.height - flowLayout.sectionInset.top - flowLayout.sectionInset.bottom);
}

#pragma mark - InstagramPhotoCollectionViewCellDelegate Methods

-(void)photoCellDidTapPhoto:(InstagramPhotoCollectionViewCell *)cell{
    
    InstagramObject *object = self.instagramObjects[[self.collectionView indexPathForCell:cell].item];
    
    if(object){
        [self.textDocumentProxy insertText:[NSString stringWithFormat:@"%@ %@ ", object.link, PROMO_TEXT]];
    }
    
}

-(void)photoCellDidDoubleTapPhoto:(InstagramPhotoCollectionViewCell *)cell{
    
    InstagramObject *object = self.instagramObjects[[self.collectionView indexPathForCell:cell].item];
    if(object){
        
        cell.heartImageView.hidden = NO;
        
        //curl -F 'access_token=ACCESS-TOKEN' \
        //https://api.instagram.com/v1/media/{media-id}/likes
        
        NSString *sessionKey = [[[NSUserDefaults alloc] initWithSuiteName:APP_GROUP] objectForKey:@"accessToken"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/media/%@/likes", object.photoID]]];
        
        request.HTTPMethod = @"POST";
        NSString *post = [NSString stringWithFormat:@"access_token=%@", sessionKey];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if(conn) {
            NSLog(@"Connection Successful");
            object.liked = YES;
        } else {
            NSLog(@"Connection could not be made");
        }
    
    }
    
    
}

-(void)photoCellDidLongPressPhoto:(InstagramPhotoCollectionViewCell *)cell{
//    NSLog(@"Long press");
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
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


- (void)portrait {
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGRect scrollFrame;
    if (_halfFrame) {
        scrollFrame.origin = self.collectionView.frame.origin;
        scrollFrame.origin.x = self.view.frame.size.width/2;
        scrollFrame.size = CGSizeMake(self.view.frame.size.width/2, 184);
        _textLabelFullAccess.frame = CGRectMake(12, 125, (width/2)-6, 80);
    } else {
        scrollFrame.origin = self.collectionView.frame.origin;
        scrollFrame.size = CGSizeMake(self.view.frame.size.width, 184);
    }
    
    self.collectionView.frame = scrollFrame;
    
    @try{
        [self.collectionView performBatchUpdates:^{
        } completion:^(BOOL finished) {
            
        }];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    
    
}

- (void)landscape {
    CGFloat width = self.view.frame.size.width;
    CGRect scrollFrame;
    if (_halfFrame) {
        scrollFrame.origin = self.collectionView.frame.origin;
        scrollFrame.size = CGSizeMake(self.view.frame.size.width/2, 125);
        scrollFrame.origin.x = self.view.frame.size.width/2;
        _textLabelFullAccess.frame = CGRectMake(self.view.frame.size.width/2-((width/4)-18), 0, (width/4)-18, 80);
    } else {
        scrollFrame.origin = self.collectionView.frame.origin;
        scrollFrame.size = CGSizeMake(self.view.frame.size.width, 125);
    }
    
    self.collectionView.frame = scrollFrame;
    @try{
        [self.collectionView performBatchUpdates:^{
        } completion:^(BOOL finished) {
        }];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
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
