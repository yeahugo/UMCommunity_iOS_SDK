//
//  UMComRemoteNoticeViewController.m
//  UMCommunity
//
//  Created by umeng on 15/7/9.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComRemoteNoticeViewController.h"
#import "UIViewController+UMComAddition.h"
#import "UMComTools.h"
#import "UMComNotification.h"
#import "UMComImageView.h"
#import "UMComMutiStyleTextView.h"
#import "UMComUser.h"
#import "UMComTools.h"
#import "UMComPullRequest.h"
#import "UMComSession.h"
#import "UIView+UMComTipLabel.h"
#import "UMComRefreshView.h"
#import "UMComClickActionDelegate.h"


const float CellSubViewOriginX = 50;
const float CellSubViewRightSpace = 10;
const float NameLabelHeight = 30;
const float ContentOriginY = 15;

@interface UMComRemoteNoticeViewController ()<UITableViewDataSource, UITableViewDelegate, UMComRefreshViewDelegate>

@property (nonatomic, strong) UMComUserNotificationRequest *notificationRequest;

@property (nonatomic, strong) NSArray *notificationList;

@property (nonatomic, strong) NSArray *styleViewList;

@property (nonatomic, assign) BOOL haveNextPage;

@property (nonatomic, assign) BOOL isLoadFinish;

@property (nonatomic, strong) UMComRefreshView *tableHeadView;

@property (nonatomic, strong) UMComRefreshView *tableFootView;

@end

