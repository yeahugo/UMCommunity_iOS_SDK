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
    self.noDataTipLabel.text = UMComLocalizedString(@"no_feeds", @"暂时没有消息咯");
    if ([[[UIDevice currentDevice] systemVersion]floatValue] >= 7.0) {
        self.bottomLine.hidden = NO;
    }
    self.feedType = feedDefaultType;
    self.rowHeight = 150;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forwardFeedFinish:) name:kNotificationForwardFeedResult object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedDeletedFinishAction:) name:kUMComFeedDeletedFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentOperationFinishAction:) name:kUMComCommentOperationFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeOperationFinishAction:) name:kUMComLikeOperationFinish object:nil];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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
    if (self.dataArray.count > 0 && [[[UIDevice currentDevice] systemVersion]floatValue] >= 7.0) {
        self.bottomLine.hidden = NO;
    } else if (self.dataArray.count == 0) {
        self.bottomLine.hidden = YES;
    }
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"FeedsTableViewCell";
    UMComFeedsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self.clickActionDelegate;
    if (indexPath.row < self.dataArray.count) {
        [cell reloadFeedWithfeedStyle:[self.dataArray objectAtIndex:indexPath.row] tableView:tableView cellForRowAtIndexPath:indexPath];
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
            NSArray *feedStyleArray = [self transFormToFeedStylesWithFeedDatas:topArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.dataArray removeAllObjects];
                if (feedStyleArray.count > 0) {
                    [self.dataArray addObjectsFromArray:feedStyleArray];
                }
                if (finishHandler) {
                    finishHandler();
                }
            });
        });
        
    }else{
        if (finishHandler) {
            finishHandler();
        }
    }
    
}

- (void)handleServerDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *feedStyleArray = [self transFormToFeedStylesWithFeedDatas:data];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.dataArray removeAllObjects];
                if (feedStyleArray.count > 0) {
                    [self.dataArray addObjectsFromArray:feedStyleArray];
                }
                if (finishHandler) {
                    finishHandler();
                }
            });
        });

    }else {
        [UMComShowToast showFetchResultTipWithError:error];
        if (finishHandler) {
            finishHandler();
        }
    }
    
}

- (void)handleLoadMoreDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error) {
        if (data.count > 0) {
   
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSArray *feedStyleArray = [self transFormToFeedStylesWithFeedDatas:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (feedStyleArray.count > 0) {
                        [self.dataArray addObjectsFromArray:feedStyleArray];
                    }
                    if (finishHandler) {
                        finishHandler();
                    }
                });
            });

        }else {
            [UMComShowToast showNoMore];
        }

    } else {
        if (finishHandler) {
            finishHandler();
        }
        [UMComShowToast showFetchResultTipWithError:error];
    }
}

- (NSArray *)transFormToFeedStylesWithFeedDatas:(NSArray *)feedList
{
     NSMutableArray *feedStyles = [NSMutableArray arrayWithCapacity:1];
    for (UMComFeed *feed in feedList) {
        if (self.feedType != feedFavourateType && [feed.status integerValue]>= FeedStatusDeleted) {
            continue;
        }
        UMComFeedStyle *feedStyle = [UMComFeedStyle feedStyleWithFeed:feed viewWidth:self.frame.size.width feedType:self.feedType];
        if (feedStyle) {
            [feedStyles addObject:feedStyle];    
        }
    }
    return feedStyles;
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
                if ([weakSelf.fetchRequest isKindOfClass:[UMComUserFavouritesRequest class]]) {
                    feedStyle = [UMComFeedStyle feedStyleWithFeed:feed viewWidth:weakSelf.frame.size.width feedType:weakSelf.feedType];
                    [weakSelf.dataArray insertObject:feedStyle atIndex:idx];
                }
                *stop = YES;
                [weakSelf reloadData];
            }
        }];
    }
}

- (void)reloadOriginFeedAfterDeletedFeed:(UMComFeed *)feed
{
    for (UMComFeedStyle *feedStyle in self.dataArray) {
        [feedStyle resetWithFeed:feedStyle.feed];
    }
    [self reloadData];
}


- (void)reloadOriginFeedAfterForwardFeed:(UMComFeed *)feed
{
    for (UMComFeedStyle *feedStyle in self.dataArray) {
        UMComFeed *currentFeed = feedStyle.feed;
        if ([currentFeed.feedID isEqualToString:feed.feedID] || [currentFeed.feedID isEqualToString:feed.origin_feed.feedID]) {
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


- (void)insertFeedStyleToDataArrayWithFeed:(UMComFeed *)feed
{
    __weak typeof(self) weakSlef = self;
    if ([feed isKindOfClass:[UMComFeed class]]) {
        UMComFeedStyle *newFeedStyle = [UMComFeedStyle feedStyleWithFeed:feed viewWidth:self.frame.size.width feedType:self.feedType];
        [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UMComFeedStyle *feedStyle = (UMComFeedStyle *)obj;
            if ([feedStyle.feed.is_lististop boolValue] == NO) {
                [weakSlef.dataArray insertObject:newFeedStyle atIndex:idx];
                *stop = YES;
                [weakSlef reloadData];
            }
        }];
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
