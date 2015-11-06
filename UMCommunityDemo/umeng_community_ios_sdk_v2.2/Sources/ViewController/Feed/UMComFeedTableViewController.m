//
//  UMComFeedsTableViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 8/27/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComFeedTableViewController.h"
#import "UMUtils.h"
#import "UMComAction.h"
#import "UMComTools.h"
#import "UMComCoreData.h"
#import "UMComShowToast.h"
#import "UMComShareCollectionView.h"
#import "UIViewController+UMComAddition.h"
#import "UMComFeedDetailViewController.h"
#import "UMComPushRequest.h"
#import "UMComFeedsTableViewCell.h"
#import "UMComFeedTableView.h"
#import "UMComPullRequest.h"
#import "UMComTopicFeedViewController.h"
#import "UMComFeedStyle.h"
#import "UMComEditViewController.h"
#import "UMComNavigationController.h"
#import "UMComUserCenterViewController.h"
#import "UMComNearbyFeedViewController.h"
#import "UMComRefreshView.h"
#import "UMComClickActionDelegate.h"
#import "UMComFeedDetailViewController.h"
#import "UMComWebViewController.h"
#import "UMComSession.h"

@interface UMComFeedTableViewController ()<NSFetchedResultsControllerDelegate,UITextFieldDelegate,UMComClickActionDelegate> {
    
    NSFetchedResultsController *_fetchedResultsController;
}

@property (nonatomic, strong) UMComShareCollectionView *shareListView;

@property (nonatomic, strong) UIView *headerView;

@end

@implementation UMComFeedTableViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isShowLocalData = YES;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isShowLocalData = YES;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.editButton.center = CGPointMake(self.view.frame.size.width-DeltaRight, [UIApplication sharedApplication].keyWindow.bounds.size.height-DeltaBottom);
    [[UIApplication sharedApplication].keyWindow addSubview:self.editButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.editButton removeFromSuperview];
    [self.shareListView dismiss];
}

- (void)viewDidLoad
{
     [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.editButton.frame = CGRectMake(0, 0, 50, 50);
    self.editButton.center = CGPointMake(self.view.frame.size.width-DeltaRight, [UIApplication sharedApplication].keyWindow.bounds.size.height-DeltaBottom);

    [self.editButton setImage:UMComImageWithImageName(@"new") forState:UIControlStateNormal];
    [self.editButton setImage:UMComImageWithImageName(@"new+") forState:UIControlStateSelected];
    [self.editButton addTarget:self action:@selector(onClickEdit:) forControlEvents:UIControlEventTouchUpInside];
    self.editButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    self.editButton.hidden = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:self.editButton];
    
    [self setBackButtonWithImage];
    [self setTitleViewWithTitle:self.title];
    self.feedsTableView = [[UMComFeedTableView alloc]initWithFrame:CGRectMake(0, -kUMComRefreshOffsetHeight, self.view.frame.size.width, self.view.frame.size.height+kUMComRefreshOffsetHeight) style:UITableViewStylePlain];
    self.feedsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.feedsTableView.clickActionDelegate = self;
    [self.view addSubview:self.feedsTableView];
    if (self.isShowLocalData == YES) {
        [self refreshAllData];
    }else{
        [self refreshDataFromServer:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - request data
- (void)setFetchFeedsController:(UMComPullRequest *)fetchFeedsController
{
    _fetchFeedsController = fetchFeedsController;
    self.feedsTableView.fetchRequest = fetchFeedsController;
}

- (void)refreshAllData
{
    if (self.fetchFeedsController) {
        self.feedsTableView.fetchRequest = self.fetchFeedsController;
        [self.feedsTableView loadAllData:nil fromServer:nil];
    }
}

- (void)refreshDataFromServer:(void (^)(NSArray *, NSError *))completion
{
    if (self.fetchFeedsController) {
        self.feedsTableView.fetchRequest = self.fetchFeedsController;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self.feedsTableView refreshNewDataFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if (completion) {
                completion(data, error);
            }
        }];
    }
}

#pragma mark - edit button
-(void)onClickEdit:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        UMComEditViewController *editViewController = [[UMComEditViewController alloc] init];;
        UMComNavigationController *editNaviController = [[UMComNavigationController alloc] initWithRootViewController:editViewController];
        [weakSelf presentViewController:editNaviController animated:YES completion:nil];
    }];
    
}

#pragma mark -  UMComClickActionDelegate


