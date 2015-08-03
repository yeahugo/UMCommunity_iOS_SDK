//
//  UMComFeedsTableView.m
//  UMCommunity
//
//  Created by Gavin Ye on 12/5/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComFeedsTableView.h"
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

@interface UMComFeedsTableView()<UMComRefreshViewDelegate>
{
    BOOL _loadingMore;
    BOOL _haveNextPage;
}
@property (nonatomic, strong) UILabel *noFeedTip;

@property (nonatomic, assign) CGPoint lastPosition;

@property (nonatomic, assign) CGFloat originY;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;


@end

#define kFetchLimit 20

@implementation UMComFeedsTableView

//static int HeaderOffSet = -90;//-120

- (void)initTableView
{
    [self registerNib:[UINib nibWithNibName:@"UMComFeedsTableViewCell" bundle:nil] forCellReuseIdentifier:@"FeedsTableViewCell"];
    self.delegate = self;
    self.dataSource = self;
    self.resultArray = [NSMutableArray arrayWithCapacity:1];
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
     self.indicatorView.frame = CGRectMake(self.frame.size.width/2-20, self.frame.size.height/2-20, 40, 40);
    [self addSubview:self.indicatorView];
    
    self.scrollsToTop = YES;
    self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self creatNoFeedTip];
    _haveNextPage = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forwardFeedFinish:) name:kNotificationPostFeedResult object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedDeletedFinishAction:) name:FeedDeletedFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentOperationFinishAction:) name:CommentOperationFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeOperationFinishAction:) name:LikeOperationFinish object:nil];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.resultArray = nil;
}

- (void)creatNoFeedTip
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height/2-20, self.frame.size.width,40)];
    label.backgroundColor = [UIColor clearColor];
    label.text = UMComLocalizedString(@"no_feeds", @"暂时没有消息咯");
    label.font = UMComFontNotoSansLightWithSafeSize(17);
    label.textColor = [UMComTools colorWithHexString:FontColorGray];
    label.textAlignment = NSTextAlignmentCenter;
    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.noFeedTip = label;
    self.noFeedTip.hidden = YES;
    [self addSubview:label];
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
        self.originY = frame.origin.y;
    }
    return self;
}

-(void)awakeFromNib
{
    [self initTableView];
    [super awakeFromNib];
}


- (void)setHeadView:(UMComRefreshView *)headView
{
    _headView = headView;
    headView.refreshDelegate = self;
    headView.startLocation = self.frame.origin.y;
    self.tableHeaderView = headView;
}

- (void)setFootView:(UMComRefreshView *)footView
{
    _footView = footView;
    footView.refreshDelegate = self;
    footView.startLocation = self.frame.origin.y;
    self.tableFooterView = footView;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"FeedsTableViewCell";
    UMComFeedsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self.clickActionDelegate;
    if (indexPath.row < self.resultArray.count) {
        [cell reloadFeedWithfeedStyle:[self.resultArray objectAtIndex:indexPath.row] tableView:tableView cellForRowAtIndexPath:indexPath];
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
    if (indexPath.row < self.resultArray.count) {
        UMComFeedStyle *feedStyle = self.resultArray[indexPath.row];
        cellHeight = feedStyle.totalHeight;
    }
    return cellHeight;
}


#pragma mark - UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (_loadingMore == NO) {
        if (scrollView.contentOffset.y < 0) {
            [self.headView refreshScrollViewDidScroll:scrollView];
        }else if (_haveNextPage == YES){
            [self.footView refreshScrollViewDidScroll:scrollView];
        }
    }
    if (self.scrollViewDelegate && [self.scrollViewDelegate respondsToSelector:@selector(customScrollViewDidScroll:lastPosition:)]) {
        [self.scrollViewDelegate customScrollViewDidScroll:scrollView lastPosition:self.lastPosition];
    }
    self.lastPosition = scrollView.contentOffset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.scrollViewDelegate && [self.scrollViewDelegate respondsToSelector:@selector(customScrollViewDidEnd:lastPosition:)]) {
        [self.scrollViewDelegate customScrollViewDidEnd:scrollView lastPosition:self.lastPosition];
    }
    if (_loadingMore == NO) {
        [self.indicatorView stopAnimating];
    }
    self.lastPosition = scrollView.contentOffset;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    float offset = scrollView.contentOffset.y;
    if (_loadingMore == NO) {
        //下拉刷新
        if (offset < 0) {
            [self.headView refreshScrollViewDidEndDragging:scrollView];
        }
        //上拉加载更多
        else if (_haveNextPage == YES && offset > 0) {
            [self.footView refreshScrollViewDidEndDragging:scrollView];
        }else{
            [self.indicatorView stopAnimating];
        }
    }
}

- (void)refreshData:(UMComRefreshView *)refreshView loadingFinishHandler:(RefreshDataLoadFinishHandler)handler
{
    [self fetchFeedsFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        if (handler) {
            handler(error);
        }
    }];
}

- (void)loadMoreData:(UMComRefreshView *)refreshView loadingFinishHandler:(RefreshDataLoadFinishHandler)handler
{
    [self fetchFeedsFromForNextPage:^(NSError *error) {
        if (handler) {
            handler(error);
        }
    }];
}


#pragma mark - handdle feeds data 

