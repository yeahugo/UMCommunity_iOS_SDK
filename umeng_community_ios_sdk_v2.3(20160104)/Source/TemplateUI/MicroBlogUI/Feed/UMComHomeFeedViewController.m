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
#import "UMComFeed.h"
#import "UMComCoreData.h"
#import "UMComFeedTableViewController.h"
#import "UMComTopicsTableViewController.h"

#define kTagRecommend 100
#define kTagAll 101

#define DeltaBottom  45
#define DeltaRight 45

@interface UMComHomeFeedViewController ()<UISearchBarDelegate, UMComScrollViewDelegate, UMComClickActionDelegate>


@property (strong, nonatomic) UMComSearchBar *searchBar;

@property (nonatomic, strong) UMComPageControlView *titlePageControl;

@property (nonatomic, strong) UIButton *findButton;

@property (nonatomic, strong) UIView *itemNoticeView;

@property (nonatomic, assign) CGFloat searchBarOriginY;

@property (nonatomic, assign) NSInteger preIndex;

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
    
    UISwipeGestureRecognizer *leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipToLeftDirection:)];
    leftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftGestureRecognizer];
    
    UISwipeGestureRecognizer *rightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipToRightDirection:)];
    rightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightGestureRecognizer];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshAllDataWhenLoginUserChange:) name:kUserLoginSucceedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshAllDataWhenLoginUserChange:) name:kUserLogoutSucceedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessageData:) name:kUMComRemoteNotificationReceivedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessageData:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    //当删除自己的Feed时更新关注列表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyDataWhenDeletedFeed:) name:kUMComFeedDeletedFinishNotification object:nil];
    //当创建新Feed时通知关注页面刷新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewFeedWhenCreatSucceed:) name:kNotificationPostFeedResultNotification object:nil];
    [self.view bringSubviewToFront:self.searchBar];
    
    [self createSubControllers];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isTransitionFinish = YES;
    originOffset = self.navigationController.navigationBar.frame.origin;
    self.findButton.center = CGPointMake(self.view.frame.size.width-27, self.findButton.center.y);
    self.findButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    [UIView animateWithDuration:0.3 animations:^{
        self.findButton.alpha = 1;
    }];
    [self refreshUnreadMessageNotification];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hidenKeyBoard];
    self.findButton.alpha = 0;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.searchBar = nil;
    self.titlePageControl = nil;
    self.findButton = nil;
    self.itemNoticeView = nil;
}

#pragma mark - 



#pragma mark - privite methods
/************************************************************************************/
- (void)createSubControllers
{
    CGRect commonFrame = self.view.frame;
    commonFrame.origin.y = self.searchBar.frame.size.height;
    commonFrame.size.height = commonFrame.size.height - commonFrame.origin.y;
    CGFloat centerY = commonFrame.size.height/2+commonFrame.origin.y;
    UMComFeedTableViewController *focusedListController = [[UMComFeedTableViewController alloc] initWithFetchRequest:[[UMComAllFeedsRequest alloc] initWithCount:BatchSize]];
    focusedListController.isAutoStartLoadData = YES;
    focusedListController.isShowEditButton = YES;
    focusedListController.feedType = feedFocusType;
    [self addChildViewController:focusedListController];
    [self.view addSubview:focusedListController.view];
    focusedListController.view.frame = commonFrame;
    [focusedListController loadAllData:nil fromServer:nil];
    
    UMComFeedTableViewController *recommendPostListController = [[UMComFeedTableViewController alloc] initWithFetchRequest:[[UMComRecommendFeedsRequest alloc] initWithCount:BatchSize]];
    [self addChildViewController:recommendPostListController];
    recommendPostListController.isShowEditButton = YES;
    recommendPostListController.view.frame = commonFrame;
    recommendPostListController.view.center = CGPointMake(commonFrame.size.width * 3 / 2, centerY);
    
    UMComTopicsTableViewController *followingPostListController = [[UMComTopicsTableViewController alloc] initWithFetchRequest:[[UMComAllTopicsRequest alloc] initWithCount:BatchSize]];
    [self addChildViewController:followingPostListController];
    followingPostListController.view.frame = commonFrame;
    followingPostListController.scrollViewDelegate = self;
    followingPostListController.view.center = CGPointMake(commonFrame.size.width * 3 / 2, centerY);
    [self transitionViewControllers];
}

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
        [wealSelf transitionViewControllers];
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
- (void)updateMyDataWhenDeletedFeed:(NSNotification *)notification
{
    UMComFeedTableViewController *feedTableVc = self.childViewControllers[0];
    [feedTableVc deleteFeed:notification.object];
}

