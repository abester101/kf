//
//  ViewController.h
//  instakey
//
//  Created by John Rogers on 11/21/14.
//  Copyright (c) 2014 jackrogers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ViewController : UIViewController <IGSessionDelegate>
@property (strong, nonatomic) IBOutlet UIButton *loginButton;



@end

