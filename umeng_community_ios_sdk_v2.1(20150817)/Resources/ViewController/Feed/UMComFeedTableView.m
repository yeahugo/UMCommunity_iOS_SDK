//
//  UMComFeedsTableView.m
//  UMCommunity
//
//  Created by Gavin Ye on 12/5/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComFeedTableView.h"
#import "UMComFeedsTableViewCell.h"
#import "UMComUser.h"
#import "UMComFeedTableViewController.h"
#import "UMComPullRequest.h"
#import "UMComCoreData.h"
#import "UMComShowToast.h"
#import "UMComAction.h"
#import "UMComFeedStyle.h"
#import "UMComRefreshView.h"
#import "UMComClickActionDelegate.h"
#import "UMComScrollViewDelegate.h"
#import "UIView+UMComTipLabel.h"
#import "UMComFeedContentView.h"

@interface UMComFeedTableView()<UMComRefreshViewDelegate>

@end

#define kFetchLimit 20

@implementation UMComFeedTableView

- (void)initTableView
{
    [self registerNib:[UINib nibWithNibName:@"UMComFeedsTableViewCell" bundle:nil] forCellReuseIdentifier:@"FeedsTableViewCell"];
    self.showDistance = NO;
    self.noDataTipLabel.text = UMComLocalizedString(@"no_feeds", @"暂时没有消息咯");
    if ([[[UIDevice currentDevice] systemVersion]floatValue] >= 7.0) {
        self.refreshController.footView.lineSpace.hidden = NO;
    }
    self.rowHeight = 150;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forwardFeedFinish:) name:kNotificationPostFeedResult object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedDeletedFinishAction:) name:kUMComFeedDeletedFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentOperationFinishAction:) name:kUMComCommentOperationFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeOperationFinishAction:) name:kUMComLikeOperationFinish object:nil];
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionOperationFinish:) name:kUMComCollectionOperationFinish object:nil];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.dataArray = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initTableView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self initTableView];
    }
    return self;
}

-(void)awakeFromNib
{
    [self initTableView];
    [super awakeFromNib];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"FeedsTableViewCell";
    UMComFeedsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self.clickActionDelegate;
    if (indexPath.row < self.dataArray.count) {
        cell.feedContentView.showDistance = self.showDistance;
        [cell reloadFeedWithfeedStyle:[self.dataArray objectAtIndex:indexPath.row] tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float cellHeight = 0;
    if (indexPath.row < self.dataArray.count) {
        UMComFeedStyle *feedStyle = self.dataArray[indexPath.row];
        cellHeight = feedStyle.totalHeight;
    }
    return cellHeight;
}


#pragma mark - handdle feeds data

- (void)handleCoreDataDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if ([data isKindOfClass:[NSArray class]] &&  data.count > 0) {
        NSMutableArray *topArray = [NSMutableArray array];
        NSMutableArray *nomalArray = [NSMutableArray array];
        for (UMComFeed *feed in data) {
            if ([feed.is_lististop boolValue] == YES) {
                [topArray addObject:feed];
            }else{
                [nomalArray addObject:feed];
            }
        }
        [topArray addObjectsFromArray:nomalArray];
        [self.dataArray removeAllObjects];
        NSArray *feedStyleArray = [self transformFeedDatasToFeedStylesData:data];
        [self.dataArray addObjectsFromArray:feedStyleArray];
    }
    if (finishHandler) {
        finishHandler();
    }
}

- (void)handleServerDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        [self.dataArray removeAllObjects];
        NSArray *feedStyleArray = [self transformFeedDatasToFeedStylesData:data];
        [self.dataArray addObjectsFromArray:feedStyleArray];
    }else if (error){
        [UMComShowToast showFetchResultTipWithError:error];
    }
    for (UMComFeedStyle *feedStyle in self.dataArray) {
        if ([feedStyle.feed.feedID isEqualToString:@"54b39c320bbbafcf887e620c"]) {
            NSLog(@"54b39c320bbbafcf887e620c : %@",feedStyle.feed.text);
        }
    }
    if (finishHandler) {
        finishHandler();
    }
}

- (void)handleLoadMoreDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error) {
        if (data.count > 0) {
            [self.dataArray addObjectsFromArray:[self transformFeedDatasToFeedStylesData:data]];
            if (finishHandler) {
                finishHandler();
            }
        }else {
            
            [UMComShowToast showNoMore];
        }
    } else {
        [UMComShowToast showFetchResultTipWithError:error];
    }
}


