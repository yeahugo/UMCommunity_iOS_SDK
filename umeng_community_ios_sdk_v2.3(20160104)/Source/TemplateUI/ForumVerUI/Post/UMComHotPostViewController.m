//
//  UMComPostListViewController.m
//  UMCommunity
//
//  Created by umeng on 12/2/15.
//  Copyright © 2015 Umeng. All rights reserved.
//

#import "UMComHotPostViewController.h"
#import "UMComPullRequest.h"
#import "UMComNavigationController.h"
#import "UMComPostTableViewController.h"
#import "UIViewController+UMComAddition.h"
#import "UMComTopic.h"

@interface UMComHotPostViewController ()

@property (nonatomic, assign) NSInteger lastPage;

@property (nonatomic, assign) NSInteger currentPage;


@end

@implementation UMComHotPostViewController

- (instancetype)initWithTopic:(UMComTopic *)topic
{
    self = [super init];
    if (self) {
        _topic = topic;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    if (!self.topic) {
        [self createHotFeedsSubViewControllers];
    }else{
        [self createTopicHotFeedsSubViewControllers];
    }
}

- (void)setPage:(NSInteger)page
{
    _lastPage = _currentPage;
    _currentPage = page;
    [self transitionFromViewControllers];
}

- (void)transitionFromViewControllers
{
    UMComPostTableViewController *postTableVc = self.childViewControllers[self.currentPage];
    if (postTableVc.isLoadFinish && postTableVc.dataArray.count == 0) {
        [postTableVc refreshNewDataFromServer:nil];
    }
    [self transitionFromViewControllerAtIndex:self.lastPage toViewControllerAtIndex:self.currentPage duration:0 options:UIViewAnimationOptionTransitionNone animations:nil completion:nil];
}

//全局热门Feed列表
- (void)createHotFeedsSubViewControllers
{
    CGRect commonFrame = self.view.bounds;
    for (int index = 0; index < 4; index ++) {
        UMComPostTableViewController *postTableViewC = [[UMComPostTableViewController alloc] init];
        postTableViewC.isLoadLoacalData = NO;
        UMComHotFeedRequest *hotFeedRequest = [[UMComHotFeedRequest alloc]initWithCount:BatchSize withinDays:1];
        if (index == 0) {
            hotFeedRequest.days = 1;
            postTableViewC.isAutoStartLoadData = YES;
            [self.view addSubview:postTableViewC.view];
        }else if (index == 1){
            hotFeedRequest.days = 3;
        }else if (index == 2){
            hotFeedRequest.days = 7;
        }else if (index == 3){
            hotFeedRequest.days = 30;
        }
        postTableViewC.fetchRequest = hotFeedRequest;
        postTableViewC.view.frame = commonFrame;
        [self addChildViewController:postTableViewC];
    }
    [self transitionFromViewControllers];
}

//话题热门feed列表
- (void)createTopicHotFeedsSubViewControllers
{
    CGRect commonFrame = self.view.bounds;
    for (int index = 0; index < 4; index ++) {
        UMComPostTableViewController *postTableViewC = [[UMComPostTableViewController alloc] init];
        postTableViewC.isLoadLoacalData = NO;
        UMComTopicHotFeedsRequest *hotFeedRequest = [[UMComTopicHotFeedsRequest alloc]initWithTopicId:self.topic.topicID count:BatchSize withinDays:1];
        if (index == 0) {
            postTableViewC.isAutoStartLoadData = YES;
            [self.view addSubview:postTableViewC.view];
        }else if (index == 1){
            hotFeedRequest.days = 3;
        }else if (index == 2){
            hotFeedRequest.days = 7;
        }else if (index == 3){
            hotFeedRequest.days = 30;
        }
        postTableViewC.fetchRequest = hotFeedRequest;
        postTableViewC.view.frame = commonFrame;
        [self addChildViewController:postTableViewC];
    }
    [self transitionFromViewControllers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - search delegate
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
