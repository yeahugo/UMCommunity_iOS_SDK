//
//  UMComTopicsTableView.m
//  UMCommunity
//
//  Created by umeng on 15/7/28.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComTopicsTableView.h"
#import "UMComTools.h"
#import "UMComFilterTopicsViewCell.h"
#import "UMComPullRequest.h"
#import "UMComShowToast.h"
#import "UMComRefreshView.h"
#import "UMComClickActionDelegate.h"
#import "UMComScrollViewDelegate.h"

@interface UMComTopicsTableView () <UITableViewDelegate, UITableViewDataSource, UMComRefreshViewDelegate>


@property (nonatomic, strong) UILabel *noTopicsTip;

@property (nonatomic, assign) BOOL loadFinish;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, assign) CGPoint lastPosition;

@property (nonatomic, assign) BOOL haveNextPage;

@end

@implementation UMComTopicsTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.rowHeight = 62;
        self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.separatorColor = TableViewSeparatorRGBColor;
        if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
            [self setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([self respondsToSelector:@selector(setLayoutMargins:)])
        {
            [self setLayoutMargins:UIEdgeInsetsZero];
        }
        
        _indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        _indicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:self.indicatorView];
        
        [self registerNib:[UINib nibWithNibName:@"UMComFilterTopicsViewCell" bundle:nil] forCellReuseIdentifier:@"FilterTopicsViewCell"];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height/2-80, self.frame.size.width, 40)];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = UMComFontNotoSansLightWithSafeSize(17);
        [self addSubview:label];
        label.hidden = YES;
        self.noTopicsTip = label;
        if (self.topicFecthRequest) {
            [self fecthTopicsData];
        }
    }
    return self;
}

- (void)setHeadView:(UMComRefreshView *)headView
{
    _headView = headView;
    _headView.refreshDelegate = self;
    headView.startLocation = self.frame.origin.y;
    self.tableHeaderView = headView;
}

- (void)setFootView:(UMComRefreshView *)footView
{
    _footView = footView;
    _footView.refreshDelegate = self;
    footView.lineSpace.hidden = YES;
    footView.startLocation = self.frame.origin.y;
    self.tableFooterView = footView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.topicsArray.count > 0) {
        [self.indicatorView stopAnimating];
    }
    return self.topicsArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"FilterTopicsViewCell";
    UMComFilterTopicsViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell == nil) {
        cell = [[UMComFilterTopicsViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.delegate = self.clickActionDelegate;
    UMComTopic *topic = [self.topicsArray objectAtIndex:indexPath.row];
    [cell setWithTopic:topic];
    __weak typeof(self) weakSelf = self;
    __weak typeof(UMComFilterTopicsViewCell) *weakCell = cell;
    cell.clickOnTopic = ^(UMComTopic *topic){
        if (weakSelf.clickActionDelegate  && [self.clickActionDelegate respondsToSelector:@selector(customObj:clickOnTopic:)]) {
            __strong typeof(weakCell) strongCell = weakCell;
            [self.clickActionDelegate customObj:strongCell clickOnTopic:topic];
        }
    };
    return cell;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.scrollViewDelegate && [self.scrollViewDelegate respondsToSelector:@selector(customScrollViewDidScroll:lastPosition:)]) {
        [self.scrollViewDelegate customScrollViewDidScroll:scrollView lastPosition:self.lastPosition];
    }
    if (self.loadFinish == YES) {
        if (scrollView.contentOffset.y < 0) {
            [self.headView refreshScrollViewDidScroll:scrollView];
        }else if (self.haveNextPage == YES){
            [self.footView refreshScrollViewDidScroll:scrollView];
        }
    }
    self.lastPosition = scrollView.contentOffset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.scrollViewDelegate && [self.scrollViewDelegate respondsToSelector:@selector(customScrollViewDidEnd:lastPosition:)]) {
        [self.scrollViewDelegate customScrollViewDidEnd:scrollView lastPosition:self.lastPosition];
    }
    if (_loadFinish == YES) {
        [self.indicatorView stopAnimating];
    }
    self.lastPosition = scrollView.contentOffset;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y < 0 && self.loadFinish == YES) {
        [self.headView refreshScrollViewDidEndDragging:scrollView];
    }else if (self.loadFinish && _haveNextPage == YES && scrollView.contentOffset.y > 0){

        [self.footView refreshScrollViewDidEndDragging:scrollView];
    }else if (self.loadFinish == YES){
        [self.indicatorView stopAnimating];
    }
}


- (void)refreshData:(UMComRefreshView *)refreshView loadingFinishHandler:(RefreshDataLoadFinishHandler)handler
{
    [self refreshTopicsData:^(NSArray *data, NSError *error) {
        if (handler) {
            handler(error);
        }
    }];
}

- (void)loadMoreData:(UMComRefreshView *)refreshView loadingFinishHandler:(RefreshDataLoadFinishHandler)handler
{
    [self fecthNextPageData:^(NSArray *data, NSError *error) {
        if (handler) {
            handler(error);
        }
    }];
}

#pragma requestDataMethod
- (void)fecthTopicsData
{
    if (!self.topicFecthRequest) {
          [self.indicatorView stopAnimating];
        return;
    }
    self.noTopicsTip.hidden = YES;
    [self.indicatorView startAnimating];
    __weak typeof(self) weakSelf = self;
    [self.topicFecthRequest fetchRequestFromCoreData:^(NSArray *data, NSError *error) {
        if (!error) {
            if (data.count > 0) {
                [weakSelf.indicatorView stopAnimating];
            }
            weakSelf.topicsArray = data;
            [weakSelf reloadData];
        }
        [weakSelf refreshTopicsData:nil];
    }];
}

- (void)refreshTopicsData:(void (^)(NSArray *data,NSError *error))block
{
    if (!self.topicFecthRequest) {
        [self.indicatorView stopAnimating];
        return;
    }
    if (self.topicsArray.count > 0) {
        [self.indicatorView stopAnimating];
    }
    __weak typeof(self) weakSelf = self;
    self.loadFinish = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.topicFecthRequest fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        _haveNextPage = haveNextPage;
        weakSelf.loadFinish = YES;
        [weakSelf.indicatorView stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (block) {
            block(data, error);
        }
        if (data.count > 0) {
            weakSelf.topicsArray = data;
        }
        [weakSelf showNoTopicTipWithArr:weakSelf.topicsArray error:error notice:UMComLocalizedString(@"no topics",@"暂无相关话题")];
        
        [weakSelf reloadData];
    }];
}


- (void)fecthNextPageData:(void (^)(NSArray *data,NSError *error))block
{
    self.loadFinish = NO;
    [self.topicFecthRequest fetchNextPageFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        _haveNextPage = haveNextPage;
        self.loadFinish = YES;
        if (block) {
            block(data, error);
        }
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.topicsArray];
        if (!error && [data isKindOfClass:[NSArray class]]) {
           [tempArray addObjectsFromArray:data];
        }
        self.topicsArray = tempArray;
        [self reloadData];
    }];
}


- (void)showNoTopicTipWithArr:(NSArray *)topicArr error:(NSError *)error notice:(NSString *)noticeMassege
{
    if (topicArr.count > 0) {
        self.noTopicsTip.hidden = YES;
    }else{
        if (error) {
            self.noTopicsTip.hidden = YES;
        }else{
            self.noTopicsTip.hidden = NO;
            self.noTopicsTip.text = noticeMassege;
        }
        [UMComShowToast fetchTopcsFail:error];
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
