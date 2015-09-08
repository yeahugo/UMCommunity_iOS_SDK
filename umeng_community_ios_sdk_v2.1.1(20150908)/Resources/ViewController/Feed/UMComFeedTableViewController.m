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

@interface UMComFeedTableViewController ()<NSFetchedResultsControllerDelegate,UITextFieldDelegate,UMComClickActionDelegate> {
    
    NSFetchedResultsController *_fetchedResultsController;
}

@property (nonatomic, strong) UMComShareCollectionView *shareListView;

@property (nonatomic, strong) UIView *shadowBgView;

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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.shareListView removeFromSuperview];
    [self.shadowBgView removeFromSuperview];
}

- (void)viewDidLoad
{
     [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (!feed || [feed.status intValue] >= FeedStatusDeleted) {
        return;
    }
    UMComFeedDetailViewController * feedDetailViewController = [[UMComFeedDetailViewController alloc] initWithFeed:feed showFeedDetailShowType:UMComShowFromClickFeedText];
    [self.navigationController pushViewController:feedDetailViewController animated:YES];
}

- (void)customObj:(id)obj clickOnOriginFeedText:(UMComFeed *)feed
{
    if (!feed || [feed.status intValue] >= FeedStatusDeleted) {
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
    if (!feed || [feed.status intValue] >= FeedStatusDeleted) {
        return;
    }
    if ([feed.liked boolValue] == YES) {
        [[UMComDisLikeAction action] performActionAfterLogin:feed viewController:self.self completion:^(NSArray *data, NSError *error) {
            if (!error) {
                feed.liked = @(0);
                feed.likes_count = [NSNumber numberWithInteger:[feed.likes_count integerValue] -1];
            } else {
                if (error.code == ERR_CODE_FEED_HAS_BEEN_LIKED) {
                    feed.liked = @(0);
                }
                [UMComShowToast showFetchResultTipWithError:error];
            }
            [[UMComCoreData sharedInstance] saveManagedObject:feed];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUMComLikeOperationFinish object:feed];
        }];
    }else{
        [[UMComLikeAction action] performActionAfterLogin:feed viewController:self completion:^(NSArray *data, NSError *error) {
            if (!error) {
                feed.liked = @(1);
                feed.likes_count = [NSNumber numberWithInteger:[feed.likes_count integerValue] +1];
            } else {
                if (error.code == ERR_CODE_FEED_HAS_BEEN_LIKED) {
                    feed.liked = @(1);
                }
                [UMComShowToast showFetchResultTipWithError:error];
            }
            [[UMComCoreData sharedInstance]  saveManagedObject:feed];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUMComLikeOperationFinish object:feed];
        }];
    }
}

- (void)customObj:(id)obj clickOnForward:(UMComFeed *)feed
{
    if (!feed || [feed.status intValue] >= FeedStatusDeleted) {
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
    if (!feed || [feed.status intValue] >= FeedStatusDeleted) {
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

- (void)customObj:(id)obj clickOnImageView:(UIImageView *)feed complitionBlock:(void (^)(UIViewController *))block
{
    if (block) {
        block(self);
    }
}

- (void)customObj:(id)obj clickOnShare:(UMComFeed *)feed
{
    if (!feed || [feed.status intValue] >= FeedStatusDeleted) {
        return;
    }
    if (!self.shareListView) {
        self.shareListView = [[UMComShareCollectionView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 120)];
        self.shareListView.shareViewController = self;
    }
    self.shareListView.feed = feed;
    [self.shareListView shareViewShow];
}



@end
