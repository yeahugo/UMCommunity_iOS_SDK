//
//  UMComFeedsTableViewCell.m
//  UMCommunity
//
//  Created by Gavin Ye on 8/27/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComFeedsTableViewCell.h"
#import "UMComUser.h"
#import "UMComTopic.h"
#import "UMComComment.h"
#import "UMComHttpPagesManager.h"
#import "UMComFeedTableViewController.h"
#import "UMComSession.h"
#import "UMComHttpManager.h"
#import "UMComCoreData.h"
#import "UMComSyntaxHighlightTextStorage.h"
#import "UMComAction.h"
#import "UMComFeedsCommentTableViewCell.h"
#import "UMComFeedsTableView.h"
#import "UMComFeedsTableView.h"
#import "UMComShowToast.h"
#import <QuartzCore/QuartzCore.h>
#import "UMComTools.h"
#import "UMComLike.h"
#import "UMUtils.h"

#define USE_UMIMAGE 1
#define USE_GRIDVIEW 1

#define  ShowCommentsNum 5
#define CommentCellHeight 25
#define ForwardBackgroundTag 1000
#define LikePerRowNum 6

#define kTagSpam 100
#define kTagDelete 101
#define ShowLikeNum 14

#define TextViewLineSpace 3
#define LikeViewLineSpace 8
#define CommentViewLineSpace 8

#define DeltaHeight 10
#define OriginFeedHeightOffset 0.5
#define OriginFeedOriginY 11

#define ImageSpace 4
#define ComTextViewHeightOffset 4
#define LikeTextViewHeightOffset 4

#define LikeNumString @"  %lu"
#define OriginUserNameString @"@%@：%@"

#define TableViewDeltaWidth 75
#define CommentTableViewDeltaWidth 43
#define LikeViewDeltaWidth 43
#define FeedAndOriginFeedDeltaWidth 10

#define LocationBackgroundViewHeight 21
#define UserNameLabelViewHeight      29
#define ImageViewHeight              75
#define LikeNumWith                  15

#define FeedFont UMComFontNotoSansLightWithSafeSize(15)
#define LikeFont UMComFontNotoSansLightWithSafeSize(14)
#define CommentFont UMComFontNotoSansLightWithSafeSize(13)


@interface UMComFeedsTableViewCell ()<UIAlertViewDelegate>

@property (nonatomic, weak) UMComFeedsTableView *tableView;

@property (nonatomic, strong) UMComLike *like;

@property (nonatomic, strong) NSArray *commentCellHeightArr;

@property (nonatomic, strong) UILabel *likeNumLabel;

@property (nonatomic, assign) CGFloat cellSubviewCommonWidth;

@property (nonatomic, strong) UMComFeedStyle *feedStyle;

@end


static inline NSString * createTimeString(NSString * create_time)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *createDate= [dateFormatter dateFromString:create_time];
    NSTimeInterval timeInterval = -[createDate timeIntervalSinceNow];
   
    NSDateFormatter *showFormatter = [[NSDateFormatter alloc] init];
    [showFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString * showDate = [showFormatter stringFromDate:createDate];
    NSString *timeDescription = nil;
    float timeValue = timeInterval/60;
    if (timeValue < 1) {
        timeDescription = @"0 秒前";//[NSString stringWithFormat:@"0 秒前"];
        if (timeValue < 0) {
            timeDescription = @"0 秒前";
            return timeDescription;

        }else{
            timeDescription = [NSString stringWithFormat:@"%d 秒前",(int)timeInterval];
            return timeDescription;
        }
    }
    
    if(timeValue >= 1 && timeValue < 60){
        timeDescription = [NSString stringWithFormat:@"%d 分钟前",(int)timeValue];
        return timeDescription;
    }
    timeValue = timeValue/60;
    
    if ( timeValue >= 1 && timeValue < 24) {
        timeDescription = [NSString stringWithFormat:@"%d 小时前 ",(int)timeValue];
        return timeDescription;
    }
    timeValue = timeValue/24;
    if (timeValue >= 1 && timeValue < 2) {
        timeDescription = [NSString stringWithFormat:@"昨天"];
        return timeDescription;
    }
    else if (timeValue >= 2 && timeValue < 3){
        timeDescription = [NSString stringWithFormat:@"前天"];
        return timeDescription;
    }
    
    timeDescription = showDate;
    
    return timeDescription;
}

@implementation UMComFeedsTableViewCell

- (void)removeSubViews:(UIView *)superView
{
    for (UIView * subView in superView.subviews) {
        [subView removeFromSuperview];
    }
}

