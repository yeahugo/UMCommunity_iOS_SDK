//
//  UMComHomeFeedViewController.m
//  UMCommunity
//
//  Created by umeng on 15-4-2.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComHomeFeedViewController.h"
#import "UMComNavigationController.h"
#import "UMComSearchBar.h"
#import "UMComFeedTableView.h"
#import "UMComAction.h"
#import "UMComPageControlView.h"
#import "UMComSearchViewController.h"
#import "UIViewController+UMComAddition.h"
#import "UMComBarButtonItem.h"
#import "UMComEditViewController.h"
#import "UMComFindViewController.h"
#import "UMComPullRequest.h"
#import "UMComPushRequest.h"
#import "UMComSession.h"
#import "UMComTopicsTableView.h"
#import "UMComLoginManager.h"
#import "UMComFeedStyle.h"
#import "UMComTopic+UMComManagedObject.h"
#import "UMComFilterTopicsViewCell.h"
#import "UMComTopicFeedViewController.h"
#import "UMComShowToast.h"
#import "UMComRefreshView.h"
#import "UMComScrollViewDelegate.h"
#import "UMComClickActionDelegate.h"
#import "UMComPushRequest.h"
#import "UMComUnReadNoticeModel.h"

#define kTagRecommend 100
#define kTagAll 101

#define DeltaBottom  45
#define DeltaRight 45

@interface UMComHomeFeedViewController ()<UISearchBarDelegate, UMComScrollViewDelegate, UMComClickActionDelegate>


@property (strong, nonatomic) UMComSearchBar *searchBar;

@property (nonatomic, strong) UMComFeedTableView *recommentfeedTableView;

@property (nonatomic, strong) UMComTopicsTableView *topicsTableView;

@property (strong,nonatomic) UMComAllTopicsRequest *allTopicsRequest;

@property (nonatomic, strong) UMComPageControlView *titlePageControl;

@property (nonatomic, strong) UIButton *findButton;

@property (nonatomic, strong) UIView *itemNoticeView;

@property (nonatomic, assign) CGFloat searchBarOriginY;

@end

@implementation UMComHomeFeedViewController
{
    BOOL  isTransitionFinish;
    CGPoint originOffset;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if ([UIApplication sharedApplication].keyWindow.rootViewController == self.navigationController) {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    //创建导航条视图
    [self creatNigationItemView];
    
    //创建serchBar
    [self creatSearchBar];

    CGRect headViewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.searchBar.frame.size.height+kUMComRefreshOffsetHeight);
//   关注页面
    self.feedsTableView.fetchRequest = [[UMComAllFeedsRequest alloc]initWithCount:BatchSize];
    self.feedsTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.feedsTableView.feedType = feedFocusType;
    [self.feedsTableView loadAllData:nil fromServer:nil];

    __weak typeof(self) weakSelf = self;
    self.feedsTableView.loadSeverDataCompletionHandler = ^(NSArray *data, BOOL haveNextPage, NSError *error){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.titlePageControl.currentPage == 0) {
            [weakSelf showUnreadFeedWithCurrentFeedArray:weakSelf.feedsTableView.dataArray compareArray:data];     
        }
    };
    self.feedsTableView.tableHeaderView = [[UIView alloc]initWithFrame:headViewFrame];

    //推荐页面
    self.recommentfeedTableView = [[UMComFeedTableView alloc]initWithFrame:CGRectMake(2*self.view.frame.size.width, self.feedsTableView.frame.origin.y, self.feedsTableView.frame.size.width, self.feedsTableView.frame.size.height) style:UITableViewStylePlain];
    [self.view addSubview:self.recommentfeedTableView];
    self.recommentfeedTableView.tableHeaderView = [[UIView alloc]initWithFrame:headViewFrame];
    self.recommentfeedTableView.fetchRequest = [[UMComRecommendFeedsRequest alloc]initWithCount:BatchSize];
    self.recommentfeedTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.recommentfeedTableView.clickActionDelegate = self;