- (NSArray *)transformFeedDatasToFeedStylesData:(NSArray *)dataArr
{
     NSMutableArray *topItems = [NSMutableArray arrayWithCapacity:1];
    for (UMComFeed *feed in dataArr) {
        UMComFeedStyle *feedStyle = [UMComFeedStyle feedStyleWithFeed:feed viewWidth:self.frame.size.width feedType:feedCellType];
        [topItems addObject:feedStyle];
    }
    return topItems;
}

#pragma mark - Feed Operation Finish

-(void)forwardFeedFinish:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[UMComFeed class]]) {
        UMComFeed *feed = (UMComFeed *)notification.object;
        [self reloadOriginFeedAfterForwardFeed:feed];
    }
}


- (void)feedDeletedFinishAction:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[UMComFeed class]]) {
        UMComFeed *feed = (UMComFeed *)notification.object;
        [self reloadOriginFeedAfterDeletedFeed:feed];
        __weak typeof(self) weakSelf = self;
        [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UMComFeedStyle *feedStyle = weakSelf.dataArray[idx];
            
            if ([feed.feedID isEqualToString:feedStyle.feed.feedID]) {
                [weakSelf.dataArray removeObjectAtIndex:idx];
                [weakSelf reloadData];
                *stop = YES;
            }
        }];
    }
}

- (void)reloadOriginFeedAfterDeletedFeed:(UMComFeed *)feed
{
    for (UMComFeedStyle *feedStyle in self.dataArray) {
        UMComFeed *currentFeed = feedStyle.feed;
        if ([feed.feedID isEqualToString:currentFeed.origin_feed.feedID]) {
            [feedStyle resetWithFeed:currentFeed];
        }
        
        if ([currentFeed.feedID isEqualToString:feed.parent_feed_id] || [currentFeed.feedID isEqualToString:feed.origin_feed.feedID]) {
            NSInteger forwardNum = [currentFeed.forward_count integerValue];
            if (forwardNum > 0) {
                currentFeed.forward_count = @(forwardNum-1);
            }else{
                currentFeed.forward_count = @0;
            }
            [feedStyle resetWithFeed:currentFeed];
        }
    }
    [self reloadData];
}


- (void)reloadOriginFeedAfterForwardFeed:(UMComFeed *)feed
{
    for (UMComFeedStyle *feedStyle in self.dataArray) {
        UMComFeed *currentFeed = feedStyle.feed;
        if ([currentFeed.feedID isEqualToString:feed.feedID] || [currentFeed.feedID isEqualToString:feed.origin_feed.feedID]) {
            NSInteger forwardNum = [currentFeed.forward_count integerValue];
            currentFeed.forward_count = @(forwardNum+1);
            [feedStyle resetWithFeed:currentFeed];
        }
    }
    [self reloadData];
}

- (void)commentOperationFinishAction:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[UMComFeed class]]) {
        UMComFeed *changeFeed = (UMComFeed *)notification.object;
        [self reloadFeed:changeFeed];
    }
}

- (void)likeOperationFinishAction:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[UMComFeed class]]) {
        UMComFeed *changeFeed = (UMComFeed *)notification.object;
        [self reloadFeed:changeFeed];
    }
}

- (void)collectionOperationFinish:(NSNotification *)notification
{
    UMComFeed *feed = notification.object;
    if ([self.fetchRequest isKindOfClass:[UMComUserFavouritesRequest class]]) {
        if ([feed isKindOfClass:[UMComFeed class]]) {
            if ([feed.has_collected boolValue]) {
                UMComFeedStyle *feedStyle = [UMComFeedStyle feedStyleWithFeed:feed viewWidth:self.frame.size.width feedType:feedCellType];
                [self.dataArray insertObject:feedStyle atIndex:0];
            }else{
                [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    UMComFeedStyle *feedStyle = obj;
                    if ([feed.feedID isEqualToString:feedStyle.feed.feedID] && [feed.has_collected boolValue] == YES) {
                        [self.dataArray removeObject:obj];
                        *stop = YES;
                    }
                }];
            }
        }
        [self reloadData];
    }
}


- (void)reloadFeed:(UMComFeed *)feed
{
    [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UMComFeedStyle *feedStyle = self.dataArray[idx];
        if ([feed.feedID isEqualToString:feedStyle.feed.feedID]) {
            [feedStyle resetWithFeed:feed];
            [self reloadRowAtIndex:[NSIndexPath indexPathForRow:idx inSection:0]];
            *stop = YES;
        }
    }];
}


- (void)reloadRowAtIndex:(NSIndexPath *)indexPath
{
    if ([self cellForRowAtIndexPath:indexPath]) {
        [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
