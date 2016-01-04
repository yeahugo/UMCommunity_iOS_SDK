//
//  UMComForumHomeViewController.m
//  UMCommunity
//
//  Created by umeng on 15/11/16.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumHomeViewController.h"
#import "UMComHorizonMenuView.h"
#import "UMComTools.h"
#import "UIViewController+UMComAddition.h"
#import "UMComPullRequest.h"
#import "UMComTopic.h"
#import "UMComForumAllTopicTableViewController.h"
#import "UMComAction.h"
#import "UMComForumDiscoverViewController.h"
#import "UMComHorizonCollectionView.h"
#import "UMComPostTableViewController.h"
#import "UMComPostingViewController.h"
#import "UMComSearchBar.h"
#import "UMComSearchPostViewController.h"
#import "UMComNavigationController.h"
#import "UMComForumSearchTopicTableViewController.h"
#import "UMComHotPostViewController.h"

//颜色值
#define UMCom_Forum_Home_TopMenu_NomalTextColor @"#999999"
#define UMCom_Forum_Home_TopMenu_HighLightTextColor @"#008BEA"
#define UMCom_Forum_Home_DropMenu_NomalTextColor @"#8F8F8F"
#define UMCom_Forum_Home_DorpMenu_HighLightTextColor @"#F5F5F5"

//文字大小
#define UMCom_Forum_Home_TopMenu_TextFont 18
#define UMCom_Forum_Home_DropMenu_TextFont 15



@interface UMComForumHomeViewController ()
<UMComHorizonCollectionViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UIButton *findButton;

@property (nonatomic, strong) UIView *itemNoticeView;

@property (nonatomic, strong) UMComHorizonCollectionView *menuView;

@property (nonatomic, strong) UMComSearchBar *searchBar;

@property (nonatomic, assign) CGFloat searchBarOriginY;

@property (nonatomic, strong) NSArray *searViewControllers;


@end

@implementation UMComForumHomeViewController
{
    CGPoint originOffset; //全部话题搜索页面的起始位置
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.findButton.hidden = NO;
    self.menuView.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.findButton.hidden = YES;
    self.menuView.hidden = YES;
    [self.menuView hiddenDropMenuView];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if (![[UIApplication sharedApplication] isStatusBarHidden]) {
        CGPoint temp_originOffset = [[UIApplication sharedApplication] statusBarFrame].origin;
        temp_originOffset.y += [[UIApplication sharedApplication] statusBarFrame].size.height;
        originOffset = temp_originOffset;
    }
    
    [self setForumUIBackButton];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    [self createDiscoverView];
    
    UMComHorizonCollectionView *collectionMenuView = [[UMComHorizonCollectionView alloc]initWithFrame:CGRectMake(40, 7, self.view.frame.size.width - 80, 30) itemCount:4];
    collectionMenuView.cellDelegate = self;
    collectionMenuView.dropMenuTopMargin = 4;
    collectionMenuView.indicatorLineHeight = 2;
    collectionMenuView.indicatorLineWidth = UMComWidthScaleBetweenCurentScreenAndiPhone6Screen(35.f);
    collectionMenuView.dropMenuSuperView = self.view;
    collectionMenuView.scrollIndicatorView.backgroundColor = UMComColorWithColorValueString(FontColorBlue);
    collectionMenuView.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar addSubview:collectionMenuView];
    self.menuView = collectionMenuView;
    
    UMComSearchBar *searchBar = [[UMComSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    searchBar.placeholder = UMComLocalizedString(@"Search user and content", @"搜索用户和内容");
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
    self.searchBar = searchBar;
    
    [self createSubControllers];
    
    [self transitionToPageAtIndex:0];
    
    self.searViewControllers = [NSArray arrayWithObjects:@"UMComSearchPostViewController",@"UMComSearchPostViewController",@"UMComSearchPostViewController",@"UMComForumSearchTopicTableViewController", nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshAllDataWhenLoginUserChange) name:kUserLoginSucceedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshAllDataWhenLoginUserChange) name:kUserLogoutSucceedNotification object:nil];
}