//
//话题列表
    self.topicsTableView = [[UMComTopicsTableView alloc]initWithFrame:CGRectMake(self.recommentfeedTableView.frame.origin.x, self.recommentfeedTableView.frame.origin.y, self.recommentfeedTableView.frame.size.width, self.recommentfeedTableView.frame.size.height) style:UITableViewStylePlain];
    self.allTopicsRequest = [[UMComAllTopicsRequest alloc]initWithCount:TotalTopicSize];
    self.topicsTableView.fetchRequest = self.allTopicsRequest;
    self.topicsTableView.clickActionDelegate = self;
    self.topicsTableView.scrollViewDelegate = self;
    self.topicsTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.topicsTableView];
    self.topicsTableView.tableHeaderView = [[UIView alloc]initWithFrame:headViewFrame];
    
    UISwipeGestureRecognizer *leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipToLeftDirection:)];
    leftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftGestureRecognizer];
    
    UISwipeGestureRecognizer *rightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipToRightDirection:)];
    rightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightGestureRecognizer];
    
    [self setScrollToTopWithCurrentPage:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewFeedDataWhenFeedCreatSucceed:) name:kNotificationPostFeedResultNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshAllDataWhenLoginUserChange:) name:kUserLoginSucceedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshAllDataWhenLoginUserChange:) name:kUserLogoutSucceedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessageData:) name:kUMComRemoteNotificationReceivedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessageData:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [self.view bringSubviewToFront:self.searchBar];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.feedsTableView.scrollViewDelegate = self;
    self.recommentfeedTableView.scrollViewDelegate = self;
    if (self.titlePageControl.currentPage == 2) {
        self.editButton.hidden = YES;
    }else{
        self.editButton.hidden = NO;
    }
    isTransitionFinish = YES;
    originOffset = self.navigationController.navigationBar.frame.origin;
    self.findButton.center = CGPointMake(self.view.frame.size.width-27, self.findButton.center.y);
    self.findButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    [UIView animateWithDuration:0.3 animations:^{
        self.findButton.alpha = 1;
    }];
    [self refreshUnreadMessageNotification];
    [self.topicsTableView reloadData];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.feedsTableView.scrollViewDelegate = nil;
    self.recommentfeedTableView.scrollViewDelegate = nil;
    self.editButton.hidden = YES;
    [self hidenKeyBoard];
    self.findButton.alpha = 0;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    self.feedsTableView.hidden = YES;
    self.recommentfeedTableView.hidden = YES;
    self.topicsTableView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.feedsTableView = nil;
    self.recommentfeedTableView = nil;
    self.topicsTableView = nil;
    self.searchBar = nil;
    self.allTopicsRequest = nil;
    self.titlePageControl = nil;
    self.findButton = nil;
    self.itemNoticeView = nil;
}

#pragma mark - privite methods
/************************************************************************************/
- (void)creatSearchBar
{
    UMComSearchBar *searchBar = [[UMComSearchBar alloc] initWithFrame:CGRectMake(0, -0.3, self.view.frame.size.width, 40)];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    searchBar.placeholder = UMComLocalizedString(@"Search user and content", @"搜索用户和内容");
    searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
    self.searchBar = searchBar;
}

- (void)hidenKeyBoard
{
    [self.searchBar resignFirstResponder];
}