-(void)awakeFromNib
{
    self.userNameLabel.adjustsFontSizeToFitWidth = YES;
    self.dateLabel.font = UMComFontNotoSansDemiWithSafeSize(12);
    [self.commentTableView registerNib:[UINib nibWithNibName:@"UMComFeedsCommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"FeedsCommentTableViewCell"];
    UITapGestureRecognizer *tapGestureRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickUserProfile:)];
    
    UMComImageView *avatarImageView = [[[UMComImageView imageViewClassName] alloc] initWithFrame:CGRectMake(19, 12, 36, 36)];
    avatarImageView.userInteractionEnabled = YES;
    [avatarImageView addGestureRecognizer:tapGestureRecog];
    avatarImageView.clipsToBounds = YES;
    avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width/2;
    self.avatarImageView = avatarImageView;
    [self.contentView addSubview:self.avatarImageView];
    
    UIImageView *likeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"like+x"]];
    likeImageView.frame = CGRectMake(0, 0, likeImageView.frame.size.width, likeImageView.frame.size.height);
    likeImageView.center = CGPointMake((self.likeImageBgVIew.frame.size.width - self.likeListTextView.frame.size.width)/2-2, likeImageView.frame.size.width/2+4);
    [self.likeImageBgVIew addSubview:likeImageView];
    
    self.likeNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(190, 0, 50, 20)];
    self.likeNumLabel.backgroundColor = [UIColor clearColor];
    self.likeNumLabel.font = UMComFontNotoSansLightWithSafeSize(11);
    self.likeNumLabel.textColor = [UMComTools colorWithHexString:@"#8e8e93"];
    self.likeNumLabel.textAlignment = NSTextAlignmentRight;
    [self.likeListTextView addSubview:self.likeNumLabel];
    
    UIView *seperateView = [[UIView alloc]initWithFrame:CGRectMake(self.likeImageBgVIew.frame.origin.x, self.likeImageBgVIew.frame.origin.y + self.likeListTextView.frame.size.height, self.likeImageBgVIew.frame.size.width, 0.5)];
    seperateView.backgroundColor = [UMComTools colorWithHexString:@"#e7e7e7"];
    [self.contentView addSubview:seperateView];
    self.seperateView = seperateView;
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

- (void)clickInFeedTextWithObject:(id)object
{
    if ([object isKindOfClass:[UMComMutiTextRunClickUser class]]) {
        UMComMutiTextRunClickUser *userRun = (UMComMutiTextRunClickUser *)object;
        [self clickInUserWithUserNameString:userRun.text];
    }else if ([object isKindOfClass:[UMComMutiTextRunTopic class]])
    {
        UMComMutiTextRunTopic *topicRun = (UMComMutiTextRunTopic *)object;
        [self clickInTopicWithTopicNameString:topicRun.text];
    }
}