- (void)refreshAllDataWhenLoginUserChange
{
    for (int index = 1; index < 3 ; index ++) {
        UMComRequestTableViewController *requestTableViewController = self.childViewControllers[index];
        requestTableViewController.dataArray = nil;
        [requestTableViewController.tableView reloadData];
        if (index == 1) {
            requestTableViewController.fetchRequest = [[UMComRecommendFeedsRequest alloc] initWithCount:BatchSize];
        }else if (index == 2){
            requestTableViewController.fetchRequest = [[UMComAllFeedsRequest alloc] initWithCount:BatchSize];
        }
        if (index == self.menuView.currentIndex) {
            [requestTableViewController refreshNewDataFromServer:nil];
        }
    }
}


- (void)createSubControllers
{
    CGRect commonFrame = self.view.frame;
    commonFrame.origin.y = self.searchBar.frame.size.height;
    commonFrame.size.height = commonFrame.size.height - commonFrame.origin.y;
    CGFloat centerY = commonFrame.size.height/2+commonFrame.origin.y;
    UMComHotPostViewController *hotPostListController = [[UMComHotPostViewController alloc]init];
    hotPostListController.view.frame = commonFrame;
    [self addChildViewController:hotPostListController];
    [self.view addSubview:hotPostListController.view];
    
    UMComPostTableViewController *recommendPostListController = [[UMComPostTableViewController alloc] initWithFetchRequest:[[UMComRecommendFeedsRequest alloc] initWithCount:BatchSize]];
    recommendPostListController.view.frame = commonFrame;
    recommendPostListController.view.center = CGPointMake(commonFrame.size.width * 3 / 2, centerY);
    [self addChildViewController:recommendPostListController];
    recommendPostListController.isAutoStartLoadData = NO;
    recommendPostListController.isLoadLoacalData = YES;
    
    UMComPostTableViewController *followingPostListController = [[UMComPostTableViewController alloc] initWithFetchRequest:[[UMComAllFeedsRequest alloc] initWithCount:BatchSize]];
    followingPostListController.view.frame = commonFrame;
    followingPostListController.view.center = CGPointMake(commonFrame.size.width * 3 / 2, centerY);
    [self addChildViewController:followingPostListController];
    followingPostListController.isAutoStartLoadData = NO;
    followingPostListController.showTopMark = YES;
    
    UMComForumAllTopicTableViewController *forumViewController = [[UMComForumAllTopicTableViewController alloc]init];
    forumViewController.view.frame = commonFrame;
    forumViewController.view.center = CGPointMake(commonFrame.size.width*3/2,centerY);
    [self addChildViewController:forumViewController];
    
    [self transitionToPageAtIndex:0];
}

