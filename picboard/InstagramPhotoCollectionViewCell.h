//
//  InstagramPhotoCollectionViewCell.h
//  KeyFeed
//
//  Created by Andrew Milham on 7/31/15.
//  Copyright (c) 2015 jackrogers. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InstagramPhotoCollectionViewCellDelegate;

@interface InstagramPhotoCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIImageView *heartImageView;

-(void)loadImageFromURLString:(NSString*)urlString;

@property (weak, nonatomic) id<InstagramPhotoCollectionViewCellDelegate> delegate;

@end


@protocol InstagramPhotoCollectionViewCellDelegate <NSObject>

@optional

-(void)photoCellDidTapPhoto:(InstagramPhotoCollectionViewCell*)cell;
-(void)photoCellDidDoubleTapPhoto:(InstagramPhotoCollectionViewCell*)cell;
-(void)photoCellDidLongPressPhoto:(InstagramPhotoCollectionViewCell*)cell;

@end