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

@interface UMComFeedsTableView()
{
    BOOL _loadingMore;
    BOOL _haveNextPage;
}
@property (nonatomic, assign) CGFloat lastPosition;

@property (nonatomic, strong) UILabel *noFeedTip;

@end

#define kFetchLimit 20

@implementation UMComFeedsTableView

static int HeaderOffSet = -90;//-120

- (void)initTableView
{
    [self registerNib:[UINib nibWithNibName:@"UMComFeedsTableViewCell" bundle:nil] forCellReuseIdentifier:@"FeedsTableViewCell"];
    self.delegate = self;
    self.dataSource = self;
    self.resultArray = [NSMutableArray arrayWithCapacity:1];
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    self.indicatorView.center = CGPointMake(self.frame.size.width/2, -20);
    [self addSubview:self.indicatorView];
    self.scrollsToTop = YES;
    self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, BottomLineHeight)];
    self.footView.backgroundColor = [UIColor clearColor];
    self.tableFooterView = self.footView;
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self creatNoFeedTip];
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
    }
    return self;
}

-(void)awakeFromNib
{
    [self initTableView];
    [super awakeFromNib];
}


- (void)addFootView{

    self.footerIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.footerIndicatorView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height+60);
    //暂时隐藏
    self.footerIndicatorView.hidden = YES;
    [self addSubview:self.footerIndicatorView];
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


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float offset = scrollView.contentOffset.y;
    if (offset < HeaderOffSet) {
        [self.indicatorView startAnimating];
    }
    else if (self.resultArray.count >= kFetchLimit && offset + self.superview.frame.size.height > self.contentSize.height){
        [self.footerIndicatorView startAnimating];
    }
    if (self.scrollViewDidScroll) {
        self.scrollViewDidScroll(scrollView, self.lastPosition);
    }
    self.lastPosition = scrollView.contentOffset.y;

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.scrollViewDidScroll) {
        self.scrollViewDidScroll(scrollView, self.lastPosition);
    }
}


- (void)refreshData
{
    _loadingMore = YES;
    self.noFeedTip.hidden = YES;
    if (self.feedsTableViewDelegate && [self.feedsTableViewDelegate respondsToSelector:@selector(feedTableView:refreshData:)]) {
        __weak UMComFeedsTableView * weakSelf = self;
        [self.feedsTableViewDelegate feedTableView:self refreshData:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            [weakSelf dealWithFetchResult:data error:error loadMore:NO haveNextPage:haveNextPage];
        }];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.resultArray.count == 0) {
        self.footView.backgroundColor = [UIColor clearColor];
    }
    float offset = scrollView.contentOffset.y;
    //下拉刷新
    if (offset < HeaderOffSet && _loadingMore == NO) {
        [self.indicatorView stopAnimating];
        _loadingMore = YES;
        [self refreshData];
    }
    //上拉加载更多
    else if (_haveNextPage == YES && offset > 0 && scrollView.contentOffset.y > scrollView.contentSize.height - (scrollView.superview.frame.size.height - 65)) {
        if (self.feedsTableViewDelegate && [self.feedsTableViewDelegate respondsToSelector:@selector(feedTableView:loadMoreData:)]) {
            __weak UMComFeedsTableView *feedsTableView = self;
            [self.feedsTableViewDelegate feedTableView:self loadMoreData:^(NSArray *data, BOOL haveNextPage, NSError *error) {
                feedsTableView.noFeedTip.hidden = YES;
                if (!haveNextPage) {
                    [feedsTableView.footerIndicatorView stopAnimating];
                }
                [feedsTableView dealWithFetchResult:data error:error loadMore:YES haveNextPage:haveNextPage];
            }];
        }
    }
}


#pragma mark - dealWith data 
- (void)dealWithFetchResult:(NSArray *)data error:(NSError *)error loadMore:(BOOL)loadeMore haveNextPage:(BOOL)haveNextPage
{
    
    _loadingMore = NO;
    _haveNextPage = haveNextPage;
    if (loadeMore == YES) {
        [self dealWithLoadMoreResult:data error:error];
    }else{
        [self.resultArray removeAllObjects];
        [self dealWithRefreshResult:data error:error];
    }
}
- (void)dealWithRefreshResult:(NSArray *)data error:(NSError *)error
{
    if (self.loadDataFinishBlock) {
        self.loadDataFinishBlock(data,error);
    }
    self.noFeedTip.hidden = YES;
    if (!error) {
        if (data.count > 0) {
            NSArray *feedStyleArray = [self dealWithFeedData:data];
            [self.resultArray addObjectsFromArray:feedStyleArray];
            self.footView.backgroundColor = TableViewSeparatorRGBColor;
            [self reloadData];
        }else {
            self.noFeedTip.hidden = NO;
            self.footView.backgroundColor = [UIColor clearColor];
        }
        
    } else {
        self.footView.backgroundColor = [UIColor clearColor];
        [UMComShowToast fetchFeedFail:error];
    }
}

- (void)dealWithLoadMoreResult:(NSArray *)data error:(NSError *)error
{
    if (!error) {
        if (data.count > 0) {
            [self addTableViewData:[self dealWithFeedData:data]];
        }else {
            [UMComShowToast showNoMore];
        }
    } else {
        [UMComShowToast fetchMoreFeedFail:error];
    }
}

- (void)addTableViewData:(NSArray *)data
{
    NSInteger indexStart = self.resultArray.count;
    NSMutableArray * reloadArray = [NSMutableArray array];
    for (int i = 0; i < data.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(indexStart+i)  inSection:0];
        [reloadArray addObject:indexPath];
    }
    if (data.count> 0) {
        [self.resultArray addObjectsFromArray:data];
        [self insertRowsAtIndexPaths:reloadArray withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (NSArray *)dealWithFeedData:(NSArray *)dataArr
{
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:1];
    for (UMComFeed *feed in dataArr) {
        UMComFeedStyle *feedStyle = [UMComFeedStyle feedStyleWithFeed:feed viewWidth:self.frame.size.width feedType:feedCellType];
        [tempArr addObject:feedStyle];
    }
    return tempArr;
}




#pragma mark -

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