- (void)clickInUserWithUserNameString:(NSString *)nameString
{
    NSString *name = [nameString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    NSMutableArray *relatedUsers = [NSMutableArray arrayWithArray:self.feed.related_user.array];
    if (self.feed.origin_feed.creator) {
        [relatedUsers addObject:self.feed.origin_feed.creator];
    }
    for (UMComUser * user in relatedUsers) {
        if ([name isEqualToString:user.name]) {
            [self turnToUserCenterWithUser:user];
            break;
        }
    }
}


- (void)clickInTopicWithTopicNameString:(NSString *)topicNameString
{
    NSString *topicName = [topicNameString substringWithRange:NSMakeRange(1, topicNameString.length -2)];
    if ([self.tableView.delegate respondsToSelector:@selector(topic)]) {
        UMComTopic *topic = [self.tableView.delegate performSelector:@selector(topic)];
        if ([topicName isEqualToString:topic.name]) {
            return;
        }
    }
    for (UMComTopic * topic in self.feed.topics) {
        if ([topicName isEqualToString:topic.name]) {
            [[UMComTopicFeedAction action] performActionAfterLogin:topic viewController:self.tableView.viewController completion:nil];
            break;
        }
    }
}

- (void)turnToUserCenterWithUser:(UMComUser *)user
{
    [[UMComUserCenterAction action] performActionAfterLogin:user viewController:self.tableView.viewController completion:nil];
}


-(UMComFeedsTableView *)tableView
{
    return (UMComFeedsTableView *)_tableView;
}


- (CGFloat)getViewOriginYWithView:(UIView *)view
{
    return view.frame.origin.y + view.frame.size.height;
}

/****************************reload cell views start *****************************/
-(void)reload:(UMComFeed *)feed tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath feedStyle:(UMComFeedStyle *)feedStyle;
{
    self.feed = feed;
    self.feedStyle = feedStyle;
    self.userNameLabel.text = feed.creator.name;
    self.indexPath = indexPath;
    self.tableView = (UMComFeedsTableView *)tableView;
    [self.dateLabel setText:createTimeString(feed.create_time)];
    self.cellSubviewCommonWidth = tableView.frame.size.width - TableViewDeltaWidth;
    //刷新头像
    [self reloadAvatarImageViewWithFeed:feed];

    float totalHeight = UserNameLabelViewHeight + DeltaHeight;
    //刷新fakeTextView
    [self reloadFakeTextViewWithFeed:feed originHeigt:totalHeight];
    
    totalHeight += self.fakeTextView.frame.size.height;
    
    float totalBgHeight = 0;
    if (feed.origin_feed && !feed.origin_feed.isFault && !feed.origin_feed.isDeleted) {
        //如果是转发，显示fakeOriginTextView，否则隐藏
        [self reloadFakeOriginTextViewWithFeed:feed originHeigt:totalBgHeight];
        totalBgHeight += self.fakeOriginTextView.frame.size.height + OriginFeedOriginY;
        UIImage *resizableImage = [[UIImage imageNamed:@"origin_image_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 50, 0, 0)];
        self.imagesBackGroundView.image = resizableImage;
    } else {
        self.imagesBackGroundView.image = nil;
        self.fakeOriginTextView.hidden = YES;
    }
    //如果存在定位信息则显示否则隐藏
    if (feed.location == nil) {
        self.locationBackground.hidden = YES;
    } else {
        [self.locationLabel setText:feed.location];
        self.locationBackground.hidden = NO;
        self.locationBackground.frame = CGRectMake(self.locationBackground.frame.origin.x, totalBgHeight, self.locationBackground.frame.size.width, self.locationBackground.frame.size.height);
        totalBgHeight += self.locationBackground.frame.size.height;
    }
    
    NSDictionary *imagesArray =  feed.images;
    if (imagesArray.count == 0 && feed.origin_feed && !feed.origin_feed.isFault) {
        imagesArray = feed.origin_feed.images;
    }
    if ([imagesArray count] == 0) {
        self.gridView.hidden = YES;
    } else {
        //如果有图片则刷新图片
        [self reloadGridViewWithFeed:feed originHeigt:totalBgHeight imagesArr:imagesArray];
        totalBgHeight += self.gridView.frame.size.height+2;
    }
    self.imagesBackGroundView.frame = CGRectMake(self.imagesBackGroundView.frame.origin.x, totalHeight, self.imagesBackGroundView.frame.size.width, totalBgHeight);
    
    totalHeight += self.imagesBackGroundView.frame.size.height;

    self.showEditBackGround.center = CGPointMake(self.showEditBackGround.center.x, totalHeight+self.showEditBackGround.frame.size.height/2);
    self.editBackGround.center = CGPointMake(self.editBackGround.center.x,  self.showEditBackGround.center.y);
    self.dateLabel.center = CGPointMake(self.dateLabel.center.x, totalHeight+self.dateLabel.frame.size.height/2 + DeltaHeight);
    totalHeight += self.dateLabel.frame.size.height + DeltaHeight;
    
    NSInteger likeNum = feed.likes.count < ShowLikeNum ? feed.likes.count : ShowLikeNum;

    if (likeNum == 0) {
        self.likeListTextView.hidden = YES;
        self.likeImageBgVIew.hidden = YES;
        self.likeNumLabel.hidden =  YES;
        [self.likeButton setImage:[UIImage imageNamed:@"likex"] forState:UIControlStateNormal];
        totalHeight += DeltaHeight;
        self.seperateView.hidden = YES;
    } else{
        [self reloadLikeTextViewWithFeed:feed originHeigt:totalHeight likeNum:(int)likeNum];
        if (feed.comments.count > 0) {
            self.seperateView.frame = CGRectMake(self.likeImageBgVIew.frame.origin.x, self.likeImageBgVIew.frame.origin.y + self.likeImageBgVIew.frame.size.height,self.likeImageBgVIew.frame.size.width, 0.5);
            self.seperateView.hidden = NO;
        } else {
            self.seperateView.hidden = YES;
        }
        totalHeight += self.likeListTextView.frame.size.height+DeltaHeight;
    }
    
    if (self.feed.comments.count == 0) {
        self.commentTableView.hidden = YES;
    } else {
        [self reloadCommentTableViewWithFeed:feed originHeigt:totalHeight];
        totalHeight += self.commentTableView.contentSize.height;
    }
    if ([feed.type integerValue] == 1) {
        self.acounTypeLabel.hidden = NO;
        self.acounTypeLabel.text = @"公告";
    }else{
        self.acounTypeLabel.hidden = YES;
        self.acounTypeLabel.text = @"";
    }
}

- (void)reloadAvatarImageViewWithFeed:(UMComFeed *)feed
{
    NSDictionary * iconUrl = !feed.creator.isFault ? feed.creator.icon_url : nil;
    NSString *iconString = [iconUrl objectForKey:@"240"];
    
    UIImage *placeHolderImage = [UMComImageView placeHolderImageGender:[feed.creator.gender integerValue]];
    [self.avatarImageView setImageURL:iconString placeHolderImage:placeHolderImage];
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2;
}

- (void)reloadFakeTextViewWithFeed:(UMComFeed *)feed originHeigt:(CGFloat)originHeigth
{
    NSString *feedString = @"";
    if (feed.text) {
        feedString = feed.text;
    }

    self.fakeTextView.frame = CGRectMake(self.fakeTextView.frame.origin.x, originHeigth , self.fakeTextView.frame.size.width, self.feedStyle.feedStyleView.totalHeight);
    [self.fakeTextView setMutiStyleTextViewProperty:self.feedStyle.feedStyleView];
    self.fakeTextView.backgroundColor = [UIColor clearColor];
    self.fakeTextView.runType = UMComMutiTextRunFeedContentType;
    __weak UMComFeedsTableViewCell *weakSelf = self;
    self.fakeTextView.clickOnlinkText = ^(UMComMutiTextRun *run){
        [weakSelf clickInFeedTextWithObject:run];
    };
}

- (void)reloadFakeOriginTextViewWithFeed:(UMComFeed *)feed originHeigt:(CGFloat)originHeigth
{
   
    self.fakeOriginTextView.pointOffset = CGPointMake(0, OriginFeedHeightOffset);
    self.fakeOriginTextView.frame = CGRectMake(self.fakeOriginTextView.frame.origin.x, OriginFeedOriginY, self.cellSubviewCommonWidth-FeedAndOriginFeedDeltaWidth, self.feedStyle.originFeedStyleView.totalHeight);
    [self.fakeOriginTextView setMutiStyleTextViewProperty:self.feedStyle.originFeedStyleView];
    self.fakeOriginTextView.runType = UMComMutiTextRunFeedContentType;
    
    __weak UMComFeedsTableViewCell *weakSelf = self;
    self.fakeOriginTextView.clickOnlinkText = ^(UMComMutiTextRun *run){
        [weakSelf clickInFeedTextWithObject:run];
    };
    self.fakeOriginTextView.hidden = NO;
}

- (void)reloadGridViewWithFeed:(UMComFeed *)feed originHeigt:(CGFloat)originHeigth imagesArr:(NSDictionary *)imagesArray
{
    NSMutableArray *showImageArray = [[NSMutableArray alloc] init];
    for (NSString *imageDictionary in imagesArray) {
        [showImageArray addObject:@[[imageDictionary valueForKey:@"360"],[imageDictionary valueForKey:@"origin"]]];
    }
    self.gridView.hidden = NO;
    [self.gridView setImages:showImageArray placeholder:[UIImage imageNamed:@"image-placeholder"] cellPad:ImageSpace];
    
    if (feed.origin_feed  && !feed.origin_feed.isFault) {
        self.gridView.frame = CGRectMake(2, originHeigth, self.cellSubviewCommonWidth, ceil((float)imagesArray.count/3) *  (ImageViewHeight+ImageSpace) + ImageSpace);
    }else{
        self.gridView.frame = CGRectMake(0,  originHeigth, self.cellSubviewCommonWidth, ceil((float)imagesArray.count/3) *  (ImageViewHeight+ImageSpace) + ImageSpace);
    }
    [self.gridView setPresentFatherViewController:self.tableView.viewController];
}

- (void)reloadLikeTextViewWithFeed:(UMComFeed *)feed originHeigt:(CGFloat)originHeigth likeNum:(int)likeNum
{
    self.likeListTextView.hidden = NO;
    self.likeNumLabel.hidden = NO;
    self.likeListTextView.runType = UMComMutiTextRunLikeType;
    __weak UMComFeedsTableViewCell *weakSelf = self;
    self.likeListTextView.clickOnlinkText = ^(UMComMutiTextRun  *run){
        if ([run isKindOfClass:[UMComMutiTextRunClickUser class]]) {
            UMComMutiTextRunClickUser *userRun = (UMComMutiTextRunClickUser *)run;
            [weakSelf turnToUserCenterWithUser:userRun.user];
        }
    };
    self.likeListTextView.pointOffset = CGPointMake(0, LikeTextViewHeightOffset);

    UMComMutiStyleTextView *likeStyleView = self.feedStyle.likeStyleView;
    CGFloat likeTextViewHeight = self.feedStyle.likeStyleView.totalHeight;
    if ((self.likeListTextView.frame.size.width - likeStyleView.lastLineWidth) < LikeNumWith) {
        likeTextViewHeight += likeStyleView.lineHeight;
    }
    self.likeNumLabel.text = [NSString stringWithFormat:@"%d",(int)likeNum];
    self.likeListTextView.frame = CGRectMake(self.likeListTextView.frame.origin.x, 0, self.likeListTextView.frame.size.width, likeTextViewHeight);
    self.likeNumLabel.frame = CGRectMake(self.likeListTextView.frame.size.width-LikeNumWith, likeTextViewHeight-likeStyleView.lineHeight+1, LikeNumWith, likeStyleView.lineHeight);
    self.likeImageBgVIew.hidden = NO;
    self.likeImageBgVIew.frame = CGRectMake(self.likeImageBgVIew.frame.origin.x, originHeigth+DeltaHeight, self.likeImageBgVIew.frame.size.width, self.likeListTextView.frame.size.height);
    [self.likeListTextView setMutiStyleTextViewProperty:self.feedStyle.likeStyleView];
    if (self.feedStyle.likeId) {
        [self.likeButton setImage:[UIImage imageNamed:@"like+x"] forState:UIControlStateNormal];
    } else {
        [self.likeButton setImage:[UIImage imageNamed:@"likex"] forState:UIControlStateNormal];
    }
}


- (void)reloadCommentTableViewWithFeed:(UMComFeed *)feed originHeigt:(CGFloat)originHeigth
{
    BOOL isShowAllComment = [(UMComFeedsTableView *)self.tableView isShowAllComment:(int)self.indexPath.row];
    if (!isShowAllComment && feed.comments.count >= ShowCommentsNum && feed.comment_navigator) {
        self.reloadComments = [[feed.comments array] subarrayWithRange:NSMakeRange(0,ShowCommentsNum)];
    } else{
        self.reloadComments = feed.comments.array;
    }
    self.commentCellHeightArr = self.feedStyle.commentHeightArray;
    [self.commentTableView reloadData];
    self.commentTableView.hidden = NO;
    self.commentTableView.frame = CGRectMake(self.commentTableView.frame.origin.x, originHeigth, self.cellSubviewCommonWidth, self.commentTableView.contentSize.height);
}

/****************************reload cell views end *****************************/


/****************************get cell height start *****************************/

+ (UMComFeedStyle *)getCellHeightWithFeed:(UMComFeed *)feed isShowComment:(BOOL)isShowComment tableViewWidth:(float)viewWidth
{
    UMComFeedStyle *feedStyle = [[UMComFeedStyle alloc] init];
    float totalHeight = UserNameLabelViewHeight + DeltaHeight;
    NSString * feedSting = @"";
    if (feed.text) {
        feedSting = feed.text;
        NSMutableDictionary *feedClickTextDict = [NSMutableDictionary dictionaryWithCapacity:1];
        if (feed.topics.count > 0) {
            [feedClickTextDict setObject:feed.topics.array forKey:@"topics"];
        }
        if (feed.related_user.count > 0) {
            [feedClickTextDict setObject:feed.related_user.array forKey:@"related_user"];
        }
        UMComMutiStyleTextView *feedStyleView = [UMComMutiStyleTextView rectDictionaryWithSize:CGSizeMake(viewWidth - TableViewDeltaWidth, MAXFLOAT) font:FeedFont attString:feedSting lineSpace:TextViewLineSpace runType:UMComMutiTextRunFeedContentType clickArray:[NSMutableArray arrayWithObject:feedClickTextDict]];
        feedStyle.feedStyleView = feedStyleView;
        totalHeight = feedStyleView.totalHeight;
    }

    UMComFeed *origin_feed = nil;
    if (feed.origin_feed && !feed.origin_feed.isDeleted && !feed.origin_feed.isFault) {
        origin_feed = feed.origin_feed;
    }
    if (origin_feed) {
        
        NSMutableString *oringFeedString = [NSMutableString stringWithString:@""];
        NSString *originUserName = !feed.origin_feed.creator.isFault ? feed.origin_feed.creator.name : @"";
        if ([feed.origin_feed.status intValue] >= FeedStatusDeleted) {
            feed.origin_feed.text = UMComLocalizedString(@"Delete Content", @"该内容已被删除");
            feed.origin_feed.images = [NSArray array];
        }
        [oringFeedString appendFormat:OriginUserNameString,originUserName,feed.origin_feed.text];
        NSMutableDictionary *originFeedClickTextDict = [NSMutableDictionary dictionaryWithCapacity:1];
        if (feed.origin_feed.topics.count > 0) {
            [originFeedClickTextDict setObject:feed.origin_feed.topics.array forKey:@"topics"];
        }
        NSMutableArray *relatedUsers = [NSMutableArray arrayWithCapacity:1];
        [relatedUsers addObject:feed.origin_feed.creator];
        [relatedUsers addObject:feed.creator];
        if (feed.origin_feed.related_user.count > 0) {
            [relatedUsers addObjectsFromArray:feed.origin_feed.related_user.array];
        }
        [originFeedClickTextDict setObject:relatedUsers forKey:@"related_user"];

        
        UMComMutiStyleTextView *originStyleView = [UMComMutiStyleTextView rectDictionaryWithSize:CGSizeMake(viewWidth-TableViewDeltaWidth-FeedAndOriginFeedDeltaWidth, MAXFLOAT) font:FeedFont attString:oringFeedString lineSpace:TextViewLineSpace runType:UMComMutiTextRunFeedContentType clickArray:[NSMutableArray arrayWithObject:originFeedClickTextDict]];
        originStyleView.totalHeight += OriginFeedHeightOffset/2+4;
        totalHeight += originStyleView.totalHeight + OriginFeedOriginY;
        feedStyle.originFeedStyleView = originStyleView;
    }
    NSArray *images = feed.images;
    if (images.count == 0 && origin_feed) {
        images = origin_feed.images;
    }
    if(images.count > 0) {
        totalHeight += ceil((float)(images.count)/3)* (ImageViewHeight + ImageSpace)+ImageSpace;
    }
    
    if (feed.location) {
        totalHeight += LocationBackgroundViewHeight;
    }
    if(feed.likes.count > 0) {
        NSMutableString *likeString = [NSMutableString stringWithString:@""];
        NSMutableArray *clikDicts = [NSMutableArray arrayWithCapacity:1];
        
        NSInteger likeNum = feed.likes.count < ShowLikeNum ? feed.likes.count : ShowLikeNum;
        
        NSString *loginUid = [UMComSession sharedInstance].uid;
        for (int i = 0; i < likeNum; i++) {
            UMComLike *like = [feed.likes objectAtIndex:i];
            UMComUser *creator = like.creator;     //[[feed.likes objectAtIndex:i] creator];
            NSString * likeNameString = [creator name];
            NSInteger location = likeString.length;
            NSRange range = NSMakeRange(location, likeNameString.length);
            NSDictionary *dict = [NSDictionary dictionaryWithObject:like forKey:NSStringFromRange(range)];
            [clikDicts addObject:dict];
            
            if (likeNameString) {
                [likeString appendString:likeNameString];
            }
            if (i < likeNum -1 && i < ShowLikeNum - 1) {
                [likeString appendString:@"、"];
            }
            if ([creator.uid isEqualToString:loginUid]) {
                feedStyle.likeId = like.id;
            }
        }
        [likeString appendString:@" "];
        
        UMComMutiStyleTextView *likeStyleView = [UMComMutiStyleTextView rectDictionaryWithSize:CGSizeMake(viewWidth-TableViewDeltaWidth - LikeViewDeltaWidth, MAXFLOAT) font:UMComFontNotoSansLightWithSafeSize(14) attString:likeString lineSpace:LikeViewLineSpace runType:UMComMutiTextRunLikeType clickArray:clikDicts];
        float likeTextViewHeight = likeStyleView.totalHeight;
        if ((viewWidth - TableViewDeltaWidth - likeStyleView.lastLineWidth) < LikeNumWith) {
            likeTextViewHeight += likeStyleView.lineHeight;
        }
        totalHeight += likeTextViewHeight+DeltaHeight;
        likeStyleView.totalHeight = likeTextViewHeight;
        feedStyle.likeStyleView = likeStyleView;
        
    }
    if (feed.comments.count > 0) {
        NSArray *reloadComments = nil;
        if (!isShowComment && feed.comments.count >= ShowCommentsNum && feed.comment_navigator ) {
            reloadComments = [[feed.comments array] subarrayWithRange:NSMakeRange(0,ShowCommentsNum)];
        } else {
            reloadComments = feed.comments.array;
        }
        NSArray *commentCellHeightArr = [UMComFeedsTableViewCell commentCellHeightArrWithComments:reloadComments withFrameWidth:viewWidth - TableViewDeltaWidth - CommentTableViewDeltaWidth isShowAllComment:isShowComment feed:feed feedStyle:feedStyle];
        for (NSNumber *height in commentCellHeightArr) {
            totalHeight += [height floatValue];
        }
        if (feed.likes.count == 0) {
            totalHeight += DeltaHeight;
        }
        feedStyle.commentHeightArray = commentCellHeightArr;
    }
    totalHeight += 80;
    feedStyle.totalHeight = totalHeight;
    return feedStyle;
}

/****************************get cell height start *****************************/


-(IBAction)onClickEdit:(UIButton *)button
{
    if (self.editBackGround.hidden) {
        //消除弹出的编辑按钮
        for (int i = 0; i < [self.tableView numberOfRowsInSection:0]; i++) {
            UMComFeedsTableViewCell *cell = (UMComFeedsTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell dissMissEditBackGround];
        }
        self.editBackGround.hidden = NO;
    } else {
        self.editBackGround.hidden = YES;
    }
}

-(IBAction)onClickComment:(id)sender
{
    [UMComSession sharedInstance].feedID = self.feed.feedID;
    [UMComSession sharedInstance].commentFeed = self.feed;
    NSString *uid = [UMComSession sharedInstance].uid;
    [[UMComCommentAction action] performActionAfterLogin:self.feed.feedID viewController:self.tableView.viewController completion:^(NSArray *data, NSError *error) {
        if (!error) {
            if (!uid) {
                [[self.tableView resultArray] insertObject:[UMComSession sharedInstance].commentFeed atIndex:0];
                [self.tableView reloadData];                
            }
            [self.editBackGround setHidden:YES];
            [(UMComFeedsTableView *)self.tableView presentEditView:[UMComSession sharedInstance].feedID selectedCell:self];
        }
    }];
}

-(IBAction)onClickLike:(id)sender
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if (self.feedStyle.likeId) {
        [[UMComDisLikeAction action] performActionAfterLogin:@{@"likeId":self.feedStyle.likeId,@"feedId":self.feed.feedID} viewController:self.tableView.viewController completion:^(NSArray *data, NSError *error) {
            if (!error) {
                [(UMComFeedsTableView *)self.tableView refreshFeedsLike:self.feed.feedID selectedCell:self];
            } else {
                [UMComShowToast deleteLikeFail:error];
            }
        }];
    } else {
        [[UMComLikeAction action] performActionAfterLogin:self.feed.feedID viewController:self.tableView.viewController completion:^(NSArray *data, NSError *error) {
            if (!error) {
                [(UMComFeedsTableView *)self.tableView refreshFeedsLike:self.feed.feedID selectedCell:self];
                
            } else {
                [UMComShowToast createLikeFail:error];
            }
        }];
    }
    
    [self.editBackGround setHidden:YES];
}

-(IBAction)onClickForward:(id)sender
{
    [[UMComForwardAction action] performActionAfterLogin:self.feed viewController:[self.tableView viewController] completion:nil];
}

-(void)dissMissEditBackGround
{
    [self.editBackGround setHidden:YES];
}

-(IBAction)onClickUserProfile:(id)sender
{
    UMComUser *feedCreator = self.feed.creator;
    [self turnToUserCenterWithUser:feedCreator];
}


- (IBAction)onClickSpam:(id)sender
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if (![self.feed.creator.uid isEqualToString:[UMComSession sharedInstance].loginUser.uid]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"spam", @"举报") message:UMComLocalizedString(@"spam_message", @"确定举报该消息？") delegate:self cancelButtonTitle:UMComLocalizedString(@"cancel", @"取消") otherButtonTitles:UMComLocalizedString(@"ok",@"确定"), nil];
        alertView.tag = kTagSpam;
        [alertView show];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"delete", @"删除") message:UMComLocalizedString(@"delete_message", @"确定删除该消息？") delegate:self cancelButtonTitle:UMComLocalizedString(@"cancel", @"取消") otherButtonTitles:UMComLocalizedString(@"ok",@"确定"), nil];
        alertView.tag = kTagDelete;
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kTagSpam && buttonIndex == 1) {
                [[UMComSpamAction action] performActionAfterLogin:self.feed.feedID viewController:self.tableView.viewController completion:^(NSArray *data, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [UMComShowToast spamSuccess:error];
        }];
    }
    if (alertView.tag == kTagDelete && buttonIndex == 1) {
        [[UMComDeleteFeedAction action] performActionAfterLogin:self.feed.feedID viewController:self.tableView.viewController completion:^(NSArray *data, NSError *error) {
            [UMComShowToast deleteSuccess:error];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if (self.feed) {
                
                self.feed.status = @(FeedStatusDeleted);
                [[UMComCoreData sharedInstance].incrementalStore updateObject:self.feed objectId:self.feed.feedID handler:^(NSManagedObject *object,NSManagedObjectContext *managedContext) {
                    UMComFeed *backingFeedObject = (UMComFeed *)object;
                    backingFeedObject.status = @(FeedStatusDeleted);
                    [managedContext save:nil];
                }];
                if (self.indexPath.row < self.tableView.resultArray.count) {
                    [self.tableView.resultArray removeObject:[self.tableView.resultArray objectAtIndex:self.indexPath.row]];
                }
                [self.tableView refreshFeedsData];
                if (self.tableView.deletedFeedSucceedAction) {
                    self.tableView.deletedFeedSucceedAction();
                }
            }
        }];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark UITableViewDataSources
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BOOL isShowAllComment = [(UMComFeedsTableView *)self.tableView isShowAllComment:(int)self.indexPath.row];
    
    if (!isShowAllComment && self.feed.comments.count >= ShowCommentsNum && self.feed.comment_navigator ) {
        self.reloadComments = [[self.feed.comments array] subarrayWithRange:NSMakeRange(0,ShowCommentsNum)];
        return self.reloadComments.count + 1;

    } else {
        self.reloadComments = self.feed.comments.array;
        return self.reloadComments.count;

    }
}

