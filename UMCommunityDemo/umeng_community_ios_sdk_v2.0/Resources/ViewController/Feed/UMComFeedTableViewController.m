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

@interface UMComFeedTableViewController ()<NSFetchedResultsControllerDelegate,UITextFieldDelegate,UMComFeedsTableViewDelegate,UMComClickActionDelegate> {
    
    NSFetchedResultsController *_fetchedResultsController;
}

@property (nonatomic, strong) UMComShareCollectionView *shareListView;

@property (nonatomic, strong) UIView *shadowBgView;

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
    
    self.feedsTableView.feedsTableViewDelegate = self;
    self.feedsTableView.clickActionDelegate = self;
    
    self.indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.frame = CGRectMake(0, 0, 40, 40);
    self.indicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.indicatorView.center = CGPointMake(self.feedsTableView.frame.size.width/2, self.feedsTableView.frame.size.height/2-40);
    [self.feedsTableView addSubview:self.indicatorView];

    if (![NSStringFromClass([self class]) isEqualToString:@"UMComUserCenterViewController"]) {
         [self refreshAllData];
    }
    if (!self.myParentViewController) {
        self.myParentViewController = self;
    }else{
    }
}


- (void)setFetchFeedsController:(UMComPullRequest *)fetchFeedsController
{
    _fetchFeedsController = fetchFeedsController;
}
- (void)refreshAllData
{
    [self.indicatorView startAnimating];
    self.indicatorView.hidden = NO;
    [self.fetchFeedsController fetchRequestFromCoreData:^(NSArray *coreData, NSError *error) {
        if (coreData.count > 0) {
            NSMutableArray *feedData = [NSMutableArray arrayWithCapacity:1];
            for (UMComFeed *feed in coreData) {
                if (!feed.isDeleted) {
                    [feedData addObject:feed];
                }
            }
//            self.feedsTableView.resultArray = [NSMutableArray arrayWithArray:[self.feedsTableView dealWithFeedData:feedData]];
            [self.feedsTableView dealWithFetchResult:feedData error:error loadMore:NO haveNextPage:NO];
            [self.indicatorView stopAnimating];
//            [self.feedsTableView reloadData];
        }
        [self refreshDataFromServer];
    }];
}


- (void)refreshDataFromServer
{
    NSArray *tempArray = self.feedsTableView.resultArray;
    [self refreshData:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        [self.indicatorView stopAnimating];
        if (data.count > 0) {
            [self showUnreadFeedWithCurrentFeedArray:tempArray compareArray:data];
            [self.feedsTableView dealWithFetchResult:data error:error loadMore:NO haveNextPage:haveNextPage];
        }
    }];
}

- (void)showUnreadFeedWithCurrentFeedArray:(NSArray *)currentArr compareArray:(NSArray *)compareArr
{
    if ([self.fetchFeedsController isKindOfClass:[UMComAllFeedsRequest class]]) {
        int unReadCount = (int)compareArr.count;
        
        for (UMComFeed *feed in compareArr) {
            for (UMComFeedStyle *feedStyle in currentArr) {
                if ([feed.feedID isEqualToString:feedStyle.feed.feedID]) {
                    unReadCount -= 1;
                    break;
                }
            }
        }
        if (unReadCount > 0) {
            [self showTipLableFromTopWithTitle:[NSString stringWithFormat:@"%d条新内容",unReadCount]];
        }
    }
}

- (void)refreshData:(LoadServerDataCompletion)completion
{
    if (!self.fetchFeedsController) {
        return;
    }
    NSArray *tempArray = self.feedsTableView.resultArray;
    [self.fetchFeedsController fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        if (!error && [data isKindOfClass:[NSArray class]] && data.count > 0) {
            [self showUnreadFeedWithCurrentFeedArray:tempArray compareArray:data];
    
        }
        completion(data,haveNextPage,error);

    }];
}


#pragma mark - UMComFeedsTableViewDelegate
- (void)feedTableView:(UMComFeedsTableView *)feedTableView refreshData:(LoadServerDataCompletion)completion
{
    [self refreshData:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        completion(data,haveNextPage,error);
    }];
}
- (void)feedTableView:(UMComFeedsTableView *)feedTableView loadMoreData:(LoadServerDataCompletion)completion
{
    if (!self.fetchFeedsController) {
        return;
    }
    [self.fetchFeedsController fetchNextPageFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        completion(data,haveNextPage,error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma UMComFeedsTableViewCellDelegate
- (void)customObj:(id)obj clickOnUser:(UMComUser *)user
{
    [[UMComUserCenterAction action] performActionAfterLogin:user viewController:self.myParentViewController completion:nil];
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
    [[UMComForwardAction action] performActionAfterLogin:feed viewController:[self myParentViewController] completion:nil];
}

- (void)customObj:(id)obj clickOnComment:(UMComComment *)comment feed:(UMComFeed *)feed
{
    [[UMComCommentOperationAction action] performActionAfterLogin:nil viewController:self.myParentViewController completion:^(NSArray *data, NSError *error) {
        if (!error) {
            [self transitionToFeedDetailViewControllerWithFeed:feed showType:UMComShowFromClickComment];
        }
    }];
}

- (void)customObj:(id)obj clickOnImageView:(UIImageView *)feed complitionBlock:(void (^)(UIViewController *))block
{
    if (block) {
        block(self.myParentViewController);
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