- (void)creatNigationItemView
{
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(self.view.frame.size.width-27, self.navigationController.navigationBar.frame.size.height/2-22, 44, 44);
    CGFloat delta = 9;
    rightButton.imageEdgeInsets =  UIEdgeInsetsMake(delta, delta, delta, delta);
    [rightButton setImage:UMComImageWithImageName(@"find+") forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(onClickFind:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:rightButton];
    self.findButton = rightButton;
    
    self.itemNoticeView = [self creatNoticeViewWithOriginX:rightButton.frame.size.width-10];
    [self.findButton addSubview:self.itemNoticeView];
    [self refreshMessageData:nil];
    //创建菜单栏
    UMComPageControlView *titlePageControl = [[UMComPageControlView alloc]initWithFrame:CGRectMake(0, 0, 180, 25) itemTitles:[NSArray arrayWithObjects:UMComLocalizedString(@"focus", @"关注"),UMComLocalizedString(@"recommend",@"推荐"),UMComLocalizedString(@"topic",@"话题"), nil] currentPage:0];
    titlePageControl.currentPage = 0;
    titlePageControl.selectedColor = [UIColor whiteColor];
    titlePageControl.unselectedColor = [UIColor blackColor];
    
    [titlePageControl setItemImages:[NSArray arrayWithObjects:UMComImageWithImageName(@"left_frame"),UMComImageWithImageName(@"midle_frame"),UMComImageWithImageName(@"right_item"), nil]];
    __weak UMComHomeFeedViewController *wealSelf = self;
    titlePageControl.didSelectedAtIndexBlock = ^(NSInteger index){
        [wealSelf transitionViewControllers:nil];
        [wealSelf hidenKeyBoard];
    };
    [self.navigationItem setTitleView:titlePageControl];
    self.titlePageControl = titlePageControl;
}

- (UIView *)creatNoticeViewWithOriginX:(CGFloat)originX
{
    CGFloat noticeViewWidth = 8;
    UIView *itemNoticeView = [[UIView alloc]initWithFrame:CGRectMake(originX,5, noticeViewWidth, noticeViewWidth)];
    itemNoticeView.backgroundColor = [UIColor redColor];
    itemNoticeView.layer.cornerRadius = noticeViewWidth/2;
    itemNoticeView.clipsToBounds = YES;
    itemNoticeView.hidden = YES;
    return itemNoticeView;
}


#pragma mark - 
- (void)refreshMessageData:(id)sender
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [UMComPushRequest requestConfigDataWithResult:^(id responseObject, NSError *error) {
        [self refreshUnreadMessageNotification];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUMComUnreadNotificationRefreshNotification object:nil userInfo:responseObject];
    }];
}


- (void)refreshUnreadMessageNotification
{
    UMComUnReadNoticeModel *unReadNotice = [UMComSession sharedInstance].unReadNoticeModel;
    if (unReadNotice.totalNotiCount == 0) {
        self.itemNoticeView.hidden = YES;
    }else{
        self.itemNoticeView.hidden = NO;
    }
}

#pragma mark - 重写父类方法
- (void)refreshAllData
{
    __weak typeof(self) weakSelf = self;
    __block NSArray *tempArray = nil;
    [self.feedsTableView loadAllData:^(NSArray *data, NSError *error) {
        tempArray = self.feedsTableView.dataArray;
    } fromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        [weakSelf showUnreadFeedWithCurrentFeedArray:tempArray compareArray:data];
    }];
}

- (void)showUnreadFeedWithCurrentFeedArray:(NSArray *)currentArr compareArray:(NSArray *)compareArr
{
    int unReadCount = (int)compareArr.count;
    for (UMComFeed *feed in compareArr) {
        for (UMComFeed *curentFeed in currentArr) {
            if ([feed.feedID isEqualToString:curentFeed.feedID]) {
                unReadCount -= 1;
                break;
            }
        }
    }
    if (unReadCount > 0) {
        [self showTipLableFromTopWithTitle:[NSString stringWithFormat:@"%d条新内容",unReadCount]];
    }
}

- (void)addNewFeedDataWhenFeedCreatSucceed:(NSNotification *)notification
{
    UMComFeed *newFeed = (UMComFeed *)notification.object;
    [self.feedsTableView insertFeedStyleToDataArrayWithFeed:newFeed];
}