@implementation UMComRemoteNoticeViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//    }
    [self setBackButtonWithImage];
    [self setTitleViewWithTitle:UMComLocalizedString(@"manager_notification", @"管理员通知")];
    
    UMComRefreshView *headView = [[UMComRefreshView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kUMComRefreshOffsetHeight)];
    headView.startLocation = -kUMComRefreshOffsetHeight;
    headView.refreshDelegate = self;
    self.tableView.tableHeaderView = headView;
    self.tableHeadView = headView;
    
    UMComRefreshView *footView = [[UMComRefreshView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kUMComRefreshOffsetHeight)];
    footView.isPull = NO;
    footView.refreshDelegate = self;
    footView.startLocation = -kUMComRefreshOffsetHeight;
    self.tableView.tableFooterView = footView;
    self.tableFootView = footView;
    
    self.tableView.frame = CGRectMake(0, -kUMComRefreshOffsetHeight, self.view.frame.size.width, self.view.frame.size.height+kUMComRefreshOffsetHeight);

    self.notificationRequest = [[UMComUserNotificationRequest alloc]initWithUid:[UMComSession sharedInstance].uid count:BatchSize];
    [self refreshNotificationData:nil];
    self.isLoadFinish = NO;
    [self.indicatorView startAnimating];
    // Do any additional setup after loading the view.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.notificationList.count > 0) {
        [self.indicatorView stopAnimating];
    }
    return self.notificationList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UMComSysNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UMComSysNotificationCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell reloadCellWithNotification:self.notificationList[indexPath.row] styleView:self.styleViewList[indexPath.row] viewWidth:tableView.frame.size.width];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UMComMutiStyleTextView *styleView = self.styleViewList[indexPath.row];
    return styleView.totalHeight + ContentOriginY * 3/2 + NameLabelHeight;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isLoadFinish == YES) {
        if (scrollView.contentOffset.y < 0) {
            [self.tableHeadView refreshScrollViewDidScroll:scrollView];
        }else if (_haveNextPage == YES){
            [self.tableFootView refreshScrollViewDidScroll:scrollView];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    float offset = scrollView.contentOffset.y;
    if (_isLoadFinish == YES) {
        //下拉刷新
        if (offset < 0) {
            [self.tableHeadView refreshScrollViewDidEndDragging:scrollView];
        }
        //上拉加载更多
        else if (_haveNextPage == YES && offset > 0) {
            [self.tableFootView refreshScrollViewDidEndDragging:scrollView];
        }else{
            [self.indicatorView stopAnimating];
        }
    }
}

- (void)refreshData:(UMComRefreshView *)refreshView loadingFinishHandler:(RefreshDataLoadFinishHandler)handler
{
    [self refreshNotificationData:^(NSArray *data, NSError *error) {
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

- (void)refreshNotificationData:(void (^)(NSArray *data, NSError *error))block
{
    __weak typeof(self) weakSelf = self;
    self.isLoadFinish = NO;
    [self.notificationRequest fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        _haveNextPage = haveNextPage;
        weakSelf.isLoadFinish = YES;
        [weakSelf.indicatorView stopAnimating];
        if (block) {
            block(data, error);
        }
        if (!error && [data isKindOfClass:[NSArray class]]) {
            weakSelf.notificationList = data;
            self.styleViewList = [self styleViewListWithNotifications:data];
        }
        [weakSelf.tableView showTipLableInViewCentreWithData:self.notificationList error:error message:UMComLocalizedString(@"no_data", @"暂时没有数据咯")];
        [self.tableView reloadData];
    }];
}

- (void)fecthNextPageData:(void (^)(NSArray *data, NSError *error))block
{
    __weak typeof(self) weakSelf = self;
    [self.indicatorView startAnimating];
    self.isLoadFinish = NO;
    [self.notificationRequest fetchNextPageFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        weakSelf.isLoadFinish = YES;
        weakSelf.haveNextPage = haveNextPage;
        [weakSelf.indicatorView stopAnimating];
        if (block) {
            block(data, error);
        }
        if ([data isKindOfClass:[NSArray class]]) {
            [weakSelf.notificationList arrayByAddingObjectsFromArray:data];
            [weakSelf.styleViewList arrayByAddingObjectsFromArray:[weakSelf styleViewListWithNotifications:data]];
        }
        [weakSelf.tableView reloadData];
    }];
}


- (NSArray *)styleViewListWithNotifications:(NSArray *)notifications
{
    NSMutableArray *styleViews = [NSMutableArray arrayWithCapacity:notifications.count];
    for (UMComNotification *notification in notifications) {
        UMComMutiStyleTextView *styleView = [UMComMutiStyleTextView rectDictionaryWithSize:CGSizeMake(self.tableView.frame.size.width-CellSubViewOriginX-CellSubViewRightSpace, MAXFLOAT) font:UMComFontNotoSansLightWithSafeSize(15) attString:notification.content lineSpace:2 runType:UMComMutiTextRunNoneType clickArray:nil];
        [styleViews addObject:styleView];
    }
   return styleViews;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end



@implementation UMComSysNotificationCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.portrait = [[[UMComImageView imageViewClassName] alloc]initWithFrame:CGRectMake(10, ContentOriginY, 30, 30)];
        self.portrait.userInteractionEnabled = YES;
        self.portrait.layer.cornerRadius = self.portrait.frame.size.width/2;
        self.portrait.clipsToBounds = YES;
        [self.contentView addSubview:self.portrait];
        
        self.userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CellSubViewOriginX, ContentOriginY, self.frame.size.width-CellSubViewOriginX-10-120, NameLabelHeight)];
        self.userNameLabel.font = UMComFontNotoSansLightWithSafeSize(15);
        [self.contentView addSubview:self.userNameLabel];
        
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CellSubViewOriginX+self.userNameLabel.frame.size.width, ContentOriginY, 120, NameLabelHeight)];
        self.timeLabel.textColor = [UMComTools colorWithHexString:FontColorGray];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        self.timeLabel.font = UMComFontNotoSansLightWithSafeSize(14);
        [self.contentView addSubview:self.timeLabel];
        
        self.contentTextView = [[UMComMutiStyleTextView alloc] initWithFrame:CGRectMake(CellSubViewOriginX, ContentOriginY + self.userNameLabel.frame.size.height+10, self.frame.size.width-60, 100)];
        self.contentTextView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.contentTextView];
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


- (void)reloadCellWithNotification:(UMComNotification *)notification styleView:(UMComMutiStyleTextView *)styleView viewWidth:(CGFloat)viewWidth
{
    UMComUser *user = notification.creator;
    NSString *iconUrl = [user.icon_url valueForKey:@"240"];
    [self.portrait setImageURL:iconUrl placeHolderImage:[UMComImageView placeHolderImageGender:user.gender.integerValue]];
    self.userNameLabel.text = user.name;
    self.timeLabel.text = createTimeString(notification.create_time);
    self.userNameLabel.frame = CGRectMake(CellSubViewOriginX, ContentOriginY/2, viewWidth-120-CellSubViewOriginX, NameLabelHeight);
    self.timeLabel.frame = CGRectMake(CellSubViewOriginX+self.userNameLabel.frame.size.width-10, ContentOriginY/2, 120, NameLabelHeight);
    self.contentTextView.frame = CGRectMake(CellSubViewOriginX, self.userNameLabel.frame.size.height+self.userNameLabel.frame.origin.y, viewWidth-CellSubViewOriginX-10, styleView.totalHeight);
    [self.contentTextView setMutiStyleTextViewProperty:styleView];
    self.contentTextView.runType = UMComMutiTextRunNoneType;
    self.contentTextView.clickOnlinkText = ^(UMComMutiStyleTextView *styleView,UMComMutiTextRun *run){
    };
}


@end
