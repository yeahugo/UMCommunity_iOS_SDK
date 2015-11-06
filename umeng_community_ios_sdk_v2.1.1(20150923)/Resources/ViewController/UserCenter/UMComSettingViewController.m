//
//  UMComSettingViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 11/19/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComSettingViewController.h"
#import "UMComProfileSettingController.h"
#import "UMComSession.h"
#import "UMComBarButtonItem.h"
#import "UMComMessageSettingViewController.h"
#import "UMComLoginManager.h"
#import "UMUtils.h"
#import "UIViewController+UMComAddition.h"

@interface UMComSettingViewController ()

@end

@implementation UMComSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.logoutButton.titleLabel.font = UMComFontNotoSansLightWithSafeSize(18);
    [self setBackButtonWithImage];
    [self setTitleViewWithTitle:UMComLocalizedString(@"Setting", @"设置")];
//    
    [self.settingTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SettingCell"];
    self.logoutButton.layer.borderColor = [UIColor colorWithRed:76.0/255 green:145.0/255 blue:226.0/255 alpha:1].CGColor;
    self.logoutButton.layer.borderWidth = 1;
    if ([self.settingTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.settingTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.settingTableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.settingTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    self.settingTableView.tableFooterView = [[UIView alloc]init];
    
    if ([[[UIDevice currentDevice] systemVersion]floatValue] < 7.0) {
        self.settingTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, 180);
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)onClickClose
{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"SettingCell";
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
    [tableViewCell.textLabel setTextColor:[UMComTools colorWithHexString:FontColorBlue]];
    tableViewCell.textLabel.textAlignment = NSTextAlignmentCenter;
    if (indexPath.row == 0) {
        [tableViewCell.textLabel setText:UMComLocalizedString(@"user_setting",@"用户设置")];
    } else {
        [tableViewCell.textLabel setText:UMComLocalizedString(@"message_setting",@"推送设置")];
    }
    return tableViewCell;
}


//#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UMComProfileSettingController *profileSettingController = [[UMComProfileSettingController alloc] initWithUid:[UMComSession sharedInstance].uid];
        [self.navigationController pushViewController:profileSettingController animated:YES];
    }
    if (indexPath.row == 1) {
        UMComMessageSettingViewController *mesageSettingController = [[UMComMessageSettingViewController alloc] initWithNibName:@"UMComMessageSettingViewController" bundle:nil];
        [self.navigationController pushViewController:mesageSettingController animated:YES];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)userLogoutAction:(id)sender {
    [[UMComSession sharedInstance] userLogout];
    [[NSNotificationCenter defaultCenter] postNotificationName:UserLogoutSucceed object:nil];
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }

}
@end
