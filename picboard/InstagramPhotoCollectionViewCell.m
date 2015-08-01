//
//  InstagramPhotoCollectionViewCell.m
//  KeyFeed
//
//  Created by Andrew Milham on 7/31/15.
//  Copyright (c) 2015 jackrogers. All rights reserved.
//

#import "InstagramPhotoCollectionViewCell.h"

@interface InstagramPhotoCollectionViewCell ()

@property (strong, nonatomic) NSURLSessionDataTask *imageDownloadTask;

@end

@implementation InstagramPhotoCollectionViewCell

-(void)prepareForReuse{
    [super prepareForReuse];
    self.textView.text = nil;
    self.imageView.image = nil;
    self.heartImageView.hidden = YES;
    if(self.imageDownloadTask&&self.imageDownloadTask.state==NSURLSessionTaskStateRunning){
        [self.imageDownloadTask cancel];
    }
}

- (void)awakeFromNib {
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
    [self addGestureRecognizer:singleTap];
    
     UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapImage:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressImage:)];
    [self addGestureRecognizer:longPress];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [singleTap requireGestureRecognizerToFail:longPress];
}


-(void)loadImageFromURLString:(NSString *)urlString{
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    self.imageDownloadTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(data){
            UIImage *loadedImage = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView transitionWithView:self.imageView duration:0.1f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    
                    self.imageView.image = loadedImage;
                } completion:^(BOOL finished) {
                    
                }];
            });
            
        }
        
    }];
    
    
    [self.imageDownloadTask resume];
    
}


- (void)tapImage:(id)sender {
    if(self.delegate&&[self.delegate respondsToSelector:@selector(photoCellDidTapPhoto:)]){
        [self.delegate photoCellDidTapPhoto:self];
    }
}
- (void)doubleTapImage:(id)sender {
    if(self.delegate&&[self.delegate respondsToSelector:@selector(photoCellDidDoubleTapPhoto:)]){
        [self.delegate photoCellDidDoubleTapPhoto:self];
    }
}
- (void)longPressImage:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan){
        if(self.delegate&&[self.delegate respondsToSelector:@selector(photoCellDidLongPressPhoto:)]){
            [self.delegate photoCellDidLongPressPhoto:self];
        }
    }
}

@end
