//
//  DecimalViewController.m
//  KeyFeed
//
//  Created by John Rogers on 2/28/15.
//  Copyright (c) 2015 jackrogers. All rights reserved.
//

#import "DecimalViewController.h"

@interface DecimalViewController ()

@end

@implementation DecimalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 40, 100)];
    [button setTitle:@"hello" forState:UIControlStateNormal];
    [self.view addSubview:button];
    // Do any additional setup after loading the view.
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

@end
