//
//  UMComSysLikeTableView.m
//  UMCommunity
//
//  Created by umeng on 15/7/10.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComSysLikeTableView.h"
#import "UMComImageView.h"
#import "UMComTools.h"
#import "UMComMutiStyleTextView.h"
#import "UMComLike.h"
#import "UMComFeed.h"
#import "UMComUser.h"
#import "UMComPullRequest.h"
#import "UMComSession.h"
#import "UMComFeed+UMComManagedObject.h"
#import "UMComRefreshView.h"
#import "UIView+UMComTipLabel.h"
#import "UMComClickActionDelegate.h"

@interface UMComSysLikeTableView ()<UITableViewDataSource, UITableViewDelegate, UMComRefreshViewDelegate>

@property (nonatomic, strong) UMComPullRequest *likeFecthRequest;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, assign) BOOL isLoadFinish;

@property (nonatomic, assign) BOOL haveNextPage;

@end

@implementation UMComSysLikeTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.rowHeight = 100;//554b218f7019c95d929b0ffc//54c6069a0bbbaf5ec82b206f
        self.likeFecthRequest = [[UMComUserLikesReceivedRequest alloc]initWithUid:[UMComSession sharedInstance].uid count:BatchSize];
        [self fetchdataFromCoreData];
        [self refreshData:nil];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.separatorColor = TableViewSeparatorRGBColor;
        
        if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
            [self setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([self respondsToSelector:@selector(setLayoutMargins:)])
        {
            [self setLayoutMargins:UIEdgeInsetsZero];
        }
        self.indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.indicatorView.frame = CGRectMake(frame.size.width/2-25, frame.size.height/2-25, 50, 50);
        [self.indicatorView startAnimating];
        [self addSubview:self.indicatorView];
        self.isLoadFinish = YES;
        self.haveNextPage = NO;
    }
    return self;
}

- (void)setHeadView:(UMComRefreshView *)headView
{
    _headView = headView;
    _headView.refreshDelegate = self;
    headView.startLocation = self.frame.origin.y;
    self.tableHeaderView = _headView;
}

