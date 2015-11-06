//
//  UMComUserRecommendViewController.m
//  UMCommunity
//
//  Created by umeng on 15-3-31.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComUsersTableViewController.h"
#import "UMComAction.h"
#import "UMComBarButtonItem.h"
#import "UIViewController+UMComAddition.h"
#import "UMComUserCenterViewController.h"
#import "UMComUserTableViewCell.h"
#import "UMComPullRequest.h"
#import "UMComUsersTableView.h"
#import "UMComRefreshView.h"
#import "UMComClickActionDelegate.h"

@interface UMComUsersTableViewController ()<UMComClickActionDelegate>

@property (nonatomic, strong) UMComUsersTableView *userTabelView;

@end

@implementation UMComUsersTableViewController


- (id)initWithCompletion:(LoadDataCompletion)completion
{
    self = [super init];
    if (self) {
        self.completion = completion;
        UMComBarButtonItem *rightButtonItem = [[UMComBarButtonItem alloc] initWithTitle:UMComLocalizedString(@"FinishStep",@"完成") target:self action:@selector(onClickNext)];
        [self.navigationItem setRightBarButtonItem:rightButtonItem];
    }
    return self;
}

- (void)onClickNext
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.completion) {
            self.completion(nil,nil);
        }        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self setBackButtonWithImage];
    [self setTitleViewWithTitle:self.title];
    
    self.userTabelView = [[UMComUsersTableView alloc]initWithFrame:CGRectMake(0, -kUMComRefreshOffsetHeight, self.view.frame.size.width, self.view.frame.size.height + kUMComRefreshOffsetHeight) style:UITableViewStylePlain];
    self.userTabelView.clickActionDelegate = self;
    self.userTabelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.userTabelView];
    if (self.userList) {
        self.userTabelView.dataArray = [NSMutableArray arrayWithArray:self.userList];
        CGFloat delta = 0;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            delta = 20;
        }
        self.userTabelView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height - delta);
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0 && [[[UIDevice currentDevice] systemVersion] floatValue] > 7.0) {
            lineView.backgroundColor = TableViewSeparatorRGBColor;
        }
        UIView *toplineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
        toplineView.backgroundColor = TableViewSeparatorRGBColor;
        self.userTabelView.refreshController = nil;
        self.userTabelView.tableFooterView = lineView;
        self.userTabelView.tableHeaderView = toplineView;
    }else{
    }
    [self refreshAllData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.userTabelView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)refreshAllData
{
    self.userTabelView.fetchRequest = self.fetchRequest;
    [self.userTabelView loadAllData:nil fromServer:nil];
}


- (void)refreshDataFromServer
{
    self.userTabelView.fetchRequest = self.fetchRequest;
    [self.userTabelView refreshNewDataFromServer:nil];
}


#pragma mark - private method
- (void)customObj:(id)obj clickOnUser:(UMComUser *)user
{
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            UMComUserCenterViewController *userCenterVc = [[UMComUserCenterViewController alloc]initWithUser:user];
            [self.navigationController pushViewController:userCenterVc animated:YES];
        }
    }];
}


- (void)removeUserFromUsers:(UMComUser *)user
{
    NSMutableArray *newUsers = [NSMutableArray arrayWithArray:self.userTabelView.dataArray];
    __weak UMComUsersTableViewController * weakSelf = self;
    if (user) {
        [self.userTabelView.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([[obj uid] isEqualToString:user.uid]) {
                [newUsers removeObject:obj];
                *stop = YES;
                weakSelf.userTabelView.dataArray = newUsers;
                [weakSelf.userTabelView reloadData];
            }
        }];
    }
}

#pragma mark - UMComClickActionDelegate
- (void)customObj:(UMComUserTableViewCell *)cell clickOnFollowUser:(UMComUser *)user
{
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        [cell focusUserAfterLoginSucceedWithResponse:^(NSError *error) {
            if (!error) {
                //社区管理员关注成功后不能将被移除，不会出现在此列表中
                if ([user.atype intValue] == 3) {
                    [self removeUserFromUsers:user];
                }
            }
        }];
    }];
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