- (void)onClickGetMore:(id)sender
{
    [self showMoreComments];
}

- (void)showMoreComments
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[UMComMoreCommentsAction action] performActionAfterLogin:self.feed viewController:(UIViewController *)self.tableView.viewController completion:^(NSArray *data, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (error) {
            [UMComShowToast showMoreCommentFail:error];
            return ;
        }
        [(UMComFeedsTableView *)self.tableView setShowAllComment:(int)self.indexPath.row selectedCell:self];
        [(UMComFeedsTableView *)self.tableView reloadRowAtIndex:self.indexPath];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.reloadComments.count) {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, cell.contentView.frame.size.height/2)];
        label.center = CGPointMake(tableView.frame.size.width/2, label.frame.size.height/4);
        label.text = @"...";
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label];
        cell.backgroundColor = self.fakeOriginTextView.backgroundColor;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickGetMore:)];
        [cell.contentView addGestureRecognizer:tap];
        return cell;
    }
    static NSString *cellID = @"FeedsCommentTableViewCell";

    UMComFeedsCommentTableViewCell *cell = (UMComFeedsCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    __block UMComComment *comment = (UMComComment *)[self.reloadComments objectAtIndex:indexPath.row];
    
    cell.textView.pointOffset = CGPointMake(0, ComTextViewHeightOffset);
    UMComMutiStyleTextView *commentStyleView = nil;
    if (indexPath.row < self.feedStyle.commentStyleView.count) {
        commentStyleView = [self.feedStyle.commentStyleView objectAtIndex:indexPath.row];
    }else{
        commentStyleView = [[self class] commentHeight:comment viewWidth:self.commentTableView.frame.size.width - CommentTableViewDeltaWidth];
    }

    cell.textView.frame = CGRectMake(cell.textView.frame.origin.x,0,self.commentTableView.frame.size.width - CommentTableViewDeltaWidth, commentStyleView.totalHeight+ComTextViewHeightOffset/2);
    [cell.textView setMutiStyleTextViewProperty:commentStyleView];

    cell.textView.clickOnlinkText = ^(UMComMutiTextRun *run){
        if ([run isKindOfClass:[UMComMutiTextRunClickUser class]]) {
            UMComMutiTextRunClickUser *userRun = (UMComMutiTextRunClickUser *)run;
            [self turnToUserCenterWithUser:userRun.user];
        }else if ([run isKindOfClass:[UMComMutiTextRunComment class]]){
            UMComMutiTextRunComment *commentRun = (UMComMutiTextRunComment *)run;
            [[UMComReplyAction action] performActionAfterLogin:nil viewController:self.tableView.viewController completion:^(NSArray *data, NSError *error) {
                [(UMComFeedsTableView *)self.tableView presentEditView:commentRun.comment selectedCell:self];
            }];
        }
    };
    
    NSDictionary *iconUrl = [[(UMComComment *)[self.reloadComments objectAtIndex:indexPath.row] creator] icon_url];
    NSString *iconString = [iconUrl objectForKey:@"240"];
    
    UIImage *placeHolderImage = [UMComImageView placeHolderImageGender:[comment.creator.gender integerValue]];
    [cell.profileImageView setImageURL:iconString placeHolderImage:placeHolderImage];
    
    cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width/2;
    
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 20;
    if (indexPath.row < self.commentCellHeightArr.count) {
         height = [[self.commentCellHeightArr objectAtIndex:indexPath.row] floatValue];
    }
    return height;
}