- (void)createDiscoverView
{
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(self.view.frame.size.width-45, self.navigationController.navigationBar.frame.size.height/2-22, 44, 44);
    CGFloat delta = 9;
    rightButton.imageEdgeInsets =  UIEdgeInsetsMake(delta, delta, delta, delta);
    [rightButton setImage:UMComImageWithImageName(@"um_discover_forum") forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(onClickDiscover:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:rightButton];
    self.findButton = rightButton;
    self.itemNoticeView = [self creatNoticeViewWithOriginX:rightButton.frame.size.width-10];
    [self.findButton addSubview:self.itemNoticeView];
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

#pragma mark - HorizionMenuViewDelegate
- (void)horizonCollectionView:(UMComHorizonCollectionView *)collectionView reloadCell:(UMComHorizonCollectionCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    CGRect labelFrame = cell.label.frame;
    cell.label.textAlignment = NSTextAlignmentLeft;
    if (indexPath.row == 0) {
        cell.label.text = UMComLocalizedString(@"um_com_forum_post_hot",@"热门");
        labelFrame.size.width = 40;
        cell.imageView.hidden = NO;
    }else if (indexPath.row == 1){
        cell.imageView.hidden = YES;
        cell.label.text = UMComLocalizedString(@"um_com_forum_post_recommend",@"推荐");
    }else if (indexPath.row == 2){
        cell.imageView.hidden = YES;
        cell.label.text = UMComLocalizedString(@"um_com_forum_post_following", @"关注");
    }else if (indexPath.row == 3){
        cell.label.text = UMComLocalizedString(@"um_com_forum_post_topic",@"话题");
        labelFrame.size.width = 40;
        cell.imageView.hidden = NO;
    }
    CGRect imageFrame = cell.imageView.frame;
    imageFrame.origin.x = UMComWidthScaleBetweenCurentScreenAndiPhone6Screen(42);;
    imageFrame.origin.y = UMComWidthScaleBetweenCurentScreenAndiPhone6Screen(12);;
    imageFrame.size.height = UMComWidthScaleBetweenCurentScreenAndiPhone6Screen(8);;
    imageFrame.size.width = UMComWidthScaleBetweenCurentScreenAndiPhone6Screen(16);
    cell.imageView.frame = imageFrame;
    if (indexPath.row == collectionView.currentIndex) {
        cell.imageView.image = UMComImageWithImageName(@"um_dropdownblue_forum");
        cell.label.textColor = UMComColorWithColorValueString(UMCom_Forum_Home_TopMenu_HighLightTextColor);
    }else{
        cell.imageView.image = UMComImageWithImageName(@"um_dropdowngray_forum");
        cell.label.textColor = UMComColorWithColorValueString(UMCom_Forum_Home_DropMenu_NomalTextColor);
    }
    cell.label.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_Home_TopMenu_TextFont);
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.label.frame = labelFrame;
}

- (BOOL)horizonCollectionView:(UMComHorizonCollectionView *)collectionView showDropDownMenuAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.row == 3) {
        return YES;
    }else{
        return NO;
    }
}


- (NSInteger)horizonCollectionView:(UMComHorizonCollectionView *)collectionView numbersOfDropdownMenuRowsAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 4;
    }else if (indexPath.row == 3){
        return 3;
    }else{
        return 0;
    }
}

- (void)horizonCollectionView:(UMComHorizonCollectionView *)collectionView didSelectedColumn:(NSInteger)column
{
    if (column == 0 || column == 3) {
        return;
    }
    [self transitionToPageAtIndex:column];
}

- (void)horizonCollectionView:(UMComHorizonCollectionView *)collectionView
       reloadDropdownMuneCell:(UMComDropdownColumnCell *)cell
                       column:(NSInteger)column
                          row:(NSInteger)row
{
    if (column == 0) {
        if (row == 0) {
            cell.label.text = @"1天";
        }else if (row == 1){
            cell.label.text = @"3天";
        }else if (row == 2){
            cell.label.text = @"7天";
        }else if (row == 3){
            cell.label.text = @"30天";
        }
    }else if (column == 3){
        if (row == 0) {
            cell.label.text = @"我关注的";
        }else if (row == 1){
            cell.label.text = @"推荐话题";
        }else if (row == 2){
            cell.label.text = @"全部话题";
        }
    }
    cell.label.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_Home_DropMenu_TextFont);
}

- (void)horizonCollectionView:(UMComHorizonCollectionView *)collectionView
            didSelectedColumn:(NSInteger)column
                          row:(NSInteger)row
{
    if (column == 0) {
        UMComHotPostViewController *hotPostTableViewController = self.childViewControllers[column];
        hotPostTableViewController.page = row;
    }else if (column == 3){
        UMComForumAllTopicTableViewController *allTopicTableViewController = self.childViewControllers[column];
        allTopicTableViewController.page = row;
    }
    [self transitionToPageAtIndex:column];
}

