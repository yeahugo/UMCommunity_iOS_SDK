//
//  UMComForumAllViewController.m
//  UMCommunity
//
//  Created by umeng on 15/11/17.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumAllTopicTableViewController.h"
#import "UMComPullRequest.h"
#import "UMComSearchBar.h"
#import "UMComAction.h"
#import "UMComTopic.h"
#import "UMComForumTopicTableViewController.h"
#import "UMComForumSearchTopicTableViewController.h"
#import "UMComSession.h"
#import "UMComTopicType.h"
#import "UMComForumTopicTableViewCell.h"
#import "UMComPushRequest.h"
#import "UMComShowToast.h"
#import "UMComForumTopicTypeTableViewController.h"
#import "UMComNavigationController.h"
#import "UMComAction.h"
#import "UMComScrollViewDelegate.h"
#import "UMComForumTopicFocusedTableViewController.h"
#import "UIViewController+UMComAddition.h"

@interface UMComForumAllTopicTableViewController ()<UISearchBarDelegate, UMComScrollViewDelegate>


@property (nonatomic, assign) NSInteger lastIndex;//上次显示的页面

@property (nonatomic, strong)  UIButton *loginBt;

@property (nonatomic, assign) CGFloat searchBarOriginY;

@end


@implementation UMComForumAllTopicTableViewController
{
    CGPoint originOffset; //全部话题搜索页面的起始位置
}

- (void)viewDidLoad {

    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    [self createTopicViewControllers];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resetSubViewControllers) name:kUserLoginSucceedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resetSubViewControllers) name:kUserLogoutSucceedNotification object:nil];
}

//- (void)loginSucceed
//{
//    [self resetSubViewControllers];
//    [self transitionToPageAtIndex:self.page];
//
//}
//
//- (void)logoutSucceed
//{
//    [self resetSubViewControllers];
//    [self transitionToPageAtIndex:self.page];
//}

- (void)resetSubViewControllers
{
    UMComForumTopicTableViewController *focusedVc = self.childViewControllers[0];
    focusedVc.dataArray = nil;
    focusedVc.isLoadFinish = YES;
    [focusedVc.tableView reloadData];
    if ([[UMComSession sharedInstance] isLogin]) {
        focusedVc.fetchRequest = [[UMComUserTopicsRequest alloc] initWithUid:[UMComSession sharedInstance].uid count:BatchSize];

    }else{
        focusedVc.fetchRequest = nil;
    }
    UMComForumTopicTableViewController *topicVc = self.childViewControllers[1];
    topicVc.dataArray = nil;
    topicVc.isLoadFinish = YES;
    [topicVc.tableView reloadData];
    [self transitionToPageAtIndex:self.page];
}

//创建各自话题ViewController
- (void)createTopicViewControllers
{
    CGRect commonFrame = self.view.bounds;
    UMComForumTopicFocusedTableViewController *focuedTopicsTableViewController = [[UMComForumTopicFocusedTableViewController alloc] initWithFetchRequest:[[UMComUserTopicsRequest alloc] initWithUid:[UMComSession sharedInstance].uid count:BatchSize]];
    focuedTopicsTableViewController.scrollViewDelegate = self;
    [self addChildViewController:focuedTopicsTableViewController];
    focuedTopicsTableViewController.view.frame = commonFrame;
    [self.view addSubview:focuedTopicsTableViewController.view];
    
    commonFrame.origin.x = -self.view.frame.size.width *3/2;
    UMComForumTopicTableViewController *recommendTopicsTableViewController = [[UMComForumTopicTableViewController alloc] initWithFetchRequest:[[UMComRecommendTopicsRequest alloc] initWithCount:BatchSize]];
    recommendTopicsTableViewController.scrollViewDelegate = self;
    [self addChildViewController:recommendTopicsTableViewController];
    recommendTopicsTableViewController.view.frame = commonFrame;
    
    UMComForumTopicTypeTableViewController *topicTypesTableViewController = [[UMComForumTopicTypeTableViewController alloc] init];
    [self addChildViewController:topicTypesTableViewController];
    topicTypesTableViewController.view.frame = commonFrame;
}

//设置当前页面
- (void)setPage:(NSInteger)page
{
    _lastIndex = _page;
    _page = page;
    if (page < self.childViewControllers.count) {
        [self transitionToPageAtIndex:page];
    }
}

/**
 跳到指定的页面
 
 @param index 要显示第几页
 
 */
- (void)transitionToPageAtIndex:(NSInteger)index
{
    UMComRequestTableViewController *requestTableViewController = self.childViewControllers[index];
    if (index == 0) {
        [requestTableViewController performSelector:@selector(resetSubViews) withObject:nil afterDelay:0];
    }
    if (requestTableViewController.dataArray.count == 0 && requestTableViewController.isLoadFinish && requestTableViewController.fetchRequest) {
        [requestTableViewController loadAllData:nil fromServer:nil];
    }
    [self transitionFromViewControllerAtIndex:self.lastIndex toViewControllerAtIndex:index duration:0 options:UIViewAnimationOptionTransitionNone animations:nil completion:nil];
}

///**
// 当前ViewController的子ViewControllers之间的切换
// 
// @param fromViewController 当前ViewController
// 
// @param toViewController   将要显示的ViewController
// 
// */
//- (void)transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
//{
//    if (fromViewController == toViewController) {
//        return;
//    }
//    __weak typeof(self) weakSelf = self;
//    [self transitionFromViewController:fromViewController toViewController:toViewController duration:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
//        toViewController.view.center = CGPointMake(weakSelf.view.frame.size.width/2, toViewController.view.center.y);
//        if (weakSelf.page > weakSelf.lastIndex) {
//            fromViewController.view.center = CGPointMake(-weakSelf.view.frame.size.width*3/2, fromViewController.view.center.y);
//        }else if(weakSelf.page < weakSelf.lastIndex){
//            fromViewController.view.center = CGPointMake(weakSelf.view.frame.size.width*3/2, fromViewController.view.center.y);
//        }else{
//            toViewController.view.center = fromViewController.view.center;
//        }
//    } completion:^(BOOL finished) {
//        weakSelf.lastViewController = toViewController;
//    }];
//}

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
