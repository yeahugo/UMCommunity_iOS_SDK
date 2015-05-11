//
//  UMComFindViewController.m
//  UMCommunity
//
//  Created by umeng on 15-3-31.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComFindViewController.h"
#import "UMComFindTableViewCell.h"
#import "UMComAction.h"
#import "UMComUserRecommendViewController.h"
#import "UMComAllFeedViewController.h"
#import "UMComSettingViewController.h"
#import "UIViewController+UMComAddition.h"

@interface UMComFindViewController ()

@end

@implementation UMComFindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonWithTitle:UMComLocalizedString(@"Back",@"返回")];
    [self setTitleViewWithTitle:UMComLocalizedString(@"find", @"发现")];
//    self.title = UMComLocalizedString(@"find", @"发现");
    [self.tableView registerNib:[UINib nibWithNibName:@"UMComFindTableViewCell" bundle:nil] forCellReuseIdentifier:@"FindTableViewCell"];
    self.tableView.rowHeight = 55.0f;
    if ([[UIDevice currentDevice].systemVersion floatValue]< 8.0) {
        self.footView.backgroundColor = TableViewSeparatorRGBColor;
    }
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    }
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"FindTableViewCell";
    UMComFindTableViewCell *cell = (UMComFindTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.titleImageView.image = [UIImage imageNamed:@"circle_friends"];
            cell.titleNameLabel.text = UMComLocalizedString(@"circle_friends", @"好友圈");
        }else if(indexPath.row == 1){
            cell.titleImageView.image = [UIImage imageNamed:@"topic_recommend"];
            cell.titleNameLabel.text = UMComLocalizedString(@"topic_recommend", @"话题推荐");

        }else{
            cell.titleImageView.image = [UIImage imageNamed:@"user_recommend"];
            cell.titleNameLabel.text = UMComLocalizedString(@"user_recommend", @"用户推荐");
        }
    }else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            cell.titleImageView.image = [UIImage imageNamed:@"user_center"];
            cell.titleNameLabel.text = UMComLocalizedString(@"user_center", @"个人中心");
        }else{
            cell.titleImageView.image = [UIImage imageNamed:@"setting"];
            cell.titleNameLabel.text = UMComLocalizedString(@"setting", @"设置");
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate 
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 50.0f;
    }else{
        return 70.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return [self headViewWithTitle:UMComLocalizedString(@"recommend", @"推荐") viewHeight:50];
    }else{
        return [self headViewWithTitle:UMComLocalizedString(@"recommend", @"其它") viewHeight:70];
    }
}

- (UIView *)headViewWithTitle:(NSString *)title viewHeight:(CGFloat)viewHeight
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, viewHeight)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(13, viewHeight-30-5, 50, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.text = title;
    label.textColor = [UMComTools colorWithHexString:FontColorGray];
    [view addSubview:label];
    UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0,viewHeight-0.5,view.frame.size.width,0.5)];
    bottomLine.backgroundColor = TableViewSeparatorRGBColor;
    [view addSubview:bottomLine];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        UIView *topLine = [[UIView alloc]initWithFrame:CGRectMake(0,0,view.frame.size.width,0.5)];
        topLine.backgroundColor = TableViewSeparatorRGBColor;
        [view addSubview:topLine];
    }
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self tranToCircleFriends];
        }else if (indexPath.row == 1) {
            [self tranToTopicsRecommend];
        }else if (indexPath.row == 2){
            [self tranToUsersRecommend];
        }
    }else{
        if (indexPath.row == 0) {
            [self tranToUserCenter];
        }else{
            [self tranToSetting];
        }
    }
}

- (void)tranToCircleFriends
{
    UMComAllFeedViewController *friendViewController = [[UMComAllFeedViewController alloc]init];
    friendViewController.fetchFeedsController = [[UMComFriendFeedsRequest alloc]initWithCount:BatchSize];
    [friendViewController setBackButtonWithTitle:UMComLocalizedString(@"Back",@"返回")];
    [friendViewController setTitleViewWithTitle:UMComLocalizedString(@"circle_friends", @"好友圈")];
//    friendViewController.title = UMComLocalizedString(@"circle_friends", @"好友圈");
    [self.navigationController pushViewController:friendViewController animated:YES];
}

- (void)tranToTopicsRecommend
{
    [[UMComTopicRecommendAction action] performActionAfterLogin:nil viewController:self completion:nil];
}

- (void)tranToUsersRecommend
{

    [[UMComUserRecommendAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        
    }];
}

- (void)tranToUserCenter
{
    [[UMComUserCenterAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
    }];

}
- (void)tranToSetting
{
//    [[UMComSettingAction action] performActionAfterLogin:nil viewController:self completion:nil];
    UMComSettingViewController *settingVc = [[UMComSettingViewController alloc]initWithNibName:@"UMComSettingViewController" bundle:nil];
    [self.navigationController pushViewController:settingVc animated:YES];
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
