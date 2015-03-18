//
//  ViewController.m
//  UMCommunityDemo
//
//  Created by Gavin Ye on 3/18/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import "ViewController.h"
#import "UMCommunity.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)onClickWxq:(id)sender
{
    UINavigationController *viewController = [UMCommunity getFeedsModalViewController];
    [self presentViewController:viewController animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
