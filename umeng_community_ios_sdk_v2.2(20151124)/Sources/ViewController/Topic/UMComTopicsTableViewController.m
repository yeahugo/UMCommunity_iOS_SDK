//
//  UMComTopicsTableViewController.m
//  UMCommunity
//
//  Created by umeng on 15/7/15.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComTopicsTableViewController.h"
#import "UIViewController+UMComAddition.h"
#import "UMComTools.h"
#import "UMComBarButtonItem.h"
#import "UMComFilterTopicsViewCell.h"
#import "UMComTopicFeedViewController.h"
#import "UMComPullRequest.h"
#import "UMComPushRequest.h"
#import "UMComShowToast.h"
#import "UMComAction.h"
#import "UMComTopic.h"
#import "UMComTopic+UMComManagedObject.h"
#import "UMComTopicsTableView.h"
#import "UMComRefreshView.h"
#import "UMComClickActionDelegate.h"

@interface UMComTopicsTableViewController ()<UMComClickActionDelegate>
@end

@implementation UMComTopicsTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self setBackButtonWithImage];
    [self setTitleViewWithTitle:self.title];
    UMComTopicsTableView *topicsTableView = [[UMComTopicsTableView alloc]initWithFrame:CGRectMake(0, -kUMComRefreshOffsetHeight, self.view.frame.size.width, self.view.frame.size.height+kUMComRefreshOffsetHeight) style:UITableViewStylePlain];
    topicsTableView.clickActionDelegate = self;
    [self.view addSubview:topicsTableView];
    if (self.tableView) {
        [self.tableView removeFromSuperview];
    }
    self.tableView = topicsTableView;
    if (self.isShowNextButton == YES) {
        UMComBarButtonItem *rightButtonItem = [[UMComBarButtonItem alloc] initWithTitle:UMComLocalizedString(@"NextStep",@"下一步") target:self action:@selector(onClickNext)];
        [self.navigationItem setRightBarButtonItem:rightButtonItem];
    }
    if (self.fetchRequest) {
       [self fecthTopicsData];
    }
}

- (void)onClickNext
{
    if (self.completion) {
        self.completion(@[self], nil);
    }
}

-(void)onClickClose
{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma requestDataMethod
- (void)fecthTopicsData
{
    self.tableView.fetchRequest = self.fetchRequest;
    [self.tableView loadAllData:nil fromServer:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UMComClickActionDelegate
- (void)customObj:(UMComFilterTopicsViewCell *)cell clickOnFollowTopic:(UMComTopic *)topic
{
    __weak UMComFilterTopicsViewCell *weakCell = cell;
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        BOOL isFocus = [[topic is_focused] boolValue];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [UMComPushRequest followerWithTopic:topic isFollower:!isFocus completion:^(NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if (!error) {
                [weakCell setFocused:[[topic is_focused] boolValue]];
            } else {
                [UMComShowToast showFetchResultTipWithError:error];
            }
            [weakSelf.tableView reloadData];
        }];
    }];
}

- (void)customObj:(id)obj clickOnTopic:(UMComTopic *)topic
{
    if (!topic) {
        return;
    }
    UMComTopicFeedViewController *oneFeedViewController = nil;
    oneFeedViewController = [[UMComTopicFeedViewController alloc] initWithTopic:topic];
    [self.navigationController pushViewController:oneFeedViewController animated:YES];
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
