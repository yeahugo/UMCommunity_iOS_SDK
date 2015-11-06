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
#import "UMComFeed.h"

@interface UMComFeedTableView()<UMComRefreshViewDelegate>

@end

#define kFetchLimit 20

@implementation UMComFeedTableView

- (void)initTableView
{
    [self registerNib:[UINib nibWithNibName:@"UMComFeedsTableViewCell" bundle:nil] forCellReuseIdentifier:@"FeedsTableViewCell"];
    self.noDataTipLabel.text = UMComLocalizedString(@"no_feeds", @"暂时没有消息咯");
    if ([[[UIDevice currentDevice] systemVersion]floatValue] >= 7.0) {
        self.bottomLine.hidden = NO;
    }
    self.feedType = feedDefaultType;
    self.rowHeight = 150;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFeedData) name:kUMComFeedDeletedFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFeedData) name:kUMComCommentOperationFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFeedData) name:kUMComLikeOperationFinishNotification object:nil];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.feedStyleList = nil;
    self.scrollViewDidScroll = nil;
    self.clickActionDelegate = nil;
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
    if (self.feedStyleList.count > 0 && [[[UIDevice currentDevice] systemVersion]floatValue] >= 7.0) {
        self.bottomLine.hidden = NO;
    } else if (self.feedStyleList.count == 0) {
        self.bottomLine.hidden = YES;
    }
    return self.feedStyleList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"FeedsTableViewCell";
    UMComFeedsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self.clickActionDelegate;
    if (indexPath.row < self.feedStyleList.count) {
        [cell reloadFeedWithfeedStyle:[self.feedStyleList objectAtIndex:indexPath.row] tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    return cell;
}


#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
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


#pragma mark - handdle feeds data

- (void)handleCoreDataDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if ([data isKindOfClass:[NSArray class]] &&  data.count > 0) {
        [self.dataArray removeAllObjects];
        NSMutableArray *nomalArray = [NSMutableArray array];
        for (UMComFeed *feed in data) {
            if ([feed.is_top boolValue] == YES) {
                [self.dataArray addObject:feed];
            }else{
                [nomalArray addObject:feed];
            }
        }
        [self.dataArray addObjectsFromArray:nomalArray];
        
        NSArray *feedStyleArray = [self transFormToFeedStylesWithFeedDatas:self.dataArray];
        self.feedStyleList = feedStyleArray;
    }
    if (finishHandler) {
        finishHandler();
    }
}

- (void)handleServerDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        [self.dataArray removeAllObjects];
        if (data.count > 0) {
            [self.dataArray addObjectsFromArray:data];
        }
        NSArray *feedStyleArray = [self transFormToFeedStylesWithFeedDatas:self.dataArray];
        self.feedStyleList = feedStyleArray;
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
            [self.dataArray addObjectsFromArray:data];
            NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.feedStyleList];
            NSArray *feedStyleArray = [self transFormToFeedStylesWithFeedDatas:data];
            if (feedStyleArray.count > 0) {
                [tempArray addObjectsFromArray:feedStyleArray];
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
            UMComFeedStyle *feedStyle = [UMComFeedStyle feedStyleWithFeed:feed viewWidth:self.frame.size.width feedType:self.feedType];
            if (feedStyle) {
                [feedStyles addObject:feedStyle];
            }
        }
    }
    return feedStyles;
}

#pragma mark - Feed Operation Finish
//
//-(void)forwardFeedFinish:(NSNotification *)notification
//{
//    [self reloadFeedData];
////    if ([notification.object isKindOfClass:[UMComFeed class]]) {
////        UMComFeed *feed = (UMComFeed *)notification.object;
////        [self reloadOriginFeedAfterForwardFeed:feed];
////    }
//}
//
//
//- (void)feedDeletedFinishAction:(NSNotification *)notification
//{
//    [self reloadFeedData];
//    
////    if ([notification.object isKindOfClass:[UMComFeed class]]) {
////        UMComFeed *feed = (UMComFeed *)notification.object;
////        [self reloadOriginFeedAfterDeletedFeed:feed];
////        __weak typeof(self) weakSelf = self;
////        [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
////            UMComFeedStyle *feedStyle = weakSelf.dataArray[idx];
////            
////            if ([feed.feedID isEqualToString:feedStyle.feed.feedID]) {
////                [weakSelf.dataArray removeObjectAtIndex:idx];
////                if ([weakSelf.fetchRequest isKindOfClass:[UMComUserFavouritesRequest class]]) {
////                    feedStyle = [UMComFeedStyle feedStyleWithFeed:feed viewWidth:weakSelf.frame.size.width feedType:weakSelf.feedType];
////                    [weakSelf.dataArray insertObject:feedStyle atIndex:idx];
////                }
////                *stop = YES;
////                [weakSelf reloadData];
////            }
////        }];
////    }
//}
//
//- (void)reloadOriginFeedAfterDeletedFeed:(UMComFeed *)feed
//{
//    [self reloadFeedData];
////    for (UMComFeedStyle *feedStyle in self.dataArray) {
////        [feedStyle resetWithFeed:feedStyle.feed];
////    }
////    [self reloadData];
//}
//
//
//- (void)reloadOriginFeedAfterForwardFeed:(UMComFeed *)feed
//{
//    [self reloadFeedData];
////    for (UMComFeedStyle *feedStyle in self.dataArray) {
////        UMComFeed *currentFeed = feedStyle.feed;
////        if ([currentFeed.feedID isEqualToString:feed.feedID] || [currentFeed.feedID isEqualToString:feed.origin_feed.feedID]) {
////            [feedStyle resetWithFeed:currentFeed];
////        }
////    }
////    [self reloadData];
//}
//
//- (void)commentOperationFinishAction:(NSNotification *)notification
//{
//    [self reloadFeedData];
////    if ([notification.object isKindOfClass:[UMComFeed class]]) {
////        UMComFeed *changeFeed = (UMComFeed *)notification.object;
////        [self reloadFeed:changeFeed];
////    }
//}
//
//- (void)likeOperationFinishAction:(NSNotification *)notification
//{
//    [self reloadFeedData];
////    if ([notification.object isKindOfClass:[UMComFeed class]]) {
////        UMComFeed *changeFeed = (UMComFeed *)notification.object;
////        [self reloadFeed:changeFeed];
////    }
//}
//
//
//- (void)reloadFeed:(UMComFeed *)feed
//{
//    [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        UMComFeedStyle *feedStyle = self.dataArray[idx];
//        if ([feed.feedID isEqualToString:feedStyle.feed.feedID]) {
//            [feedStyle resetWithFeed:feed];
//            [self reloadRowAtIndex:[NSIndexPath indexPathForRow:idx inSection:0]];
//            *stop = YES;
//        }
//    }];
//}
//

- (void)reloadRowAtIndex:(NSIndexPath *)indexPath
{
    if ([self cellForRowAtIndexPath:indexPath]) {
        [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}


- (void)insertFeedStyleToDataArrayWithFeed:(UMComFeed *)newFeed
{
    __weak typeof(self) weakSlef = self;
    if ([newFeed isKindOfClass:[UMComFeed class]]) {
        __block NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataArray];
        [tempArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UMComFeed *feed = (UMComFeed *)obj;
            if ([feed.is_top boolValue] == NO) {
                [self.dataArray insertObject:newFeed atIndex:idx];
                *stop = YES;
                [weakSlef reloadFeedData];
            }
        }];
    }
}

- (void)reloadFeedData
{
    self.feedStyleList = [self transFormToFeedStylesWithFeedDatas:self.dataArray];
    [self reloadData];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
