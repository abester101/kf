//
//  ViewController.m
//  instakey
//
//  Created by John Rogers on 11/21/14.
//  Copyright (c) 2014 jackrogers. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
//    [self.view addGestureRecognizer:gr];
    // if not using ARC, you should [gr release];
    // mySensitiveRect coords are in the coordinate system of self.view
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"login to insta");
    [self loginToInsta:nil];

}

- (void)viewDidAppear:(BOOL)animated {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    // here i can set accessToken received on previous login
    appDelegate.instagram.accessToken = [[[NSUserDefaults alloc] initWithSuiteName:@"group.KeyFeed.KeyFeed"] objectForKey:@"accessToken"];
    NSLog(@"token: %@", appDelegate.instagram.accessToken);
    appDelegate.instagram.sessionDelegate = self;
    if ([appDelegate.instagram isSessionValid]) {
        NSLog(@"ok");
        [_loginButton setTitle:@"Logged in" forState:UIControlStateNormal];
        [self didLogin];
    }
}

- (IBAction)loginToInsta:(id)sender {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    // here i can set accessToken received on previous login
    appDelegate.instagram.accessToken = [[[NSUserDefaults alloc] initWithSuiteName:@"group.KeyFeed.KeyFeed"] objectForKey:@"accessToken"];
    NSLog(@"token: %@", appDelegate.instagram.accessToken);
    appDelegate.instagram.sessionDelegate = self;
    if ([appDelegate.instagram isSessionValid]) {
        [_loginButton setTitle:@"Logged in" forState:UIControlStateNormal];
        [self didLogin];
    } else {
        [appDelegate.instagram authorize:[NSArray arrayWithObjects:@"likes", nil]];
    }
}

- (void)didLogin {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    UIViewController *controller = (UIViewController*)[mainStoryboard
                                                       instantiateViewControllerWithIdentifier:@"howtoinstall"];
    
    if(self.presentedViewController){
        [self dismissViewControllerAnimated:YES completion:^{
            [self presentViewController:controller animated:YES completion:nil];
        }];
    } else {
        [self presentViewController:controller animated:YES completion:nil];
        NSLog(@"will present other view controller");
    }
}

-(void)igDidLogin {
    NSLog(@"Instagram did login");
    // here i can store accessToken
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [[[NSUserDefaults alloc] initWithSuiteName:@"group.KeyFeed.KeyFeed"] setObject:appDelegate.instagram.accessToken forKey:@"accessToken"];
    [[[NSUserDefaults alloc] initWithSuiteName:@"group.KeyFeed.KeyFeed"] synchronize];
    NSLog(@"suite: %@",[[[NSUserDefaults alloc] initWithSuiteName:@"group.KeyFeed.KeyFeed"] objectForKey:@"accessToken"]);
    [_loginButton setTitle:@"Logged in" forState:UIControlStateNormal];
    [self didLogin];
    
    //IGListViewController* viewController = [[IGListViewController alloc] init];
    //[self.navigationController pushViewController:viewController animated:YES];
}

-(void)igDidNotLogin:(BOOL)cancelled {
    NSLog(@"Instagram did not login");
    NSString* message = nil;
    if (cancelled) {
        message = @"Access cancelled!";
    } else {
        message = @"Access denied!";
    }
    if(self.presentedViewController){
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

-(void)igDidLogout {
    NSLog(@"Instagram did logout");
    // remove the accessToken
    [[[NSUserDefaults alloc] initWithSuiteName:@"group.KeyFeed.KeyFeed"] setObject:nil forKey:@"accessToken"];
    [[[NSUserDefaults alloc] initWithSuiteName:@"group.KeyFeed.KeyFeed"] synchronize];
}

-(void)igSessionInvalidated {
    NSLog(@"Instagram session was invalidated");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