- (void)refreshAllFeedsData:(LoadCoreDataCompletionHandler)coreDataHandler fromServer:(LoadSeverDataCompletionHandler)serverDataHandler
{
    self.indicatorView.center = CGPointMake(self.indicatorView.center.x, self.tableHeaderView.frame.size.height+(self.frame.size.height-self.tableHeaderView.frame.size.height)/2);
    [self.indicatorView startAnimating];
    if (self.fetchFeedsController == nil) {
        [self.indicatorView stopAnimating];
        _loadingMore = NO;
        return;
    }
    self.fetchFeedsController.fetchRequest.fetchLimit = 46;
    [self fetchFeedsFromCoreData:^(NSArray *data, NSError *error) {
        if (coreDataHandler) {
            coreDataHandler(data, error);
        }
        self.indicatorView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self fetchFeedsFromServer:serverDataHandler];
    }];
}

- (void)fetchFeedsFromCoreData:(LoadCoreDataCompletionHandler)coreDataHandler
{
    if (self.fetchFeedsController == nil) {
        [self.indicatorView stopAnimating];
        return;
    }
    __weak typeof(self) weakSelf = self;
    _loadingMore = YES;
    [self.fetchFeedsController fetchRequestFromCoreData:^(NSArray *coreData, NSError *error) {
        if (coreDataHandler) {
            coreDataHandler(coreData,error);
        }
        if (!error && coreData.count > 0) {
            NSArray *feedStyleArray = [self transformFeedDatasToFeedStylesData:coreData];
            [weakSelf.resultArray addObjectsFromArray:feedStyleArray];
        }else {
            weakSelf.noFeedTip.hidden = NO;
        }
        if (coreData.count > 0) {
            [self.indicatorView stopAnimating];
        }
        [self reloadData];
    }];
}

- (void)fetchFeedsFromServer:(LoadSeverDataCompletionHandler)serverDataHandler
{
    if (!self.fetchFeedsController) {
        [self.indicatorView stopAnimating];
        return;
    }else if (self.resultArray.count > 0){
        [self.indicatorView stopAnimating];
    }
    __weak typeof(self) weakSelf = self;
    _loadingMore = YES;
    self.fetchFeedsController.fetchRequest.fetchLimit = BatchSize;
    if (self.resultArray.count ==0 && !self.indicatorView.isAnimating) {
        [self.indicatorView startAnimating];
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.fetchFeedsController fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
         [self.indicatorView stopAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (serverDataHandler) {
            serverDataHandler(data,haveNextPage,error);
        }
        if (self.loadSeverDataCompletionHandler) {
            self.loadSeverDataCompletionHandler(data, haveNextPage, error);
        }
        _loadingMore = NO;
        _haveNextPage = haveNextPage;
        [weakSelf handleRefreshResult:data error:error];
    }];
}

- (void)fetchFeedsFromForNextPage:(void (^)(NSError *error))block
{
    if (self.fetchFeedsController == nil) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    _loadingMore = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.fetchFeedsController fetchNextPageFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        [weakSelf.indicatorView stopAnimating];
        if (block) {
            block(error);
        }
        _loadingMore = NO;
        _haveNextPage = haveNextPage;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        weakSelf.noFeedTip.hidden = YES;
        [weakSelf handleLoadMoreResult:data error:error];
    }];
}

- (void)handleRefreshResult:(NSArray *)data error:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.noFeedTip.hidden = YES;
        if (!error) {
            [self.resultArray removeAllObjects];
            if (data.count > 0) {
                NSArray *feedStyleArray = [self transformFeedDatasToFeedStylesData:data];
                [self.resultArray addObjectsFromArray:feedStyleArray];
            }else {
                self.noFeedTip.hidden = NO;
            }
        } else {
            [UMComShowToast fetchFeedFail:error];
        }
        [self reloadData];
}

- (void)handleLoadMoreResult:(NSArray *)data error:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (!error) {
        if (data.count > 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.resultArray addObjectsFromArray:[self transformFeedDatasToFeedStylesData:data]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self reloadData];
                });
            });
        }else {
            [UMComShowToast showNoMore];
        }
    } else {
        [UMComShowToast fetchMoreFeedFail:error];
    }
}


- (NSArray *)transformFeedDatasToFeedStylesData:(NSArray *)dataArr
{
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:1];
     NSMutableArray *topItems = [NSMutableArray arrayWithCapacity:1];
    for (UMComFeed *feed in dataArr) {
        UMComFeedStyle *feedStyle = [UMComFeedStyle feedStyleWithFeed:feed viewWidth:self.frame.size.width feedType:feedCellType];
        if ([feed.is_top boolValue]) {
            [topItems addObject:feedStyle];
        }else{
            [tempArr addObject:feedStyle];
        }
    }
    [topItems addObjectsFromArray:tempArr];
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
        [self.resultArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UMComFeedStyle *feedStyle = weakSelf.resultArray[idx];
            
            if ([feed.feedID isEqualToString:feedStyle.feed.feedID]) {
                [weakSelf.resultArray removeObjectAtIndex:idx];
                [weakSelf reloadData];
                *stop = YES;
            }
        }];
    }
}

- (void)reloadOriginFeedAfterDeletedFeed:(UMComFeed *)feed
{
    for (UMComFeedStyle *feedStyle in self.resultArray) {
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
    for (UMComFeedStyle *feedStyle in self.resultArray) {
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

- (void)reloadFeed:(UMComFeed *)feed
{
    [self.resultArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UMComFeedStyle *feedStyle = self.resultArray[idx];
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