#pragma mark - notifcation action
- (void)refreshAllDataWhenLoginUserChange:(NSNotification *)notification
{
    if ([kUserLogoutSucceedNotification isEqualToString:notification.name]) {
        [self.feedsTableView.dataArray removeAllObjects];
        [self.feedsTableView reloadFeedData];
        [self.recommentfeedTableView.dataArray removeAllObjects];
        [self.recommentfeedTableView reloadFeedData];
        [self.topicsTableView.dataArray removeAllObjects];
        [self.topicsTableView reloadData];
    }
    __weak typeof(self) weakSelf = self;
    if (self.titlePageControl.currentPage == 0) {
        [self.feedsTableView refreshNewDataFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            [weakSelf.recommentfeedTableView refreshNewDataFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
                [weakSelf.topicsTableView refreshNewDataFromServer:nil];
            }];
        }];
    } else if(self.titlePageControl.currentPage == 1){
        [self.recommentfeedTableView refreshNewDataFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            [weakSelf.feedsTableView refreshNewDataFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
                [weakSelf.topicsTableView refreshNewDataFromServer:nil];
            }];
        }];
    } else if (self.titlePageControl.currentPage ==2){
        [self.topicsTableView refreshNewDataFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            [weakSelf.feedsTableView refreshNewDataFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
                [weakSelf.recommentfeedTableView refreshNewDataFromServer:nil];
            }];
        }];
    }
    
    [self refreshMessageData:nil];
}


#pragma mark - 视图切换逻辑

- (void)swipToLeftDirection:(UISwipeGestureRecognizer *)swip
{
    if (self.titlePageControl.currentPage < 2) {
        self.titlePageControl.currentPage += 1;
        [self transitionViewControllers:nil];
    }
}

- (void)swipToRightDirection:(UISwipeGestureRecognizer *)swip
{
    if (self.titlePageControl.currentPage > 0) {
        self.titlePageControl.currentPage -= 1;
        [self transitionViewControllers:nil];
    }
}
- (void)transitionViewControllers:(id)sender
{
    if (!isTransitionFinish) {
        return;
    }
    UITableView *temToView = nil;
    NSInteger currentPage = self.titlePageControl.currentPage;
    if (currentPage == 0) {
        self.searchBar.placeholder = UMComLocalizedString(@"Search user and content", @"搜索用户和内容");
        self.editButton.hidden = NO;
        temToView = self.feedsTableView;
    }else if (currentPage == 1){
        self.searchBar.placeholder = UMComLocalizedString(@"Search user and content", @"搜索用户和内容");
        self.editButton.hidden = NO;
        temToView = self.recommentfeedTableView;
    }else if (currentPage == 2){
        self.editButton.hidden = YES;
        temToView = self.topicsTableView;
        self.searchBar.placeholder = UMComLocalizedString(@"Search topics", @"搜索话题");
    }
    [self transitionToViewController:temToView];
    [self setScrollToTopWithCurrentPage:currentPage];
}

- (void)setScrollToTopWithCurrentPage:(NSInteger)currentPage
{
    if (currentPage == 0) {
        self.feedsTableView.scrollsToTop = YES;
        self.recommentfeedTableView.scrollsToTop = NO;
        self.topicsTableView.scrollsToTop = NO;
    }else if (currentPage == 1){
        self.feedsTableView.scrollsToTop = NO;
        self.recommentfeedTableView.scrollsToTop = YES;
        self.topicsTableView.scrollsToTop = NO;
    }else if (currentPage == 2){
        self.feedsTableView.scrollsToTop = NO;
        self.recommentfeedTableView.scrollsToTop = NO;
        self.topicsTableView.scrollsToTop = YES;
    }
}

