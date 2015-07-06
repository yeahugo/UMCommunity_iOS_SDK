//
//  UMComSearchViewController.m
//  UMCommunity
//
//  Created by umeng on 15-4-22.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComSearchViewController.h"
#import "UMComHorizontalTableView.h"
#import "UMComAllFeedViewController.h"
#import "UMComUserRecommendViewController.h"
#import "UMComUserCenterViewController.h"
#import "UMComBarButtonItem.h"
#import "UMComShowToast.h"
#import "UMComAction.h"
#import "UMComShareCollectionView.h"
#import "UIViewController+UMComAddition.h"
#import "UMComFeedDetailViewController.h"
#import "UMComFeedsTableViewCell.h"
#import "UMComFeedsTableView.h"
#import "UMComTopicFeedViewController.h"


@interface UMComSearchViewController ()<UISearchBarDelegate,UMComFeedsTableViewDelegate,UMComClickActionDelegate>

@property (nonatomic, strong) UMComFeedsTableView *feedsTableView;
@property (nonatomic, strong) UMComHorizontalTableView *userTableView;

@property (nonatomic, strong) UMComPullRequest *userFetchRequest;
@property (nonatomic, strong) UMComPullRequest *searchFeedRequest;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UMComBarButtonItem *rightButtonItem;

@property (nonatomic, strong) UIView *spaceLine;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UMComShareCollectionView *shareListView;
@property (nonatomic, strong) UIView *shadowBgView;

@end

@implementation UMComSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-160, 30)];
    searchBar.placeholder = UMComLocalizedString(@"Enter user or content key words", @"请输入用户或内容关键字");
    searchBar.backgroundImage = [[UIImage alloc] init];
    searchBar.delegate = self;
    [self.navigationItem setTitleView:searchBar];
    [searchBar becomeFirstResponder];
    self.searchBar = searchBar;
    
    UMComBarButtonItem *rightButtonItem = [[UMComBarButtonItem alloc] initWithTitle:@"取消" target:self action:@selector(goBack:)];
    rightButtonItem.customButtonView.frame = CGRectMake(10, 0, 40, 30);
    rightButtonItem.customButtonView.titleLabel.font = UMComFontNotoSansLightWithSafeSize(17);
    self.rightButtonItem = rightButtonItem;
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]init];
    spaceItem.width = 5;
    [self.navigationItem setRightBarButtonItems:@[spaceItem,rightButtonItem,spaceItem]];
    
    self.feedsTableView = [[UMComFeedsTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-20) style:UITableViewStylePlain];
    self.feedsTableView.clickActionDelegate = self;
    self.feedsTableView.feedsTableViewDelegate = self;
    [self.feedsTableView.indicatorView removeFromSuperview];
    self.feedsTableView.scrollViewDidScroll = ^(UIScrollView *scrollView, CGFloat lastPosition){
        [searchBar resignFirstResponder];
    };
    [self.view addSubview:self.feedsTableView];
    UISwipeGestureRecognizer *leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(noAction)];
    leftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftGestureRecognizer];
    
    UISwipeGestureRecognizer *rightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(noAction)];
    rightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightGestureRecognizer];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(noAction)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)noAction
{
    [self.searchBar resignFirstResponder];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.userTableView) {
        self.feedsTableView.tableHeaderView = [self creatHorizonTbaleView]; 
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.shareListView removeFromSuperview];
    [self.shadowBgView removeFromSuperview];
}
- (UIView *)creatHorizonTbaleView
{
    self.userTableView = [[UMComHorizontalTableView alloc]initWithFrame:CGRectMake(0, 0, 100, self.view.frame.size.width) style:UITableViewStylePlain];
    self.userTableView.rowHeight = self.userTableView.frame.size.width/4;
    __weak UMComSearchViewController *weakSelf = self;
    self.userTableView.didSelectedUser = ^(UMComUser *user){
        UIViewController *tempViewController = nil;
        if (user) {
            tempViewController = [[UMComUserCenterViewController alloc] initWithUser:user];
        }else{
            UMComUserRecommendViewController *temSearchAllUserVc = [[UMComUserRecommendViewController alloc]init];
            tempViewController.title = UMComLocalizedString(@"related_user", @"相关用户");
            temSearchAllUserVc.userDataSourceType = UMComSearchUser;
            temSearchAllUserVc.userList = weakSelf.userTableView.userList;
            tempViewController = temSearchAllUserVc;
        }
        [weakSelf.navigationController pushViewController:tempViewController animated:YES];
    };
    UIView *tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    tableHeaderView.backgroundColor = [UIColor clearColor];
    [tableHeaderView addSubview:self.userTableView];
    self.userTableView.center = CGPointMake(tableHeaderView.frame.size.width/2, tableHeaderView.frame.size.height/2);
    UIView *spaceView = [[UIView alloc]initWithFrame:CGRectMake(0, 100-10, self.view.frame.size.width, 0.3)];
    spaceView.backgroundColor = TableViewSeparatorRGBColor;
    spaceView.hidden = YES;
    self.spaceLine = spaceView;
    [tableHeaderView addSubview:spaceView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, 95, 60, 12)];
    label.backgroundColor = [UIColor clearColor];
    label.text = UMComLocalizedString(@"related_feed", @"相关消息");
    label.textColor = [UMComTools colorWithHexString:FontColorGray];
    label.font = UMComFontNotoSansLightWithSafeSize(12);
    [tableHeaderView addSubview:label];
    label.hidden = YES;
    self.titleLabel = label;
    return tableHeaderView;
}


