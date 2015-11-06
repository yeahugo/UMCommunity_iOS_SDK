//
//  UMCommViewController.m
//  UMCommunityDemo
//
//  Created by Gavin Ye on 3/18/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import "UMCommViewController.h"
#import "UMCommunity.h"

@interface UMCommViewController ()

@end

@implementation UMCommViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(IBAction)onClickDemo:(id)sender
{
    UIViewController *communityController = [UMCommunity getFeedsModalViewController];
    [self presentModalViewController:communityController animated:YES];
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
