//
//  InstagramAuthenticationViewController.h
//  KeyFeed
//
//  Created by Andrew Milham on 8/14/15.
//  Copyright (c) 2015 jackrogers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstagramAuthenticationViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)tapCancel:(id)sender;

@end