- (void)customObj:(id)obj clickOnUser:(UMComUser *)user
{
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:user viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            UMComUserCenterViewController *userCenterVc = [[UMComUserCenterViewController alloc]initWithUser:user];
            [weakSelf.navigationController pushViewController:userCenterVc animated:YES];
        }
    }];
}

- (void)customObj:(id)obj clickOnTopic:(UMComTopic *)topic
{
    if (!topic) {
        return;
    }
    UMComTopicFeedViewController *oneFeedViewController = [[UMComTopicFeedViewController alloc] initWithTopic:topic];
    [self.navigationController  pushViewController:oneFeedViewController animated:YES];
}

- (void)customObj:(id)obj clickOnFeedText:(UMComFeed *)feed
{
    if (!feed) {
        return;
    }
    UMComFeedDetailViewController * feedDetailViewController = [[UMComFeedDetailViewController alloc] initWithFeed:feed showFeedDetailShowType:UMComShowFromClickFeedText];
    [self.navigationController pushViewController:feedDetailViewController animated:YES];
}

- (void)customObj:(id)obj clickOnOriginFeedText:(UMComFeed *)feed
{
    if (!feed) {
        return;
    }
    UMComFeedDetailViewController * feedDetailViewController = [[UMComFeedDetailViewController alloc] initWithFeed:feed showFeedDetailShowType:UMComShowFromClickFeedText];
    [self.navigationController pushViewController:feedDetailViewController animated:YES];
}

- (void)customObj:(id)obj clickOnURL:(NSString *)url
{
    UMComWebViewController * webViewController = [[UMComWebViewController alloc] initWithUrl:url];
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)customObj:(id)obj clickOnLocationText:(UMComFeed *)feed
{
    if (!feed || [feed.status intValue] >= FeedStatusDeleted) {
        return;
    }
    NSDictionary *locationDic = feed.location;
    if (!locationDic) {
        locationDic = feed.origin_feed.location;
    }
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[[[locationDic valueForKey:@"geo_point"] objectAtIndex:1] floatValue] longitude:[[[locationDic valueForKey:@"geo_point"] objectAtIndex:0] floatValue]];
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        UMComNearbyFeedViewController *nearbyFeedViewController = [[UMComNearbyFeedViewController alloc] initWithLocation:location title:[locationDic valueForKey:@"name"]];
        [weakSelf.navigationController pushViewController:nearbyFeedViewController animated:YES];
    }];
}

- (void)customObj:(id)obj clickOnLikeFeed:(UMComFeed *)feed
{
    if (!feed) {
        return;
    }
    BOOL isLike = ![feed.liked boolValue];
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
         [UMComPushRequest likeWithFeed:feed isLike:isLike completion:^(id responseObject, NSError *error) {
             if (error) {
                 [UMComShowToast showFetchResultTipWithError:error];
             }
            [[NSNotificationCenter defaultCenter] postNotificationName:kUMComLikeOperationFinishNotification object:feed];
         }];
    }];
}

- (void)customObj:(id)obj clickOnForward:(UMComFeed *)feed
{
    if (!feed) {
        return;
    }
    [[UMComAction action] performActionAfterLogin:feed viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            UMComEditViewController *editViewController = [[UMComEditViewController alloc] initWithForwardFeed:feed];
            UMComNavigationController *editNaviController = [[UMComNavigationController alloc] initWithRootViewController:editViewController];
            [self presentViewController:editNaviController animated:YES completion:nil];
        }
    }];
}

- (void)customObj:(id)obj clickOnComment:(UMComComment *)comment feed:(UMComFeed *)feed
{
    if (!feed) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            UMComFeedDetailViewController * feedDetailViewController = [[UMComFeedDetailViewController alloc] initWithFeed:feed showFeedDetailShowType:UMComShowFromClickComment];
            [weakSelf.navigationController pushViewController:feedDetailViewController animated:YES];
        }
    }];
}

- (void)customObj:(id)obj clickOnImageView:(UIImageView *)imageView complitionBlock:(void (^)(UIViewController *viewcontroller))block
{
    if (block) {
        block(self);
    }
}

- (void)customObj:(id)obj clickOnShare:(UMComFeed *)feed
{
    if (!feed) {
        return;
    }
    self.shareListView = [[UMComShareCollectionView alloc]initWithFrame:CGRectMake(0, self.view.window.frame.size.height, self.view.window.frame.size.width,120)];
    self.shareListView.feed = feed;
    self.shareListView.shareViewController = self;
    [self.shareListView shareViewShow];
}

#pragma mark - rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.shareListView dismiss];
}



@end