- (void)setFootView:(UMComRefreshView *)footView
{
    _footView = footView;
    _footView.refreshDelegate = self;
    footView.startLocation = self.frame.origin.y;
    self.tableFooterView = _footView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.likeList.count == 0) {
        [self.indicatorView stopAnimating];
    }
    return self.likeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    
    UMComSysLikeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UMComSysLikeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.delegate = self.cellActionDelegate;
    UMComLikeModle *likeModel = self.likeList[indexPath.row];
    [cell reloadCellWithLikeModel:likeModel];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UMComLikeModle *likeModel = self.likeList[indexPath.row];
    return likeModel.totalHeight;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isLoadFinish == YES) {
        if (scrollView.contentOffset.y < 0) {
            [self.headView refreshScrollViewDidScroll:scrollView];
        }else if (_haveNextPage == YES){
            [self.footView refreshScrollViewDidScroll:scrollView];
        }
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    float offset = scrollView.contentOffset.y;
    if (_isLoadFinish == YES) {
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
    [self refreshData:^(NSArray *data, NSError *error) {
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

- (void)fetchdataFromCoreData
{
    __weak typeof(self) weakSelf = self;
    [self.likeFecthRequest fetchRequestFromCoreData:^(NSArray *data, NSError *error) {
        if (data.count > 0) {
            self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            NSMutableArray *likeModels = [NSMutableArray arrayWithCapacity:data.count];
            for (UMComLike *like in data) {
                UMComLikeModle *likeModel = [UMComLikeModle likeModelWithLike:like viewWidth:weakSelf.frame.size.width];
                [likeModels addObject:likeModel];
            }
            weakSelf.likeList = likeModels;
            [weakSelf.indicatorView stopAnimating];
        }
        [weakSelf reloadData];
        [weakSelf refreshData:nil];
    }];
}

- (void)refreshData:(void (^)(NSArray *data, NSError *error))block
{
    if (self.likeFecthRequest == nil) {
        [self.indicatorView stopAnimating];
        return;
    }
    if (self.likeList.count > 0) {
        [self.indicatorView stopAnimating];
    }
    __weak typeof(self) weakSelf = self;
    self.isLoadFinish = NO;
    [self.likeFecthRequest fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        weakSelf.isLoadFinish = YES;
        weakSelf.haveNextPage = haveNextPage;
        [weakSelf.indicatorView stopAnimating];
        if (block) {
            block(data, error);
        }
        if (!error && [data isKindOfClass:[NSArray class]]) {
            weakSelf.likeList = [self likeModelListWithLikes:data];
        }
        [weakSelf showTipLableInViewCentreWithData:self.likeList error:error message:UMComLocalizedString(@"no_data", @"暂时没有数据咯")];
        [weakSelf reloadData];
    }];
}


- (void)fecthNextPageData:(void (^)(NSArray *data, NSError *error))block
{
    if (self.likeFecthRequest == nil) {
        [self.indicatorView stopAnimating];
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.isLoadFinish = NO;
    [self.likeFecthRequest fetchNextPageFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        weakSelf.isLoadFinish = YES;
        weakSelf.haveNextPage = haveNextPage;
        [weakSelf.indicatorView stopAnimating];
        if (block) {
            block(data, error);
        }
        if (!error && [data isKindOfClass:[NSArray class]]) {
            weakSelf.likeList = [self.likeList arrayByAddingObjectsFromArray:[self likeModelListWithLikes:data]];
        }
        [self reloadData];
    }];
}

- (NSArray *)likeModelListWithLikes:(NSArray *)likes
{
    NSMutableArray *likeModels = [NSMutableArray arrayWithCapacity:likes.count];
    for (UMComLike *like in likes) {
        UMComLikeModle *likeModel = [UMComLikeModle likeModelWithLike:like viewWidth:self.frame.size.width];
        [likeModels addObject:likeModel];
    }
    return likeModels;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

const float LikeNameLabelHeight = 30;
const float LikeContentOriginY = 10;


@implementation UMComLikeModle
{
    float mainViewWidth;
}
+ (UMComLikeModle *)likeModelWithLike:(UMComLike *)like viewWidth:(float)viewWidth
{
    UMComLikeModle *likeModel = [[UMComLikeModle alloc]init];
    likeModel.subViewsOriginX = 50;
    likeModel.subViewWidth = viewWidth - likeModel.subViewsOriginX - 10;
    likeModel.viewWidth = viewWidth;
    [likeModel resetWithLike:like];
    likeModel.feedTextOrigin = CGPointMake(2, 10);
    return likeModel;
}

- (void)resetWithLike:(UMComLike *)like
{
    self.like = like;
    UMComUser *user = like.creator;
    UMComFeed *feed = like.feed;
    self.portraitUrlString = [user.icon_url valueForKey:@"240"];
    self.timeString = createTimeString(like.create_time);
    self.nameString = [NSString stringWithFormat:@"%@ 赞了你",user.name];
    float totalHeight = LikeNameLabelHeight + LikeContentOriginY;
    NSString * feedSting = @"";
    NSMutableDictionary *feedClickTextDict = [NSMutableDictionary dictionaryWithCapacity:1];
    if ([feed.status integerValue] < 2) {
        feedSting = feed.text;
        if (feed.topics.count > 0) {
            [feedClickTextDict setObject:feed.topics.array forKey:@"topics"];
        }
        if (feed.related_user.count > 0) {
            [feedClickTextDict setObject:feed.related_user.array forKey:@"related_user"];
        }
    }else{
        feedSting = UMComLocalizedString(@"Delete Content", @"该内容已被删除");
    }
    UMComMutiStyleTextView *feedStyleView = [UMComMutiStyleTextView rectDictionaryWithSize:CGSizeMake(self.subViewWidth-self.feedTextOrigin.x*2, MAXFLOAT) font:UMComFontNotoSansLightWithSafeSize(14) attString:feedSting lineSpace:3 runType:UMComMutiTextRunFeedContentType clickArray:[NSMutableArray arrayWithObject:feedClickTextDict]];
    self.feedStyleView = feedStyleView;
    totalHeight += feedStyleView.totalHeight;
    self.totalHeight = totalHeight+25;
}


@end

@interface UMComSysLikeCell ()

@property (nonatomic, strong) UIImageView *bgimageView;

@property (nonatomic, strong) UMComLike *like;


@end

@implementation UMComSysLikeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat textOriginX = 50;
        CGFloat textOriginY = LikeContentOriginY;
        self.portrait = [[[UMComImageView imageViewClassName] alloc]initWithFrame:CGRectMake(10, textOriginY, 30, 30)];
        self.portrait.userInteractionEnabled = YES;
        self.portrait.layer.cornerRadius = self.portrait.frame.size.width/2;
        self.portrait.clipsToBounds = YES;
        [self.contentView addSubview:self.portrait];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didSelectedUser)];
        [self.portrait addGestureRecognizer:tap];
        
        self.userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(textOriginX, textOriginY, self.frame.size.width-textOriginX-10-120, LikeNameLabelHeight)];
        self.userNameLabel.font = UMComFontNotoSansLightWithSafeSize(15);
        [self.contentView addSubview:self.userNameLabel];
        
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(textOriginX+self.userNameLabel.frame.size.width, textOriginY, 120, LikeNameLabelHeight)];
        self.timeLabel.textColor = [UMComTools colorWithHexString:FontColorGray];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        self.timeLabel.font = UMComFontNotoSansLightWithSafeSize(14);
        [self.contentView addSubview:self.timeLabel];
    
        self.bgimageView = [[UIImageView alloc]initWithFrame:CGRectMake(textOriginX, textOriginY + self.userNameLabel.frame.size.height+10, self.frame.size.width-60, 100)];
        UIImage *resizableImage = [[UIImage imageNamed:@"origin_image_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 50, 0, 0)];
        self.bgimageView.image = resizableImage;
        [self.contentView addSubview:self.bgimageView];
        
        self.feedTextView = [[UMComMutiStyleTextView alloc] initWithFrame:CGRectMake(textOriginX, textOriginY + self.userNameLabel.frame.size.height+10, self.frame.size.width-60, 100)];
        self.feedTextView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.feedTextView];
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


- (void)reloadCellWithLikeModel:(UMComLikeModle *)likeModel
{
    self.like = likeModel.like;
    UMComUser *user = likeModel.like.creator;
     NSString *iconUrl = [user.icon_url valueForKey:@"240"];
    [self.portrait setImageURL:iconUrl placeHolderImage:[UMComImageView placeHolderImageGender:user.gender.integerValue]];
    
    self.userNameLabel.text = likeModel.nameString;
    self.timeLabel.text = likeModel.timeString;
    self.userNameLabel.frame = CGRectMake(likeModel.subViewsOriginX, LikeContentOriginY, likeModel.subViewWidth-120, LikeNameLabelHeight);
    self.timeLabel.frame = CGRectMake(likeModel.subViewsOriginX+self.userNameLabel.frame.size.width, LikeContentOriginY, 120, LikeNameLabelHeight);
    
    self.bgimageView.frame = CGRectMake(likeModel.subViewsOriginX, LikeContentOriginY+LikeNameLabelHeight, likeModel.subViewWidth, likeModel.feedStyleView.totalHeight+likeModel.feedTextOrigin.y);
    
    self.feedTextView.frame = CGRectMake(likeModel.subViewsOriginX+likeModel.feedTextOrigin.x, LikeContentOriginY+LikeNameLabelHeight+likeModel.feedTextOrigin.y, likeModel.subViewWidth-likeModel.feedTextOrigin.x*2, likeModel.feedStyleView.totalHeight);
    [self.feedTextView setMutiStyleTextViewProperty:likeModel.feedStyleView];
    self.feedTextView.runType = UMComMutiTextRunFeedContentType;
    __weak typeof (self) weakSelf = self;
    self.feedTextView.clickOnlinkText = ^(UMComMutiStyleTextView *styleView,UMComMutiTextRun *run){
        if ([run isKindOfClass:[UMComMutiTextRunClickUser class]]) {
            UMComMutiTextRunClickUser *userRun = (UMComMutiTextRunClickUser *)run;
            UMComUser *user = [weakSelf.like.feed relatedUserWithUserName:userRun.text];
            [weakSelf turnToUserCenterWithUser:user];
        }else if ([run isKindOfClass:[UMComMutiTextRunTopic class]])
        {
            UMComMutiTextRunTopic *topicRun = (UMComMutiTextRunTopic *)run;
            UMComTopic *topic = [weakSelf.like.feed relatedTopicWithTopicName:topicRun.text];
            [weakSelf turnToTopicViewWithTopic:topic];
        }else{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(customObj:clickOnFeedText:)]) {
                __strong typeof(weakSelf)strongSelf = weakSelf;
                [weakSelf.delegate customObj:strongSelf clickOnFeedText:weakSelf.like.feed];
            }
        }
    };
}

- (void)didSelectedUser
{
    [self turnToUserCenterWithUser:self.like.creator];
}

- (void)turnToUserCenterWithUser:(UMComUser *)user
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnUser:)]) {
        [self.delegate customObj:self clickOnUser:user];
    }
}

- (void)turnToTopicViewWithTopic:(UMComTopic *)topic
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnTopic:)]) {
        [self.delegate customObj:self clickOnTopic:topic];
    }
}

- (void)drawRect:(CGRect)rect
{
    UIColor *color = TableViewSeparatorRGBColor;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height - TableViewCellSpace, rect.size.width, TableViewCellSpace));
}

@end

