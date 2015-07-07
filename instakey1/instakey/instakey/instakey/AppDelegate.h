//
//  AppDelegate.h
//  instakey
//
//  Created by John Rogers on 11/21/14.
//  Copyright (c) 2014 jackrogers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instagram.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#define APP_ID @"4efbf1dd9a1b4a058a4c3772876d9400"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Instagram *instagram;

@end