- (void)transitionToViewController:(UIView *)view
{
    isTransitionFinish = NO;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        view.frame = CGRectMake(0, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
        NSInteger currentPage = weakSelf.titlePageControl.currentPage;
        if (currentPage == 0) {
            weakSelf.recommentfeedTableView.frame = CGRectMake(weakSelf.view.frame.size.width, weakSelf.recommentfeedTableView.frame.origin.y, weakSelf.recommentfeedTableView.frame.size.width, weakSelf.recommentfeedTableView.frame.size.height);
            weakSelf.topicsTableView.frame = CGRectMake(weakSelf.view.frame.size.width, weakSelf.topicsTableView.frame.origin.y, weakSelf.topicsTableView.frame.size.width, weakSelf.topicsTableView.frame.size.height);
        }else if (currentPage == 1){
            if (weakSelf.recommentfeedTableView.feedStyleList.count == 0) {
                [weakSelf.recommentfeedTableView loadAllData:nil fromServer:nil];
            }
            weakSelf.feedsTableView.frame = CGRectMake(-weakSelf.view.frame.size.width, weakSelf.feedsTableView.frame.origin.y, weakSelf.feedsTableView.frame.size.width, weakSelf.feedsTableView.frame.size.height);
            weakSelf.topicsTableView.frame = CGRectMake(weakSelf.view.frame.size.width, weakSelf.topicsTableView.frame.origin.y, weakSelf.topicsTableView.frame.size.width, weakSelf.topicsTableView.frame.size.height);
        }else if (currentPage == 2){
            if (weakSelf.topicsTableView.dataArray.count == 0) {
                [weakSelf reloadTopicsDataWithSearchText:nil];
            }
            weakSelf.recommentfeedTableView.frame = CGRectMake(-weakSelf.view.frame.size.width, weakSelf.recommentfeedTableView.frame.origin.y, weakSelf.recommentfeedTableView.frame.size.width, weakSelf.recommentfeedTableView.frame.size.height);
            weakSelf.feedsTableView.frame = CGRectMake(-weakSelf.view.frame.size.width, weakSelf.feedsTableView.frame.origin.y, weakSelf.feedsTableView.frame.size.width, weakSelf.feedsTableView.frame.size.height);
        }
        self.editButton.center = CGPointMake(self.view.frame.size.width-DeltaRight, [UIApplication sharedApplication].keyWindow.bounds.size.height-DeltaBottom);
    } completion:^(BOOL finished) {
        if (finished) {
            if (view != self.topicsTableView) {
                self.editButton.center = CGPointMake(self.view.frame.size.width-DeltaRight, [UIApplication sharedApplication].keyWindow.bounds.size.height-DeltaBottom);
            }
        }
        isTransitionFinish = YES;
    }];
}


- (void)setEditButtonAnimationWithScrollView:(UIScrollView *)scrollView lastPosition:(CGPoint)lastPosition
{
    self.editButton.hidden = NO;
    if (self.editButton.superview != self.view.window) {
        [self.view.window addSubview:self.editButton];
    }
    if (scrollView.contentOffset.y >0 && scrollView.contentOffset.y > lastPosition.y+15) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.editButton.center = CGPointMake(self.editButton.center.x, [UIApplication sharedApplication].keyWindow.bounds.size.height+DeltaBottom);
        } completion:nil];
    }else{
        if (scrollView.contentOffset.y < lastPosition.y-15) {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.editButton.center = CGPointMake(self.editButton.center.x, [UIApplication sharedApplication].keyWindow.bounds.size.height-DeltaBottom);
            } completion:nil];
        }
    }
}

-(void)onClickClose:(id)sender
{
    if ([self.navigationController isKindOfClass:[UMComNavigationController class]]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)onClickFind:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            UMComFindViewController *findViewController = [[UMComFindViewController alloc] init];
            [weakSelf.navigationController  pushViewController:findViewController animated:YES];
        }
    }];
}

#pragma mark Content Filtering

- (void)searchWhenClickAtSearchButtonResult:(NSString *)keywords
{
    if([keywords length]>0)
    {
        self.topicsTableView.fetchRequest = [[UMComSearchTopicRequest alloc]initWithKeywords:keywords];
        [self.topicsTableView loadAllData:nil fromServer:nil];
    }
}

- (void)filterContentForSearchText:(NSString*)searchText
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains %@",searchText];
    NSArray *tempArray = [self.topicsTableView.dataArray filteredArrayUsingPredicate:predicate];
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:1];
    for (UMComTopic *topic in tempArray) {
        if (!topic.isFault && !topic.isDeleted) {
            [resultArray addObject:topic];
        }
    }
    self.topicsTableView.dataArray = resultArray;
    [self.topicsTableView reloadData];
}