+ (NSArray *)commentCellHeightArrWithComments:(NSArray *)reloadComments
                               withFrameWidth:(CGFloat)width
                             isShowAllComment:(BOOL)isShowAllComment
                                         feed:(UMComFeed *)feed
                                    feedStyle:(UMComFeedStyle *)feedStyle
{
    NSMutableArray *heightArr = [NSMutableArray array];
    for (UMComComment *comment in reloadComments) {
        UMComMutiStyleTextView *commentStyleView = [[self class] commentHeight:comment viewWidth:width];
        float height = commentStyleView.totalHeight;
        [heightArr addObject:[NSNumber numberWithFloat:height]];
        [feedStyle.commentStyleView addObject:commentStyleView];
    }
    if (!isShowAllComment && feed.comments.count >= ShowCommentsNum && feed.comment_navigator) {
        [heightArr addObject:@20];
    }
    return heightArr;
}


+ (UMComMutiStyleTextView *)commentHeight:(UMComComment *)comment viewWidth:(CGFloat)viewWidth
{
    NSString *commentUserName = @"";
    if (comment.creator.name) {
        commentUserName = comment.creator.name;
    }
    NSString *commentReplyName = @"";
    if (comment.reply_user.name) {
        commentReplyName = comment.reply_user.name;
    }
    NSMutableArray *clikDicts = [NSMutableArray arrayWithCapacity:1];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:comment.creator forKey:NSStringFromRange(NSMakeRange(0, commentUserName.length))];
    [clikDicts addObject:dict];
    NSMutableString * replayStr = [NSMutableString stringWithString:commentUserName];
    if (comment.reply_user) {
        [replayStr appendString:@" 回复 "];
        NSDictionary *dict1 = [NSDictionary dictionaryWithObject:comment.reply_user forKey:NSStringFromRange(NSMakeRange(replayStr.length, commentReplyName.length))];
        [clikDicts addObject:dict1];
        [replayStr appendString:commentReplyName];
    }
    if (comment.content) {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:comment forKey:NSStringFromRange(NSMakeRange(replayStr.length, comment.content.length))];
        [clikDicts addObject:dict];
        [replayStr appendFormat:@"：%@",comment.content];
    }

    UMComMutiStyleTextView *commentStyleView = [UMComMutiStyleTextView rectDictionaryWithSize:CGSizeMake(viewWidth, MAXFLOAT) font:CommentFont attString:replayStr lineSpace:CommentViewLineSpace runType:UMComMutiTextRunCommentType clickArray:clikDicts];
    commentStyleView.totalHeight = commentStyleView.totalHeight + ComTextViewHeightOffset/2;
    return commentStyleView;
}


@end
