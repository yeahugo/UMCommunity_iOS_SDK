//
//  UMComTableView.m
//  UMCommunity
//
//  Created by umeng on 15/8/5.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComTableView.h"
#import "UMComTools.h"
#import "UMComRefreshView.h"
#import "UMComScrollViewDelegate.h"
#import "UMComPullRequest.h"

@interface UMComTableView ()<UITableViewDataSource, UITableViewDelegate, UMComRefreshViewDelegate,UMComTableViewHandleDataDelegate>

@property (nonatomic, assign) CGPoint lastPosition;

@end

@implementation UMComTableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initDataWithFrame:frame]; 
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self initDataWithFrame:frame];
    }
    return self;
}

- (void)initDataWithFrame:(CGRect)frame
{
    self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.separatorColor = TableViewSeparatorRGBColor;
    self.delegate = self;
    self.dataSource = self;
    self.scrollsToTop = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
    UIView *lineSpace = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
    lineSpace.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lineSpace.backgroundColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.8 alpha:1];
    self.bottomLine = lineSpace;
    
    UMComRefreshView * refreshView = [[UMComRefreshView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, kUMComRefreshOffsetHeight) ScrollView:self];
    self.refreshController = refreshView;
    self.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, kUMComRefreshOffsetHeight)];
    self.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, kUMComLoadMoreOffsetHeight)];
    _indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    _indicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:self.indicatorView];
    self.dataArray = [NSMutableArray array];
    [self creatNoFeedTip];
    self.handleDataDelegate = self;
}

- (void)setTableHeaderView:(UIView *)tableHeaderView
{
    [super setTableHeaderView:tableHeaderView];
    if (self.refreshController.headView.superview != self.tableHeaderView) {
        [self.refreshController.headView removeFromSuperview];
        [self.tableHeaderView addSubview:self.refreshController.headView];
    }
    self.refreshController.startLocation = self.frame.origin.y;
    self.refreshController.headView.frame = CGRectMake(self.refreshController.headView.frame.origin.x, self.tableHeaderView.frame.size.height - self.refreshController.headView.frame.size.height, self.frame.size.width, self.refreshController.headView.frame.size.height);
    self.indicatorView.center = CGPointMake(self.frame.size.width/2, self.tableHeaderView.frame.size.height + (self.frame.size.height - self.tableHeaderView.frame.size.height)/2);
    self.noDataTipLabel.center = self.indicatorView.center;
}

- (void)setTableFooterView:(UIView *)tableFooterView
{
    [super setTableFooterView:tableFooterView];
    if (self.refreshController.footView.superview != self.tableFooterView) {
        [self.refreshController.footView removeFromSuperview];
        [self.tableFooterView addSubview:self.refreshController.footView];
    }
    if (self.bottomLine) {
        [self.bottomLine removeFromSuperview];
    }
    [self.tableFooterView addSubview:self.bottomLine];
    if ([[[UIDevice currentDevice] systemVersion]floatValue] >= 8.0 || [[[UIDevice currentDevice] systemVersion]floatValue] < 7.0) {
        self.bottomLine.hidden = YES;
    }
    self.refreshController.startLocation = self.frame.origin.y;
    self.refreshController.footView.frame = CGRectMake(self.refreshController.footView.frame.origin.x, 0, self.frame.size.width, self.refreshController.footView.frame.size.height);
}

- (void)creatNoFeedTip
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height/2-20, self.frame.size.width,40)];
    label.backgroundColor = [UIColor clearColor];
    label.text = UMComLocalizedString(@"No_Data", @"暂时没有数据咯");
    label.font = UMComFontNotoSansLightWithSafeSize(17);
    label.textColor = [UMComTools colorWithHexString:FontColorGray];
    label.textAlignment = NSTextAlignmentCenter;
    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    label.hidden = YES;
    [self addSubview:label];
    self.noDataTipLabel = label;
}

#pragma mark - delegate methed

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.refreshController refreshScrollViewDidScroll:scrollView haveNextPage:self.haveNextPage];
    if (self.scrollViewDelegate && [self.scrollViewDelegate respondsToSelector:@selector(customScrollViewDidScroll:lastPosition:)]) {
        [self.indicatorView stopAnimating];
        [self.scrollViewDelegate customScrollViewDidScroll:scrollView lastPosition:self.lastPosition];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.lastPosition = scrollView.contentOffset;
    if (self.scrollViewDelegate && [self.scrollViewDelegate respondsToSelector:@selector(customScrollViewDidEnd:lastPosition:)]) {
        [self.scrollViewDelegate customScrollViewDidEnd:scrollView lastPosition:self.lastPosition];
    }
    self.lastPosition = scrollView.contentOffset;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.refreshController refreshScrollViewDidEndDragging:scrollView haveNextPage:self.haveNextPage];
    if (self.scrollViewDelegate && [self.scrollViewDelegate respondsToSelector:@selector(customScrollViewEndDrag:lastPosition:)]) {
        [self.scrollViewDelegate customScrollViewEndDrag:scrollView lastPosition:self.lastPosition];
    }
    self.lastPosition = scrollView.contentOffset;
}


