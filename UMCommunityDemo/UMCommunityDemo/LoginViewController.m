//
//  LoginViewController.m
//  UMCommunity_0318
//
//  Created by lixinsheng on 15-4-14.
//  Copyright (c) 2015年 lixinsheng. All rights reserved.
//

#import "LoginViewController.h"
#import "UMComUserAccount.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didLoginBtn:(id)sender
{
    UMComUserAccount *account = [[UMComUserAccount alloc] initWithSnsType:UMComSnsTypeSelfAccount];
    account.usid = @"asdfasdfasdf";
    account.name = @"你好";
    
    [UMComLoginManager finishLoginWithAccount:account completion:^(NSArray *data, NSError *error) {
        [UMComLoginManager finishDismissViewController:self data:data error:error];
    }];
}

-(void)presentLoginViewController:(UIViewController *)viewController finishResponse:(LoadDataCompletion)loginCompletion
{
    [viewController presentViewController:self animated:YES completion:nil];
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
