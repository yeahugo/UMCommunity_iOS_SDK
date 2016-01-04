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
#import "UMComFeed.h"
#import "UMComScrollViewDelegate.h"


@interface UMComFeedTableViewController ()<NSFetchedResultsControllerDelegate,UITextFieldDelegate,UMComClickActionDelegate,UMComScrollViewDelegate> {
    
    NSFetchedResultsController *_fetchedResultsController;
}

@property (nonatomic, strong) UMComShareCollectionView *shareListView;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) NSMutableArray *feedStyleList;

@end

@implementation UMComFeedTableViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isLoadLoacalData = YES;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isLoadLoacalData = YES;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.isShowEditButton && !self.editButton.superview) {
        self.editButton.hidden = NO;
        [[UIApplication sharedApplication].keyWindow addSubview:self.editButton];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.editButton removeFromSuperview];
    [self.shareListView dismiss];
}

- (void)viewDidLoad
{
    [self.tableView registerNib:[UINib nibWithNibName:@"UMComFeedsTableViewCell" bundle:nil] forCellReuseIdentifier:@"FeedsTableViewCell"];
     [super viewDidLoad];
    
    self.feedStyleList = [NSMutableArray array];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    if (_isShowEditButton) {
        [self createEditButton];
    }
    
    [self setBackButtonWithImage];
    
    [self setTitleViewWithTitle:self.title];
}

- (void)createEditButton
{
    self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.editButton.frame = CGRectMake(0, 0, 50, 50);
    self.editButton.center = CGPointMake(self.view.frame.size.width-DeltaRight, [UIApplication sharedApplication].keyWindow.bounds.size.height-DeltaBottom);
    
    [self.editButton setImage:UMComImageWithImageName(@"new") forState:UIControlStateNormal];
    [self.editButton setImage:UMComImageWithImageName(@"new+") forState:UIControlStateSelected];
    [self.editButton addTarget:self action:@selector(onClickEdit:) forControlEvents:UIControlEventTouchUpInside];
    self.editButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [[UIApplication sharedApplication].keyWindow addSubview:self.editButton];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - deleagte 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.feedStyleList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"FeedsTableViewCell";
    UMComFeedsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    if (indexPath.row < self.feedStyleList.count) {
        [cell reloadFeedWithfeedStyle:[self.feedStyleList objectAtIndex:indexPath.row] tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float cellHeight = 0;
    if (indexPath.row < self.feedStyleList.count) {
        UMComFeedStyle *feedStyle = self.feedStyleList[indexPath.row];
        cellHeight = feedStyle.totalHeight;
    }
    return cellHeight;
}

- (void)customScrollViewDidScroll:(UIScrollView *)scrollView lastPosition:(CGPoint)lastPosition
{
    if (self.isShowEditButton) {
        [self setEditButtonAnimationWithScrollView:scrollView lastPosition:self.lastPosition];
    }
}

- (void)setEditButtonAnimationWithScrollView:(UIScrollView *)scrollView lastPosition:(CGPoint)lastPosition
{
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

#pragma mark - handdle feeds data

- (void)handleCoreDataDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if ([data isKindOfClass:[NSArray class]] &&  data.count > 0) {
        self.dataArray = data;
        NSMutableArray *nomalArray = [NSMutableArray array];
        NSMutableArray *topArray = [NSMutableArray array];
        for (UMComFeed *feed in data) {
            if ([feed.is_top boolValue] == YES) {
                [topArray addObject:feed];
            }else{
                [nomalArray addObject:feed];
            }
        }
        [topArray addObjectsFromArray:nomalArray];
        [self.feedStyleList addObjectsFromArray:[self transFormToFeedStylesWithFeedDatas:topArray]];
    }
    if (finishHandler) {
        finishHandler();
    }
}

- (void)handleServerDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        [self.feedStyleList removeAllObjects];
        if ([self.fetchRequest isKindOfClass:[UMComAllFeedsRequest class]]) {
            [self showUnreadFeedWithCurrentFeedArray:self.dataArray compareArray:data];
        }
        self.dataArray = data;
        [self.feedStyleList addObjectsFromArray:[self transFormToFeedStylesWithFeedDatas:data]];
    }else {
        [UMComShowToast showFetchResultTipWithError:error];
    }
    if (finishHandler) {
        finishHandler();
    }
}

- (void)handleLoadMoreDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error) {
        if (data.count > 0) {
            NSMutableArray *feedDatas = [NSMutableArray arrayWithArray:self.dataArray];
            [feedDatas addObjectsFromArray:data];
            self.dataArray = feedDatas;
            NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.feedStyleList];
            NSArray *array = [self transFormToFeedStylesWithFeedDatas:data];
            if (array.count > 0) {
                [tempArray addObjectsFromArray:array];
            }
            self.feedStyleList = tempArray;
            
        }else {
            [UMComShowToast showNoMore];
        }
        
    } else {
        [UMComShowToast showFetchResultTipWithError:error];
    }
    if (finishHandler) {
        finishHandler();
    }
}