- (void)goBack:(id)sender
{
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}

#pragma mark - searchBarDelelagte
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
{
    [searchBar resignFirstResponder];
    self.titleLabel.hidden = YES;
    [self.userTableView searchUsersWithKeyWord:searchBar.text];
    [self searchFeedsWithKeyWord:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.titleLabel.hidden = YES;
    if (searchBar.text.length == 0) {
        [self.searchBar resignFirstResponder];
    }
}


- (void)searchFeedsWithKeyWord:(NSString *)keyWord
{
    self.searchText = keyWord;
    self.titleLabel.hidden = YES;
    self.searchFeedRequest = [[UMComSearchFeedRequest alloc]initWithKeywords:keyWord count:BatchSize];
    [self refreshData:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        [self.feedsTableView dealWithFetchResult:data error:error loadMore:NO haveNextPage:haveNextPage];

    }];
}

- (void)refreshData:(LoadServerDataCompletion)completion
{
    [self.feedsTableView.resultArray removeAllObjects];
    [self.searchFeedRequest fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        completion(data,haveNextPage,error);
        if (error) {
            self.titleLabel.hidden = YES;
            [UMComShowToast fetchFeedFail:error];
        }else{
            if (data.count == 0) {
                self.titleLabel.hidden = YES;
            }else{
                self.titleLabel.hidden = NO;
            }
        }
        self.spaceLine.hidden = NO;
    }];
}

#pragma mark - UMComfeedTableViewDelegate
- (void)feedTableView:(UMComFeedsTableView *)feedTableView refreshData:(LoadServerDataCompletion)completion
{
    [self refreshData:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        completion(data,haveNextPage,error);
    }];

}

- (void)feedTableView:(UMComFeedsTableView *)feedTableView loadMoreData:(LoadServerDataCompletion)completion
{
    [self.searchFeedRequest fetchNextPageFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        if (completion) {
            completion(data,haveNextPage,error);
        }
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

#pragma UMComFeedsTableViewCellDelegate
- (void)customObj:(id)obj clickOnUser:(UMComUser *)user
{
    [[UMComUserCenterAction action] performActionAfterLogin:user viewController:self completion:nil];
}

- (void)customObj:(id)obj clickOnTopic:(UMComTopic *)topic
{
    UMComTopicFeedViewController *oneFeedViewController = [[UMComTopicFeedViewController alloc] initWithTopic:topic];
    [self.navigationController  pushViewController:oneFeedViewController animated:YES];
}
- (void)customObj:(id)obj clickOnFeedText:(UMComFeed *)feed
{
    [self transitionToFeedDetailViewControllerWithFeed:feed showType:UMComShowFromClickFeedText];
}

- (void)customObj:(id)obj clickOnOriginFeedText:(UMComFeed *)feed
{
    [self transitionToFeedDetailViewControllerWithFeed:feed showType:UMComShowFromClickFeedText];
}
- (void)customObj:(id)obj clickOnLikeFeed:(UMComFeed *)feed
{
    UMComFeedsTableViewCell *cell = (UMComFeedsTableViewCell *)obj;
    if ([feed.liked boolValue] == YES) {
        [[UMComDisLikeAction action] performActionAfterLogin:feed viewController:self.self completion:^(NSArray *data, NSError *error) {
            if (!error) {
                feed.liked = @(0);
                feed.likes_count = [NSNumber numberWithInteger:[feed.likes_count integerValue] -1];
            } else {
                if (error.code == 20003) {
                    feed.liked = @(0);
                }
                [UMComShowToast deleteLikeFail:error];
            }
            [self.feedsTableView reloadRowAtIndex:cell.indexPath];

        }];
    }else{
        [[UMComLikeAction action] performActionAfterLogin:feed viewController:self completion:^(NSArray *data, NSError *error) {
            if (!error) {
                feed.liked = @(1);
                feed.likes_count = [NSNumber numberWithInteger:[feed.likes_count integerValue] +1];
            } else {
                if (error.code == 20003) {
                   feed.liked = @(1);
                }
                [UMComShowToast createLikeFail:error];
            }
            [self.feedsTableView reloadRowAtIndex:cell.indexPath];
        }];
    }
}

- (void)customObj:(id)obj clickOnForward:(UMComFeed *)feed
{
     self.feedsTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [[UMComForwardAction action] performActionAfterLogin:feed viewController:self completion:nil];
}

- (void)customObj:(id)obj clickOnComment:(UMComComment *)comment feed:(UMComFeed *)feed
{
    [[UMComCommentOperationAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        [self transitionToFeedDetailViewControllerWithFeed:feed showType:UMComShowFromClickComment];
    }];
}

- (void)customObj:(id)obj clickOnImageView:(UIImageView *)feed complitionBlock:(void (^)(UIViewController *))block
{
    if (block) {
        block(self);
    }
}

- (void)customObj:(id)obj clickOnShare:(UMComFeed *)feed
{
   
    if (!self.shareListView) {
        self.shareListView = [[UMComShareCollectionView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 120)];
    }
    if (!self.shadowBgView) {
        self.shadowBgView = [self createdShadowBgView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenShareListView)];
        [self.shadowBgView addGestureRecognizer:tap];
    }
    self.shareListView.feed = feed;
    [self showShareCollectionViewWithShareListView:self.shareListView bgView:self.shadowBgView];
}

- (void)hiddenShareListView
{
    [self hidenShareListView:self.shareListView bgView:self.shadowBgView];
}
@end
