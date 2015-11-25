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
#import "UMComClickActionDelegate.h"
#import "UMComTopic.h"
#import "UMComUser+UMComManagedObject.h"

@interface UMComSysLikeTableView ()<UITableViewDataSource, UITableViewDelegate, UMComRefreshViewDelegate>

@end


@implementation UMComSysLikeTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.rowHeight = 100;
        self.fetchRequest = [[UMComUserLikesReceivedRequest alloc]initWithCount:BatchSize];
    }
    return self;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataArray.count == 0) {
        [self.indicatorView stopAnimating];
    }
    return self.dataArray.count;
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
    UMComLikeModle *likeModel = self.dataArray[indexPath.row];
    [cell reloadCellWithLikeModel:likeModel];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UMComLikeModle *likeModel = self.dataArray[indexPath.row];
    return likeModel.totalHeight;
}


#pragma mark - data handler

- (void)handleCoreDataDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if ([data isKindOfClass:[NSArray class]] &&  data.count > 0) {
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:[self likeModelListWithLikes:data]];
    }
    if (finishHandler) {
        finishHandler();
    }
}

- (void)handleServerDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:[self likeModelListWithLikes:data]];
    }
    if (finishHandler) {
        finishHandler();
    }
}

- (void)handleLoadMoreDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        [self.dataArray addObjectsFromArray:[self likeModelListWithLikes:data]];
    }
    if (finishHandler) {
        finishHandler();
    }
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
    self.portraitUrlString = [user iconUrlStrWithType:UMComIconSmallType];
    self.timeString = createTimeString(like.create_time);
    self.nameString = [NSString stringWithFormat:@"%@ 赞了你",user.name];
    float totalHeight = LikeNameLabelHeight + LikeContentOriginY;
    NSString * feedSting = @"";
    NSMutableArray *feedCheckWords = nil;
    if ([feed.status integerValue] < 2) {
        if (feed.text.length > kFeedContentLength) {
            feedSting = [feed.text substringWithRange:NSMakeRange(0, kFeedContentLength)];
        }else{
            feedSting = feed.text;
        }
       feedCheckWords = [NSMutableArray array];
        for (UMComTopic *topic in feed.topics) {
            NSString *topicName = [NSString stringWithFormat:TopicString,topic.name];
            [feedCheckWords addObject:topicName];
        }
        for (UMComUser *user in feed.related_user) {
            NSString *userName = [NSString stringWithFormat:UserNameString,user.name];
            [feedCheckWords addObject:userName];
        }
    }else{
        feedSting = UMComLocalizedString(@"Delete Content", @"该内容已被删除");
    }
    UMComMutiStyleTextView *feedStyleView = [UMComMutiStyleTextView rectDictionaryWithSize:CGSizeMake(self.subViewWidth-self.feedTextOrigin.x*2, MAXFLOAT) font:UMComFontNotoSansLightWithSafeSize(14) attString:feedSting lineSpace:3 runType:UMComMutiTextRunFeedContentType checkWords:feedCheckWords];
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
        UIImage *resizableImage = [UMComImageWithImageName(@"origin_image_bg") resizableImageWithCapInsets:UIEdgeInsetsMake(20, 50, 0, 0)];
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
     NSString *iconUrl = [user iconUrlStrWithType:UMComIconSmallType];
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
        }else if ([run isKindOfClass:[UMComMutiTextRunURL class]]){
            [weakSelf turnToWebViewWithUrlString:run.text];
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

- (void)turnToWebViewWithUrlString:(NSString *)urlString
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnURL:)]) {
        [self.delegate customObj:self clickOnURL:urlString];
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

