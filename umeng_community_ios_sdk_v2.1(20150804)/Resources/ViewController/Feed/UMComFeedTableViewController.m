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
#import "UMComFeedsTableView.h"
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

@interface UMComFeedTableViewController ()<NSFetchedResultsControllerDelegate,UITextFieldDelegate,UMComClickActionDelegate> {
    
    NSFetchedResultsController *_fetchedResultsController;
}

@property (nonatomic, strong) UMComShareCollectionView *shareListView;

@property (nonatomic, strong) UIView *shadowBgView;

@property (nonatomic, strong) UIView *headerView;

@end

@implementation UMComFeedTableViewController


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

    self.feedsTableView = [[UMComFeedsTableView alloc]initWithFrame:CGRectMake(0, -kUMComRefreshOffsetHeight, self.view.frame.size.width, self.view.frame.size.height+kUMComRefreshOffsetHeight) style:UITableViewStylePlain];
    self.feedsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.feedsTableView.clickActionDelegate = self;
    [self.view addSubview:self.feedsTableView];
    
    UMComRefreshView *headView = [[UMComRefreshView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kUMComRefreshOffsetHeight)];
    self.feedsTableView.headView = headView;
    
    UMComRefreshView *footView = [[UMComRefreshView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kUMComRefreshOffsetHeight)];
    footView.isPull = NO;
    self.feedsTableView.footView = footView;
    
    [self setBackButtonWithImage];
    [self setTitleViewWithTitle:self.title];
    [self refreshAllData];
}

- (void)setFetchFeedsController:(UMComPullRequest *)fetchFeedsController
{
    _fetchFeedsController = fetchFeedsController;
    self.feedsTableView.fetchFeedsController = fetchFeedsController;
}

- (void)refreshAllData
{
    if (self.fetchFeedsController) {
        self.feedsTableView.fetchFeedsController = self.fetchFeedsController;
        [self.feedsTableView refreshAllFeedsData:nil fromServer:nil];
    }
}


- (void)refreshDataFromServer:(void (^)(NSArray *, NSError *))completion
{
    if (self.fetchFeedsController) {
        self.feedsTableView.fetchFeedsController = self.fetchFeedsController;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self.feedsTableView fetchFeedsFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
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


#pragma UMComFeedsTableViewCellDelegate
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

- (void)customObj:(id)obj clickOnLocationText:(UMComFeed *)feed
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[[[feed.location valueForKey:@"geo_point"] objectAtIndex:1] floatValue] longitude:[[[feed.location valueForKey:@"geo_point"] objectAtIndex:0] floatValue]];
    
    UMComNearbyFeedViewController *nearbyFeedViewController = [[UMComNearbyFeedViewController alloc] initWithLocation:location title:[feed.location valueForKey:@"name"]];
    [self.navigationController pushViewController:nearbyFeedViewController animated:YES];
}

- (void)customObj:(id)obj clickOnLikeFeed:(UMComFeed *)feed
{
    UMComFeedsTableViewCell *cell = (UMComFeedsTableViewCell *)obj;
    __weak typeof(self) weakSelf = self;
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
            [weakSelf.feedsTableView reloadRowAtIndex:cell.indexPath];
            
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
            [weakSelf.feedsTableView reloadRowAtIndex:cell.indexPath];
        }];
    }
}

- (void)customObj:(id)obj clickOnForward:(UMComFeed *)feed
{
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

- (void)customObj:(id)obj clickOnAddCollection:(UMComFeed *)feed
{
    __weak typeof(self) weakSelf = self;
    BOOL isFavourite = ![[feed has_collected] boolValue];
    [UMComFavouriteFeedRequest favouriteFeedWithFeedId:feed.feedID isFavourite:isFavourite completion:^(NSError *error) {
        if (!error) {
            if (isFavourite) {
                [feed setHas_collected:@1];
            }else{
                [feed setHas_collected:@0];
            }
        }
        [weakSelf.feedsTableView reloadData];
        [UMComShowToast favouriteFeedFail:error isFavourite:isFavourite];
    }];
}

- (void)hiddenShareListView
{
    [self hidenShareListView:self.shareListView bgView:self.shadowBgView];
}



@end
