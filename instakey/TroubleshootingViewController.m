//
//  TroubleshootingViewController.m
//  KeyFeed
//
//  Created by John Rogers on 1/11/15.
//  Copyright (c) 2015 jackrogers. All rights reserved.
//

#import "TroubleshootingViewController.h"

@interface TroubleshootingViewController ()

@end

@implementation TroubleshootingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)contactButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://retentiontab.typeform.com/to/VMtfLc"]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
