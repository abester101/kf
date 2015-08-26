//
//  InstagramAuthenticationViewController.m
//  KeyFeed
//
//  Created by Andrew Milham on 8/14/15.
//  Copyright (c) 2015 jackrogers. All rights reserved.
//

#import "InstagramAuthenticationViewController.h"

#import "AppDelegate.h"

static NSString *const authUrlString = @"https://api.instagram.com/oauth/authorize/";
static NSString *const tokenUrlString = @"https://api.instagram.com/oauth/access_token/ ";



// YOU NEED A BAD URL HERE - THIS NEEDS TO MATCH YOUR URL SET UP FOR YOUR
// INSTAGRAM APP
static NSString *const redirectUri = @" http://mydomain.com/NeverGonnaFindMe/ ";

// CHANGE TO THE SCOPE YOU NEED ACCESS TO
static NSString *const scope = @"likes";

@interface InstagramAuthenticationViewController ()

@end

@implementation InstagramAuthenticationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
//    NSString *authUrlString = [NSString stringWithFormat:@"%@/?client_id=%@&redirect_uri=%@&scope=%@&response_type=token&display=touch",
//                                @"https://api.instagram.com/oauth/authorize",
//                                APP_ID,
//                                [NSString stringWithFormat:@"instakey://authorize"],
//                                @"likes"];
    NSString *authUrlString = [NSString stringWithFormat:@"%@/?client_id=%@&redirect_uri=%@&scope=%@&response_type=token&display=touch",
                               @"https://api.instagram.com/oauth/authorize",
                               APP_ID,
                               [NSString stringWithFormat:@"ig%@://authorize", APP_ID],
                               @"likes"];
    
    NSURLRequest *authRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:authUrlString]];
    [self.webView loadRequest:authRequest];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)tapCancel:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}


-(void)webViewDidStartLoad:(UIWebView *)webView{
    [self.activityIndicatorView startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.activityIndicatorView stopAnimating];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL *url = [request URL];
    if([[url scheme] isEqualToString:[NSString stringWithFormat:@"ig%@://authorize", APP_ID]]){
        
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate.instagram handleOpenURL:url];
        
        return NO;
    }

    return YES;
}


@end