#pragma mark - 

- (void)transitionToPageAtIndex:(NSInteger)index
{
    if (index == 3) {
        self.searchBar.placeholder = UMComLocalizedString(@"Search_Topic", @"搜索话题");
    }else{
        self.searchBar.placeholder = UMComLocalizedString(@"Search user and content", @"搜索用户和内容");
    }
    UIViewController *toViewController = self.childViewControllers[index];
    if (index != 0 && index != 3) {
        UMComRequestTableViewController *requestTableViewVC = (UMComRequestTableViewController *)toViewController;
        if (requestTableViewVC.dataArray.count == 0) {
            [requestTableViewVC loadAllData:^(NSArray *data, NSError *error) {
                
            } fromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
                
            }];
        }
    }
    [self transitionFromViewControllerAtIndex:self.menuView.previewsIndex toViewControllerAtIndex:self.menuView.currentIndex animations:nil completion:nil];
}

- (void)onClickDiscover:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            UMComForumDiscoverViewController *findViewController = [[UMComForumDiscoverViewController alloc] init];
            [weakSelf.navigationController  pushViewController:findViewController animated:YES];
        }
    }];
}



- (void)transitionToSearViewController
{
    CGRect _currentViewFrame = self.view.frame;
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    UIView *spaceView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    spaceView.backgroundColor = [UMComTools colorWithHexString:@"#f7f7f8"];
    [self.view addSubview:spaceView];
    __weak typeof(self) weakSelf = self;
    
    Class viewControllerClass = NSClassFromString(self.searViewControllers[self.menuView.currentIndex]);
    UIViewController *searchViewController =[[viewControllerClass alloc]init];
    UMComNavigationController *navi = [[UMComNavigationController alloc]initWithRootViewController:searchViewController];
    navi.view.frame = CGRectMake(0, navigationBar.frame.size.height+originOffset.y,self.view.frame.size.width, self.view.frame.size.height);
    void (^dismissBlock)() = ^(){
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            weakSelf.searchBar.alpha = 1;
            weakSelf.searchBar.frame = CGRectMake(0, self.searchBarOriginY, weakSelf.searchBar.frame.size.width, weakSelf.searchBar.frame.size.height);
            navigationBar.frame = CGRectMake(originOffset.x, originOffset.y, weakSelf.view.frame.size.width, navigationBar.frame.size.height);
            weakSelf.view.frame = _currentViewFrame;
            [navi.view removeFromSuperview];
            [spaceView removeFromSuperview];
        } completion:nil];
    };
    if (self.menuView.currentIndex == 3) {
        UMComForumSearchTopicTableViewController *searchPostViewController = (UMComForumSearchTopicTableViewController *)searchViewController;
        searchPostViewController.dismissBlock = dismissBlock;
    }else{
        UMComSearchPostViewController *searchPostViewController = (UMComSearchPostViewController *)searchViewController;
        searchPostViewController.dismissBlock = dismissBlock;
    }
    [self.view.window addSubview:navi.view];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        weakSelf.searchBar.alpha = 0;
        weakSelf.searchBar.frame = CGRectMake(0, self.searchBarOriginY-44, weakSelf.searchBar.frame.size.width, weakSelf.searchBar.frame.size.height);
        navigationBar.frame = CGRectMake(0, -44, weakSelf.view.frame.size.width, navigationBar.frame.size.height);
        weakSelf.view.frame = CGRectMake(0,- navigationBar.frame.size.height-originOffset.y, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height+navigationBar.frame.size.height+originOffset.y);
        navi.view.frame = CGRectMake(0, originOffset.y,weakSelf.view.frame.size.width, weakSelf.view.frame.size.height+navigationBar.frame.size.height);
    } completion:nil];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    
    [self.menuView hiddenDropMenuView];
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        [weakSelf transitionToSearViewController];
    }];
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