- (NSArray *)transFormToFeedStylesWithFeedDatas:(NSArray *)feedList
{
    NSMutableArray *feedStyles = [NSMutableArray arrayWithCapacity:1];
    @autoreleasepool {
        for (UMComFeed *feed in feedList) {
            if (self.feedType != feedFavourateType && [feed.status integerValue]>= FeedStatusDeleted) {
                continue;
            }
            UMComFeedStyle *feedStyle = [UMComFeedStyle feedStyleWithFeed:feed viewWidth:self.tableView.frame.size.width feedType:self.feedType];
            if (feedStyle) {
                [feedStyles addObject:feedStyle];
            }
        }
    }
    return feedStyles;
}


- (void)reloadRowAtIndex:(NSIndexPath *)indexPath
{
    if ([self.tableView cellForRowAtIndexPath:indexPath]) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)insertFeedStyleToDataArrayWithFeed:(UMComFeed *)newFeed
{
    __weak typeof(self) weakSlef = self;
    if ([newFeed isKindOfClass:[UMComFeed class]] && ![self.dataArray containsObject:newFeed]) {
        __block NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataArray];
        [tempArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UMComFeed *feed = (UMComFeed *)obj;
            if ([feed.is_top boolValue] == NO) {
                [tempArray insertObject:newFeed atIndex:idx];
                weakSlef.dataArray = tempArray;
                UMComFeedStyle *feedStyle = [UMComFeedStyle feedStyleWithFeed:newFeed viewWidth:weakSlef.tableView.frame.size.width feedType:weakSlef.feedType];
                [self.feedStyleList insertObject:feedStyle atIndex:idx];
                *stop = YES;
                [weakSlef insertCellAtRow:idx section:0];
            }
        }];
    }
}

- (void)deleteFeed:(UMComFeed *)feed
{
    __weak typeof(self) weakSelf = self;
    [self.feedStyleList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UMComFeedStyle *feedStyle = obj;
        if ([feedStyle.feed.feedID isEqualToString:feed.feedID]) {
            *stop = YES;
            [weakSelf.feedStyleList removeObject:feedStyle];
            [weakSelf.tableView reloadData];
        }
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

#pragma mark - edit button
-(void)onClickEdit:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        UMComEditViewController *editViewController = [[UMComEditViewController alloc] init];
        if ([weakSelf.fetchRequest isKindOfClass:[UMComAllFeedsRequest class]] || ([weakSelf.fetchRequest isKindOfClass:[UMComUserFeedsRequest class]] && [weakSelf.fetchRequest.fuid isEqualToString:[UMComSession sharedInstance].uid]) || [weakSelf.fetchRequest isKindOfClass:[UMComTopicFeedsRequest class]]) {
            editViewController.createFeedSucceed = ^(UMComFeed *feed){
                [weakSelf insertFeedStyleToDataArrayWithFeed:feed];
            };
        }
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
    __weak typeof(self) weakSelf = self;
    UMComFeedDetailViewController * feedDetailViewController = [[UMComFeedDetailViewController alloc] initWithFeed:feed showFeedDetailShowType:UMComShowFromClickFeedText];
    feedDetailViewController.deletedCompletion = ^(UMComFeed *feed){
        [weakSelf deleteFeed:feed];
    };
    feedDetailViewController.dismissFromDetailVc = ^(){
        [weakSelf.tableView reloadData];
    };
    [self.navigationController pushViewController:feedDetailViewController animated:YES];
}

- (void)customObj:(id)obj clickOnOriginFeedText:(UMComFeed *)feed
{
    if (!feed) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    UMComFeedDetailViewController * feedDetailViewController = [[UMComFeedDetailViewController alloc] initWithFeed:feed showFeedDetailShowType:UMComShowFromClickFeedText];
    feedDetailViewController.dismissFromDetailVc = ^(){
        [weakSelf.tableView reloadData];
    };
    feedDetailViewController.deletedCompletion = ^(UMComFeed *feed){
        [weakSelf.tableView reloadData];
    };
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
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
         [UMComPushRequest likeWithFeed:feed isLike:isLike completion:^(id responseObject, NSError *error) {
             if (error) {
                 [UMComShowToast showFetchResultTipWithError:error];
             }
             [weakSelf reloadRowAtIndex:[weakSelf.tableView indexPathForCell:obj]];
         }];
    }];
}

- (void)customObj:(id)obj clickOnForward:(UMComFeed *)feed
{
    if (!feed) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:feed viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            UMComEditViewController *editViewController = [[UMComEditViewController alloc] initWithForwardFeed:feed];
            if ([weakSelf.fetchRequest isKindOfClass:[UMComAllFeedsRequest class]] || ([weakSelf.fetchRequest isKindOfClass:[UMComUserFeedsRequest class]] && [weakSelf.fetchRequest.fuid isEqualToString:[UMComSession sharedInstance].uid]) || [weakSelf.fetchRequest isKindOfClass:[UMComTopicFeedsRequest class]]) {
                editViewController.createFeedSucceed = ^(UMComFeed *feed){
                    [weakSelf insertFeedStyleToDataArrayWithFeed:feed];
                };
            }
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
