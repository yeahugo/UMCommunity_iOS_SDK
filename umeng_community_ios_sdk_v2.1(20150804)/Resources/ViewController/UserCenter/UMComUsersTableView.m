//
//  UMComUsersTableView.m
//  UMCommunity
//
//  Created by umeng on 15/7/26.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComUsersTableView.h"
#import "UMComPullRequest.h"
#import "UMComUserTableViewCell.h"
#import "UMComAction.h"
#import "UMComShowToast.h"
#import "UMComRefreshView.h"
#import "UMComClickActionDelegate.h"
#import "UMComScrollViewDelegate.h"

@interface UMComUsersTableView ()<UITableViewDataSource, UITableViewDelegate, UMComRefreshViewDelegate>

@property (nonatomic, strong) UILabel *noUserTip;

@property (nonatomic, assign) CGPoint lastPosition;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, assign) BOOL isLoadFinish;

@end

@implementation UMComUsersTableView
{
    BOOL _haveNextPage;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self registerNib:[UINib nibWithNibName:@"UMComUserTableViewCell" bundle:nil] forCellReuseIdentifier:@"ComUserTableViewCell"];
        self.dataSource = self;
        self.delegate = self;
        self.rowHeight = 60.0f;
        _indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        _indicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:self.indicatorView];
        
        self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.separatorColor = TableViewSeparatorRGBColor;
        if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
            [self setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([self respondsToSelector:@selector(setLayoutMargins:)])
        {
            [self setLayoutMargins:UIEdgeInsetsZero];
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.userList.count > 0) {
        self.noUserTip.hidden = YES;
        [self.indicatorView stopAnimating];
    }
    return self.userList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"ComUserTableViewCell";
    UMComUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.delegate = self.clickActionDelegate;
    UMComUser *user = self.userList[indexPath.row];
    [cell displayWithUser:user];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UMComUser *user = self.userList[indexPath.row];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isLoadFinish == YES) {
        if (self.contentOffset.y < 0) {
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
    if (_isLoadFinish == YES) {
        [self.indicatorView stopAnimating];
    }
    self.lastPosition = scrollView.contentOffset;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.isLoadFinish == YES) {
        if (scrollView.contentOffset.y < 0) {
            [self.headView refreshScrollViewDidEndDragging:scrollView];
        }else if (_haveNextPage == YES && scrollView.contentOffset.y > 0){
            [self.footView refreshScrollViewDidEndDragging:scrollView];
        }
    }
}

- (void)refreshData:(UMComRefreshView *)refreshView loadingFinishHandler:(RefreshDataLoadFinishHandler)handler
{
    [self refreshDataFromServer:^(NSArray *data, NSError *error) {
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

#pragma mark - data handle

- (void)refreshAllData
{
    if (self.fetchRequest == nil) {
        [self.indicatorView stopAnimating];
        self.isLoadFinish = YES;
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.indicatorView startAnimating];
    [self.fetchRequest fetchRequestFromCoreData:^(NSArray *data, NSError *error) {
        if (data.count > 0) {
            [self.indicatorView stopAnimating];
            weakSelf.userList = data;
            [weakSelf reloadData];
        }
        [weakSelf refreshDataFromServer:nil];
    }];
}

- (void)refreshDataFromServer:(void (^)(NSArray *data, NSError *error))block
{
    if (self.fetchRequest == nil) {
        [self.indicatorView stopAnimating];
        self.isLoadFinish = YES;
        return;
    }
    [self.indicatorView startAnimating];
    __weak typeof(self) weakSelf = self;
    self.isLoadFinish = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.fetchRequest fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        weakSelf.isLoadFinish = YES;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        _haveNextPage = haveNextPage;
        [weakSelf.indicatorView stopAnimating];
        if (block) {
            block(data, error);
        }
        [weakSelf handleData:data error:error haveNextPage:haveNextPage];
        [weakSelf reloadData];
    }];
}

- (void)fecthNextPageData:(void (^)(NSArray *data, NSError *error))block
{
    __weak typeof(self) weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.isLoadFinish = NO;
    [self.fetchRequest fetchNextPageFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        weakSelf.isLoadFinish = YES;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        _haveNextPage = haveNextPage;
        if (block) {
            block(data, error);
        }
        if (!error) {
            [weakSelf.userList arrayByAddingObjectsFromArray:data];
            [weakSelf reloadData];
        }
    }];
}

- (void)handleData:(NSArray *)data error:(NSError *)error haveNextPage:(BOOL)nextPage
{
    if (data.count > 0) {
        self.userList = data;
        self.noUserTip.hidden = YES;
    }else{
        if (error) {
            self.noUserTip.hidden = YES;
        }else{
            if (self.noUserTip == nil) {
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height/2-80, self.frame.size.width, 40)];
                label.backgroundColor = [UIColor clearColor];
                label.text = UMComLocalizedString(@"Tehre is no user", @"暂时没有相关用户咯");
                label.textAlignment = NSTextAlignmentCenter;
                self.noUserTip = label;
                [self addSubview:label];
            } else {
                self.noUserTip.hidden = NO;
            }
        }
        [UMComShowToast fetchRecommendUserFail:error];
    }
}

@end