- (void)addNewFeedWhenCreatSucceed:(NSNotification *)notification
{
    UMComFeedTableViewController *feedTableVc = self.childViewControllers[0];
    [feedTableVc insertFeedStyleToDataArrayWithFeed:notification.object];
}


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

#pragma mark - notifcation action
- (void)refreshAllDataWhenLoginUserChange:(NSNotification *)notification
{
    UMComRequestTableViewController *requestTableView = self.childViewControllers[self.titlePageControl.currentPage];
    requestTableView.dataArray = nil;
    [requestTableView.tableView reloadData];
    if (self.titlePageControl.currentPage == 0) {
        [requestTableView refreshNewDataFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            [requestTableView refreshNewDataFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
                [requestTableView refreshNewDataFromServer:nil];
            }];
        }];
    } else if(self.titlePageControl.currentPage == 1){
        [requestTableView refreshNewDataFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            [requestTableView refreshNewDataFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
                [requestTableView refreshNewDataFromServer:nil];
            }];
        }];
    } else if (self.titlePageControl.currentPage ==2){
        [requestTableView refreshNewDataFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            [requestTableView refreshNewDataFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
                [requestTableView refreshNewDataFromServer:nil];
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
        [self transitionViewControllers];
    }
}

- (void)swipToRightDirection:(UISwipeGestureRecognizer *)swip
{
    if (self.titlePageControl.currentPage > 0) {
        self.titlePageControl.currentPage -= 1;
        [self transitionViewControllers];
    }
}
- (void)transitionViewControllers
{
    [self hidenKeyBoard];
    NSInteger currentPage = self.titlePageControl.currentPage;
    
    UMComRequestTableViewController *requestViewController = self.childViewControllers[currentPage];
    UMComFeedTableViewController *focusedTableController = self.childViewControllers[0];
    UMComFeedTableViewController *recommentTableController = self.childViewControllers[1];
    if (currentPage == 0) {
        self.searchBar.placeholder = UMComLocalizedString(@"Search user and content", @"搜索用户和内容");
        focusedTableController.editButton.hidden = NO;
        recommentTableController.editButton.hidden = YES;
    }else if (currentPage == 1){
        focusedTableController.editButton.hidden = YES;
        recommentTableController.editButton.hidden = NO;
        self.searchBar.placeholder = UMComLocalizedString(@"Search user and content", @"搜索用户和内容");
    }else if (currentPage == 2){
        self.searchBar.placeholder = UMComLocalizedString(@"Search topics", @"搜索话题");
        focusedTableController.editButton.hidden = YES;
        recommentTableController.editButton.hidden = YES;
    }
    if (requestViewController.dataArray.count == 0 && requestViewController.isLoadFinish) {
        [requestViewController loadAllData:nil fromServer:nil];
    }
    [self transitionFromViewControllerAtIndex:self.titlePageControl.lastPage toViewControllerAtIndex:currentPage animations:nil completion:nil];
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


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
{
    if (self.titlePageControl.currentPage == 2) {
        UMComTopicsTableViewController *topicTableVc = self.childViewControllers[2];
        [topicTableVc searchTopicsFromServerWithKeyWord:searchBar.text];
    }
    [self hidenKeyBoard];
    
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (self.titlePageControl.currentPage == 2) {
        UMComTopicsTableViewController *topicTableVc = self.childViewControllers[2];
        [topicTableVc searchTopicsFromLocalWithKeyWord:searchBar.text];
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
        return YES;
    }
}

#pragma mark - topic tableView scrollDelegate
- (void)customScrollViewEndDrag:(UIScrollView *)scrollView lastPosition:(CGPoint)lastPosition
{
    [self hidenKeyBoard];
}

@end