#pragma mark - UMComRefreshTableViewDelegate

- (void)refreshData:(UMComRefreshView *)refreshView loadingFinishHandler:(RefreshDataLoadFinishHandler)handler
{
    if (self.fetchRequest == nil) {
        if (handler) {
            handler(nil);
        }
        return;
    }
    [self refreshNewDataFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        if (handler) {
            handler(error);
        }
    }];
}

- (void)loadMoreData:(UMComRefreshView *)refreshView loadingFinishHandler:(RefreshDataLoadFinishHandler)handler
{
    if (self.fetchRequest == nil) {
        if (handler) {
            handler(nil);
        }
        return;
    }
    [self loadNextPageDataFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        if (handler) {
            handler(error);
        }
    }];
}



#pragma mark - Data Request
- (void)loadAllData:(LoadCoreDataCompletionHandler)coreDataHandler fromServer:(LoadSeverDataCompletionHandler)complection
{
    __weak typeof(self) weakSelf = self;
    [self.indicatorView startAnimating];
    [self fetchDataFromCoreData:^(NSArray *data, NSError *error) {
        if (coreDataHandler) {
            coreDataHandler(data, error);
        }
        if (weakSelf.dataArray.count > 0) {
            [weakSelf.indicatorView stopAnimating];
        }
        [weakSelf refreshNewDataFromServer:complection];
    }];
}

- (void)fetchDataFromCoreData:(LoadCoreDataCompletionHandler)coreDataHandler
{
    if (!self.fetchRequest) {
        [self.indicatorView stopAnimating];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.fetchRequest fetchRequestFromCoreData:^(NSArray *data, NSError *error) {
        if (coreDataHandler) {
            coreDataHandler(data,error);
        }
        if (weakSelf.handleDataDelegate && [weakSelf.handleDataDelegate respondsToSelector:@selector(handleCoreDataDataWithData:error:dataHandleFinish:)]) {
            [weakSelf.handleDataDelegate handleCoreDataDataWithData:data error:error dataHandleFinish:^{
                if (data.count > 0) {
                    [weakSelf.indicatorView stopAnimating];
                }
                [weakSelf reloadData];
            }];
        }
    }];
}

- (void)refreshNewDataFromServer:(LoadSeverDataCompletionHandler)complection
{
    if (!self.fetchRequest) {
        [self.indicatorView stopAnimating];
        return;
    }
    if (self.dataArray.count == 0) {
        [self.indicatorView startAnimating];
    }else{
        [self.indicatorView stopAnimating];
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    __weak typeof(self) weakSelf = self;
    [self.fetchRequest fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        weakSelf.haveNextPage = haveNextPage;
        if (complection) {
            complection(data, haveNextPage, error);
        }
        if (weakSelf.loadSeverDataCompletionHandler) {
            weakSelf.loadSeverDataCompletionHandler(data, haveNextPage, error);
        }
        if ((weakSelf.dataArray.count == 0 && data.count == 0) || haveNextPage == NO) {
            weakSelf.refreshController.footView.hidden = YES;
        }else{
            weakSelf.refreshController.footView.hidden = NO;
        }
        [weakSelf.handleDataDelegate handleServerDataWithData:data error:error dataHandleFinish:^{
            [weakSelf.indicatorView stopAnimating];
            [weakSelf reloadData];
            if (!error) {
                if (data.count > 0) {
                    weakSelf.noDataTipLabel.hidden = YES;
                }else{
                    weakSelf.noDataTipLabel.hidden = NO;
                }
            }else{
                weakSelf.noDataTipLabel.hidden = YES;
            }
            if (!weakSelf.contentSize.height < weakSelf.frame.size.height) {
                [weakSelf.refreshController.footView hidenVews];
            }
        }];
    }];
}

- (void)loadNextPageDataFromServer:(LoadSeverDataCompletionHandler)complection
{
    if (!self.fetchRequest) {
        [self.indicatorView stopAnimating];
        return;
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    __weak typeof(self) weakSelf = self;
    [self.fetchRequest fetchNextPageFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        weakSelf.haveNextPage = haveNextPage;
        if (complection) {
            complection(data, haveNextPage, error);
        }
        [self.handleDataDelegate handleLoadMoreDataWithData:data error:error dataHandleFinish:^{
            [weakSelf reloadData];
        }];
    }];
}

#pragma mark - handleData
- (void)handleCoreDataDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if ([data isKindOfClass:[NSArray class]] &&  data.count > 0) {
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:data];
    }
    if (finishHandler) {
        finishHandler();
    }
}

- (void)handleServerDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:data];;
    }
    if (finishHandler) {
        finishHandler();
    }
}

- (void)handleLoadMoreDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isMemberOfClass:[NSArray class]]) {
        if ([data isKindOfClass:[NSArray class]]) {
            [self.dataArray addObjectsFromArray:data];
        }
    }
    if (finishHandler) {
        finishHandler();
    }
}

@end
