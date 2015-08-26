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

#define APP_ID @"44da35c3aec84759ada97a7cf94bfe30"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Instagram *instagram;

@end