- (void)reloadTopicsDataWithSearchText:(NSString *)searchText
{
    if (searchText!=nil && searchText.length>0) {
        [self filterContentForSearchText:searchText];
    }
    else
    {
        self.topicsTableView.fetchRequest = self.allTopicsRequest;
        [self.topicsTableView loadAllData:nil fromServer:nil];
    }
}

- (void)transitionToSearFeedViewController
{
    CGRect _currentViewFrame = self.view.frame;
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    UMComSearchViewController *searchViewController =[[UMComSearchViewController alloc]init];
    UMComNavigationController *navi = [[UMComNavigationController alloc]initWithRootViewController:searchViewController];
    
    navi.view.frame = CGRectMake(0, navigationBar.frame.size.height+originOffset.y,self.view.frame.size.width, self.view.frame.size.height);
    UIView *spaceView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    spaceView.backgroundColor = [UMComTools colorWithHexString:@"#f7f7f8"];
    [self.view addSubview:spaceView];
    __weak typeof(self) weakSelf = self;
    searchViewController.dismissBlock = ^(){
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            weakSelf.searchBar.alpha = 1;
            weakSelf.searchBar.frame = CGRectMake(0, self.searchBarOriginY, weakSelf.searchBar.frame.size.width, weakSelf.searchBar.frame.size.height);
            navigationBar.frame = CGRectMake(originOffset.x, 20, weakSelf.view.frame.size.width, navigationBar.frame.size.height);
            weakSelf.view.frame = _currentViewFrame;
            [navi.view removeFromSuperview];
            [spaceView removeFromSuperview];
        } completion:nil];
    };
    [self.view.window addSubview:navi.view];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        weakSelf.searchBar.alpha = 0;
        weakSelf.searchBar.frame = CGRectMake(0, self.searchBarOriginY-44, weakSelf.searchBar.frame.size.width, weakSelf.searchBar.frame.size.height);
        navigationBar.frame = CGRectMake(0, -44, weakSelf.view.frame.size.width, navigationBar.frame.size.height);
        weakSelf.view.frame = CGRectMake(0,- navigationBar.frame.size.height-originOffset.y, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height+navigationBar.frame.size.height+originOffset.y);
        navi.view.frame = CGRectMake(0, 20,weakSelf.view.frame.size.width, weakSelf.view.frame.size.height+navigationBar.frame.size.height);
    } completion:nil];
}



#pragma mark - searchBarDelelagte

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    __weak typeof(self) weakSelf = self;
    if (self.titlePageControl.currentPage != 2) {
        [[UMComAction action] performActionAfterLogin:searchBar.text viewController:self completion:^(NSArray *data, NSError *error) {
            if (!error) {
                [weakSelf transitionToSearFeedViewController];
            }
        }];
        return NO;
    }else{
        self.editButton.hidden = YES;
        return YES;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
{
    if (self.titlePageControl.currentPage == 2) {
        [self searchWhenClickAtSearchButtonResult:searchBar.text];
    }
    [self hidenKeyBoard];
    
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (self.titlePageControl.currentPage == 2) {
        [self reloadTopicsDataWithSearchText:searchBar.text];
    }
}

#pragma mark - UMComScrollViewDelegate
- (void)customScrollViewDidScroll:(UIScrollView *)scrollView lastPosition:(CGPoint)lastPosition
{
    if (scrollView == self.topicsTableView) {
        [self.searchBar resignFirstResponder];
    }else{
        [self setEditButtonAnimationWithScrollView:scrollView lastPosition:lastPosition];
    }
}

- (void)customScrollViewDidEnd:(UIScrollView *)scrollView lastPosition:(CGPoint)lastPosition
{
    if (scrollView != self.topicsTableView) {
        [self setEditButtonAnimationWithScrollView:scrollView lastPosition:lastPosition];
    }
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
            [weakSelf.topicsTableView reloadData];
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
    [self.navigationController pushViewController:oneFeedViewController animated:YES];}
@end
