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

static UMComFeedsTableViewCell *Cell;

@interface UMComFeedsTableViewCell ()<UMImageViewDelegate,UIAlertViewDelegate>

@property (nonatomic, weak) UMComFeedsTableView *tableView;
@property (nonatomic, strong) UITextView *attributedTextView;
@property (nonatomic, strong) UITextView *originTextView;
@property (nonatomic, strong) NSMutableAttributedString * attributedText;
@property (nonatomic, strong) NSMutableParagraphStyle * paragraphStyle;
@property (nonatomic, strong) NSMutableParagraphStyle *likeParagraphStyle;

@property (nonatomic, strong) NSArray *commentContents;

@property (nonatomic, strong) UIView *originBackground;
@property (nonatomic, strong) UMComLike *like;

@property (nonatomic, assign) CGFloat commentTextViewWidth;
@property (nonatomic, strong) NSArray *commentCellHeightArr;

@property (nonatomic, strong) UILabel *likeNumLabel;

@end


static NSMutableParagraphStyle *style;
static NSDictionary *commentStyleDictionary;
static NSMutableParagraphStyle *likeStyle;
static NSDictionary *likeStyleDictionary;
static NSDictionary *textStyleDictionary;



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

+(void)initialize {
    if(!Cell){
        
        Cell = [[[NSBundle mainBundle] loadNibNamed:@"UMComFeedsTableViewCell" owner:nil options:nil] objectAtIndex:0];
        likeStyle = [[NSMutableParagraphStyle alloc] init];
        likeStyle.lineSpacing = 8;
        style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = TextViewLineSpace;
        textStyleDictionary = @{NSFontAttributeName:UMComFontNotoSansLightWithSafeSize(15),NSParagraphStyleAttributeName:style};
        commentStyleDictionary = @{NSFontAttributeName:UMComFontNotoSansLightWithSafeSize(13),NSParagraphStyleAttributeName:likeStyle};
        likeStyleDictionary = @{NSFontAttributeName:UMComFontNotoSansLightWithSafeSize(15),NSParagraphStyleAttributeName:likeStyle};
        if (!Cell.commentCellHeightArr) {
            Cell.commentCellHeightArr = [NSArray array];
        }
        Cell.commentTextViewWidth = Cell.commentTableView.frame.size.width - CommentTableViewDeltaWidth;
    }
}

+ (UMComFeedsTableViewCell *)cell
{
    return Cell;
}

- (void)removeSubViews:(UIView *)superView
{
    for (UIView * subView in superView.subviews) {
        [subView removeFromSuperview];
    }
}

-(void)awakeFromNib
{
    self.userNameLabel.font = UMComFontNotoSansDemiWithSafeSize(17);
    self.userNameLabel.adjustsFontSizeToFitWidth = YES;
    self.fakeTextView.font = UMComFontNotoSansLightWithSafeSize(15);
    self.fakeOriginTextView.font = UMComFontNotoSansLightWithSafeSize(15);
    self.dateLabel.font = UMComFontNotoSansDemiWithSafeSize(12);
    self.paragraphStyle = style;
    self.likeParagraphStyle  = likeStyle;
    [self.commentTableView registerNib:[UINib nibWithNibName:@"UMComFeedsCommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"FeedsCommentTableViewCell"];
    UITapGestureRecognizer *tapGestureRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickUserProfile:)];
    [self.avatarImageView addGestureRecognizer:tapGestureRecog];
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2;
    self.avatarImageView.layer.masksToBounds = YES;
    
    UIImageView *likeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"like+x"]];
    likeImageView.frame = CGRectMake(0, 0, likeImageView.frame.size.width, likeImageView.frame.size.height);
    likeImageView.center = CGPointMake((self.likeImageBgVIew.frame.size.width - self.likeListTextView.frame.size.width)/2-2, likeImageView.frame.size.width/2+4);
    [self.likeImageBgVIew addSubview:likeImageView];
    
    self.likeNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(190, 0, 50, 20)];
    self.likeNumLabel.backgroundColor = [UIColor clearColor];
    self.likeNumLabel.font = UMComFontNotoSansLightWithSafeSize(14);
    self.likeNumLabel.textColor = [UMComTools colorWithHexString:@"#8e8e93"];
    self.likeNumLabel.textAlignment = NSTextAlignmentCenter;
    [self.likeListTextView addSubview:self.likeNumLabel];
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

-(void)reload:(UMComFeed *)feed tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    self.feed = feed;
    self.userNameLabel.text = feed.creator.name;
    self.indexPath = indexPath;
    self.tableView = (UMComFeedsTableView *)tableView;
    Cell.tableView = (UMComFeedsTableView *)tableView;
    [self.dateLabel setText:createTimeString(feed.create_time)];
    
    [self.avatarImageView setIsAutoStart:NO];
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2;
    self.avatarImageView.clipsToBounds = YES;
    if ([feed.creator.gender intValue] == 0) {
        [self.avatarImageView setPlaceholderImage:[UIImage imageNamed:@"female"]];
    } else{
        [self.avatarImageView setPlaceholderImage:[UIImage imageNamed:@"male"]];
    }
    NSDictionary * iconUrl = !feed.creator.isFault ? feed.creator.icon_url : nil;
    NSString *iconString = [iconUrl valueForKey:@"240"];
    NSURL *iconURL = nil;
    if (iconString && ![iconString isKindOfClass:[NSNull class]]) {
        iconURL = [NSURL URLWithString:iconString];
        [self.avatarImageView setImageURL:iconURL ];
        [self.avatarImageView startImageLoad];
    }
    
    __weak UMComFeedsTableViewCell *weakSelf = self;


    float totalHeight = Cell.userNameLabel.frame.size.height + DeltaHeight;
    //修正字体的行间距
    NSString *feedString = @"";
    if (self.feed.text) {
        feedString = self.feed.text;
    }
    UIFont *feedFont = UMComFontNotoSansLightWithSafeSize(15);
    CGRect feedTextRect = [UMComMutiStyleTextView boundingRectWithSize:CGSizeMake(self.fakeTextView.frame.size.width, MAXFLOAT) font:feedFont string:feedString lineSpace:TextViewLineSpace];
    self.fakeTextView.frame = CGRectMake(Cell.fakeTextView.frame.origin.x, totalHeight , self.fakeTextView.frame.size.width, feedTextRect.size.height);
    self.fakeTextView.font = feedFont;
    self.fakeTextView.lineSpace = TextViewLineSpace;
    NSMutableDictionary *feedClickTextDict = [NSMutableDictionary dictionaryWithCapacity:1];
    if (feed.topics.count > 0) {
        [feedClickTextDict setObject:feed.topics.array forKey:@"topics"];
    }
    if (feed.related_user.count > 0) {
        [feedClickTextDict setObject:feed.related_user.array forKey:@"related_user"];
    }
    [self.fakeTextView.clikTextDict addObject:feedClickTextDict];

    self.fakeTextView.runType = UMComMutiTextRunFeedContentType;
    self.fakeTextView.text = feedString;
    self.fakeTextView.backgroundColor = [UIColor clearColor];
    self.fakeTextView.clickOnlinkText = ^(UMComMutiTextRun *run){
        [weakSelf clickInFeedTextWithObject:run];
    };
    
    totalHeight += self.fakeTextView.frame.size.height;
    NSMutableString *oringFeedString = [NSMutableString stringWithString:@""];
    
    float totalBgHeight = 0;
    if (self.feed.origin_feed && !self.feed.origin_feed.isFault) {
        NSString *originUserName = !feed.origin_feed.creator.isFault ? feed.origin_feed.creator.name : @"";
        if ([self.feed.origin_feed.status intValue] >= FeedStatusDeleted) {
            self.feed.origin_feed.text = UMComLocalizedString(@"Delete Content", @"该内容已被删除");
            self.feed.origin_feed.images = [NSArray array];
        }
        [oringFeedString appendFormat:OriginUserNameString,originUserName,self.feed.origin_feed.text];
        self.fakeOriginTextView.pointOffset = CGPointMake(0, OriginFeedHeightOffset);
        CGRect originFeedRect = [UMComMutiStyleTextView boundingRectWithSize:CGSizeMake(self.fakeOriginTextView.frame.size.width, MAXFLOAT) font:feedFont string:oringFeedString lineSpace:TextViewLineSpace];
        self.fakeOriginTextView.frame = CGRectMake(self.fakeOriginTextView.frame.origin.x, OriginFeedOriginY, self.fakeOriginTextView.frame.size.width, originFeedRect.size.height + OriginFeedHeightOffset/2+4);
        self.fakeOriginTextView.font = feedFont;
        self.fakeOriginTextView.lineSpace = TextViewLineSpace;
        self.fakeOriginTextView.runType = UMComMutiTextRunFeedContentType;
        self.fakeOriginTextView.text = oringFeedString;
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
        [self.fakeOriginTextView.clikTextDict addObject:originFeedClickTextDict];
        
        self.fakeOriginTextView.clickOnlinkText = ^(UMComMutiTextRun *run){
            [weakSelf clickInFeedTextWithObject:run];
        };
        totalBgHeight += self.fakeOriginTextView.frame.size.height + OriginFeedOriginY;
        self.fakeOriginTextView.hidden = NO;
        UIImage *resizableImage = [[UIImage imageNamed:@"origin_image_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 50, 0, 0)];
        self.imagesBackGroundView.image = resizableImage;
    } else {
        self.imagesBackGroundView.image = nil;
        self.fakeOriginTextView.hidden = YES;
    }
    
    if (self.feed.location == nil) {
        self.locationBackground.hidden = YES;
    } else {
        [self.locationLabel setText:self.feed.location];
        self.locationBackground.hidden = NO;
        self.locationBackground.frame = CGRectMake(self.locationBackground.frame.origin.x, totalBgHeight, self.locationBackground.frame.size.width, self.locationBackground.frame.size.height);
        totalBgHeight += self.locationBackground.frame.size.height;
    }
    
    NSDictionary *imagesArray =  self.feed.images;
 
    if (imagesArray.count == 0 && self.feed.origin_feed && !self.feed.origin_feed.isFault) {
        imagesArray = self.feed.origin_feed.images;
    }
    NSMutableArray *showImageArray = [[NSMutableArray alloc] init];
    for (NSString *imageDictionary in imagesArray) {
        [showImageArray addObject:@[[imageDictionary valueForKey:@"360"],[imageDictionary valueForKey:@"origin"]]];
    }
    if ([imagesArray count] == 0) {
        self.gridView.hidden = YES;
    } else {
        self.gridView.hidden = NO;
        [self.gridView setImages:showImageArray placeholder:[UIImage imageNamed:@"image-placeholder"] cellPad:ImageSpace];
       
        if (self.feed.origin_feed  && !self.feed.origin_feed.isFault) {
            self.gridView.frame = CGRectMake(2, totalBgHeight, self.gridView.frame.size.width, ceil((float)imagesArray.count/3) *  (Cell.gridView.frame.size.height+ImageSpace) + ImageSpace);
        }else{
            self.gridView.frame = CGRectMake(0,  totalBgHeight, self.gridView.frame.size.width, ceil((float)imagesArray.count/3) *  (Cell.gridView.frame.size.height+ImageSpace) + ImageSpace);
        }
        [self.gridView setPresentFatherViewController:self.tableView.feedTableViewController];
        totalBgHeight += self.gridView.frame.size.height+2;
        [self.gridView startDownload];
    }

    self.imagesBackGroundView.frame = CGRectMake(Cell.imagesBackGroundView.frame.origin.x, totalHeight, self.imagesBackGroundView.frame.size.width, totalBgHeight);
    
    totalHeight += self.imagesBackGroundView.frame.size.height;
    
    self.showEditBackGround.center = CGPointMake(self.showEditBackGround.center.x, totalHeight+self.showEditBackGround.frame.size.height/2);
    self.editBackGround.center = CGPointMake(self.editBackGround.center.x,  self.showEditBackGround.center.y);
    self.dateLabel.center = CGPointMake(self.dateLabel.center.x, totalHeight+self.dateLabel.frame.size.height/2 + DeltaHeight);
    totalHeight += self.dateLabel.frame.size.height + DeltaHeight;
    
    NSInteger likeNum = self.feed.likes.count < ShowLikeNum ? self.feed.likes.count : ShowLikeNum;
    NSMutableString *likeString = [NSMutableString stringWithString:@""];
    NSMutableArray *clikDicts = [NSMutableArray arrayWithCapacity:1];
    NSString *loginUid = [UMComSession sharedInstance].uid;
    self.like = nil;
    for (int i = 0; i < likeNum; i++) {
        UMComLike *like = [feed.likes objectAtIndex:i];
        UMComUser *creator = like.creator;     //[[feed.likes objectAtIndex:i] creator];
        NSString * likeNameString = [creator name];
        NSString * uid = creator.uid;
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
        if ([uid isEqualToString:loginUid]) {
            self.like = [feed.likes objectAtIndex:i];
        }
    }
    [likeString appendString:@" "];

    self.likeListTextView.clikTextDict = clikDicts;
    self.likeListTextView.runType = UMComMutiTextRunLikeType;
    self.likeListTextView.clickOnlinkText = ^(UMComMutiTextRun  *run){
        if ([run isKindOfClass:[UMComMutiTextRunClickUser class]]) {
            UMComMutiTextRunClickUser *userRun = (UMComMutiTextRunClickUser *)run;
            [weakSelf turnToUserCenterWithUser:userRun.user];
        }
    };
    if (self.like) {
        [self.likeButton setImage:[UIImage imageNamed:@"like+x"] forState:UIControlStateNormal];
    } else {
        [self.likeButton setImage:[UIImage imageNamed:@"likex"] forState:UIControlStateNormal];
    }
    if (likeNum == 0) {
        self.likeListTextView.hidden = YES;
        self.likeImageBgVIew.hidden = YES;
        self.likeNumLabel.hidden =  YES;

        totalHeight += DeltaHeight;
    } else{
        self.likeListTextView.hidden = NO;
        self.likeNumLabel.hidden = NO;
        self.likeListTextView.pointOffset = CGPointMake(0, LikeTextViewHeightOffset);
        NSDictionary *likeRectDict = [UMComMutiStyleTextView rectWithSize:CGSizeMake(self.likeListTextView.frame.size.width, MAXFLOAT) font:UMComFontNotoSansLightWithSafeSize(14) AttString:likeString lineSpace:LikeViewLineSpace];
        CGRect likeRect = CGRectFromString([likeRectDict valueForKey:@"rect"]);
        int likesNum = (int)feed.likes.count;
        CGFloat likeNumWith = 10;
        CGFloat likeNumHeight = [[likeRectDict valueForKey:@"lineHeight"] floatValue];
        CGFloat likeTextViewHeight = likeRect.size.height;
        if (likesNum >= 10) {
            likeNumWith = 20;
        }
        CGFloat lastLineWith = [[likeRectDict valueForKey:@"lastLineWidth"] floatValue];
        if ((self.likeListTextView.frame.size.width - lastLineWith) < likeNumWith) {
            likeTextViewHeight += likeNumHeight;
        }
        self.likeNumLabel.text = [NSString stringWithFormat:@"%d",likesNum];
        self.likeListTextView.frame = CGRectMake(self.likeListTextView.frame.origin.x, 0, self.likeListTextView.frame.size.width, likeTextViewHeight);
        self.likeNumLabel.frame = CGRectMake(self.likeListTextView.frame.size.width-likeNumWith, likeTextViewHeight-likeNumHeight+1, likeNumWith, likeNumHeight);
        self.likeImageBgVIew.hidden = NO;
        self.likeImageBgVIew.frame = CGRectMake(self.likeImageBgVIew.frame.origin.x, totalHeight+DeltaHeight, self.likeImageBgVIew.frame.size.width, self.likeListTextView.frame.size.height);

        totalHeight += self.likeListTextView.frame.size.height+DeltaHeight;
    }
    self.likeListTextView.font = UMComFontNotoSansLightWithSafeSize(14);
    self.likeListTextView.lineSpace = LikeViewLineSpace;
    self.likeListTextView.text = likeString;
    
    if (self.feed.comments.count > 0 && self.feed.likes.count > 0) {
        if (!self.seperateView) {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(self.likeImageBgVIew.frame.origin.x, self.likeImageBgVIew.frame.origin.y + self.likeListTextView.frame.size.height, self.likeImageBgVIew.frame.size.width, 0.5)];
            view.backgroundColor = [UMComTools colorWithHexString:@"#e7e7e7"];
            self.seperateView = view;
            [self.contentView addSubview:self.seperateView];
        } else {
            self.seperateView.frame = CGRectMake(self.likeImageBgVIew.frame.origin.x, self.likeImageBgVIew.frame.origin.y + self.likeImageBgVIew.frame.size.height,self.likeImageBgVIew.frame.size.width, 0.5);
        }
        self.seperateView.hidden = NO;
    } else {
        self.seperateView.hidden = YES;
    }
    
    if (self.feed.comments.count == 0) {
        self.commentTableView.hidden = YES;
    } else {

        BOOL isShowAllComment = [(UMComFeedsTableView *)self.tableView isShowAllComment:(int)self.indexPath.row];
        if (!isShowAllComment && self.feed.comments.count >= ShowCommentsNum && self.feed.comment_navigator) {
            self.reloadComments = [[self.feed.comments array] subarrayWithRange:NSMakeRange(0,ShowCommentsNum)];
        } else{
            self.reloadComments = self.feed.comments.array;
        }
        self.commentCellHeightArr = [UMComFeedsTableViewCell commentCellHeightArrWithComments:self.reloadComments withFrameWidth:self.commentTableView.frame.size.width - CommentTableViewDeltaWidth isShowAllComment:isShowAllComment feed:feed];
        [self.commentTableView reloadData];
        self.commentTableView.hidden = NO;
        self.commentTableView.frame = CGRectMake(self.commentTableView.frame.origin.x, totalHeight, self.commentTableView.frame.size.width, self.commentTableView.contentSize.height);
        totalHeight += self.commentTableView.contentSize.height;
    }
    
    [self.acounTypeLabel removeFromSuperview];
    [self.contentView addSubview:self.acounTypeLabel];
    self.acounTypeLabel.font = [UIFont systemFontOfSize:8.0f];
    if ([feed.type integerValue] == 1) {
        self.acounTypeLabel.hidden = NO;
        self.acounTypeLabel.text = @"公告";
    }else{
        self.acounTypeLabel.hidden = YES;
        self.acounTypeLabel.text = @"";
    }
}

+ (float)getCellHeightWithFeed:(UMComFeed *)feed isShowComment:(BOOL)isShowComment tableViewWidth:(float)viewWidth
{
    float totalHeight = Cell.userNameLabel.frame.size.height + DeltaHeight;
    NSString * feedSting = @"";
    if (feed.text) {
        feedSting = feed.text;
        CGRect fitRect = [UMComMutiStyleTextView boundingRectWithSize:CGSizeMake(viewWidth - TableViewDeltaWidth, MAXFLOAT) font:UMComFontNotoSansLightWithSafeSize(15) string:feedSting lineSpace:TextViewLineSpace];
        
        totalHeight = fitRect.size.height;
    }

    UMComFeed *origin_feed = nil;
    if (feed.origin_feed && !feed.origin_feed.isDeleted && !feed.origin_feed.isFault) {
        origin_feed = feed.origin_feed;
      
    }
    if (origin_feed) {
        
        if ([origin_feed.status intValue] >= FeedStatusDeleted) {
            origin_feed.text = UMComLocalizedString(@"Delete Content", @"该内容已被删除");
            origin_feed.images = [NSArray array];
        }
        
        UMComUser * origin_user = feed.origin_feed.creator;
        NSMutableString * originText = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:OriginUserNameString,origin_user.name,feed.origin_feed.text]];
        CGRect originTextRect = [UMComMutiStyleTextView boundingRectWithSize:CGSizeMake(viewWidth-TableViewDeltaWidth-FeedAndOriginFeedDeltaWidth, MAXFLOAT) font:UMComFontNotoSansLightWithSafeSize(15) string:originText lineSpace:TextViewLineSpace];
        totalHeight += originTextRect.size.height + OriginFeedHeightOffset/2+4 + OriginFeedOriginY;
    }
    NSArray *images = feed.images;
    if (images.count == 0 && origin_feed) {
        images = origin_feed.images;
    }
    if(images.count > 0) {
        totalHeight += ceil((float)(images.count)/3)* (Cell.gridView.frame.size.height + ImageSpace)+ImageSpace;
    }
    
    if (feed.location) {
        totalHeight += Cell.locationBackground.frame.size.height;
    }
    if(feed.likes.count > 0) {
        NSMutableString * likeString = [[NSMutableString alloc] initWithString:@""];
        NSString * seperateString = @"、";
        for (UMComLike *like in feed.likes) {
            [likeString appendString:like.creator.name];
            [likeString appendString:seperateString];
        }
        
        [likeString appendString:@" "];
        NSDictionary *likeRectDict = [UMComMutiStyleTextView rectWithSize:CGSizeMake(viewWidth-TableViewDeltaWidth - LikeViewDeltaWidth, MAXFLOAT) font:UMComFontNotoSansLightWithSafeSize(14) AttString:likeString lineSpace:LikeViewLineSpace];
        CGRect likeRect = CGRectFromString([likeRectDict valueForKey:@"rect"]);
        int likesNum = (int)feed.likes.count;
        CGFloat likeNumWith = 10;
        CGFloat likeNumHeight = [[likeRectDict valueForKey:@"lineHeight"] floatValue];
        CGFloat likeTextViewHeight = likeRect.size.height;
        if (likesNum >= 10) {
            likeNumWith = 20;
        }
        CGFloat shortestWith = [[likeRectDict valueForKey:@"lastLineWidth"] floatValue];
        if ((viewWidth - TableViewDeltaWidth - shortestWith) < likeNumWith) {
            likeTextViewHeight += likeNumHeight;
        }

        CGFloat height = likeTextViewHeight;
        totalHeight += height+DeltaHeight;
    }
    
    if (feed.comments.count > 0) {
        NSArray *reloadComments = nil;
        if (!isShowComment && feed.comments.count >= ShowCommentsNum && feed.comment_navigator ) {
            reloadComments = [[feed.comments array] subarrayWithRange:NSMakeRange(0,ShowCommentsNum)];
        } else {
            reloadComments = feed.comments.array;
        }
        NSArray *commentCellHeightArr = [UMComFeedsTableViewCell commentCellHeightArrWithComments:reloadComments withFrameWidth:viewWidth - TableViewDeltaWidth - CommentTableViewDeltaWidth isShowAllComment:isShowComment feed:feed];
        for (NSNumber *height in commentCellHeightArr) {
            totalHeight += [height floatValue];
        }
        if (feed.likes.count == 0) {
            totalHeight += DeltaHeight;
        }
    }
    totalHeight += 80;
    return totalHeight;
}



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
    if (self.like) {
        [[UMComDisLikeAction action] performActionAfterLogin:@{@"likeId":self.like.id,@"feedId":self.feed.feedID} viewController:self.tableView.viewController completion:^(NSArray *data, NSError *error) {
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
            [UMComShowToast spamSuccess:error];
        }];
    }
    if (alertView.tag == kTagDelete && buttonIndex == 1) {
        [[UMComDeleteFeedAction action] performActionAfterLogin:self.feed.feedID viewController:self.tableView.viewController completion:^(NSArray *data, NSError *error) {
            [UMComShowToast deleteSuccess:error];
            if (_deleteFeedSucceedAction) {
                _deleteFeedSucceedAction(self.feed);
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
        [(UMComFeedsTableView *)self.tableView setShowAllComment:(int)self.indexPath.row];
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
        cell.backgroundColor = Cell.originTextView.backgroundColor;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickGetMore:)];
        [cell.contentView addGestureRecognizer:tap];
        return cell;
    }
    static NSString *cellID = @"FeedsCommentTableViewCell";

    UMComFeedsCommentTableViewCell *cell = (UMComFeedsCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *iconUrl = [[(UMComComment *)[self.reloadComments objectAtIndex:indexPath.row] creator] icon_url];
    NSString *iconString = [iconUrl valueForKey:@"240"];
    NSURL *iconURL = nil;
    if (iconString && ![iconString isKindOfClass:[NSNull class]]) {
        iconURL = [NSURL URLWithString:iconString];
    }
    __block UMComComment *comment = (UMComComment *)[self.reloadComments objectAtIndex:indexPath.row];
    
    NSString *commentUserName = @"";
    if (comment.creator.name) {
        commentUserName = comment.creator.name;
    }
    NSString *commentReplyName = @"";
    if (comment.reply_user.name) {
        commentReplyName = comment.reply_user.name;
    }
    NSMutableArray *clikDicts = [NSMutableArray arrayWithCapacity:1];
    UIFont *font = UMComFontNotoSansLightWithSafeSize(13);
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
    CGFloat height = 0;
    if (indexPath.row < self.commentCellHeightArr.count) {
        height = [[self.commentCellHeightArr objectAtIndex:indexPath.row] floatValue];
    }
    
    cell.textView.runType = UMComMutiTextRunCommentType;
    cell.textView.clikTextDict = clikDicts;
    cell.textView.pointOffset = CGPointMake(0, ComTextViewHeightOffset);
    CGRect rect = [UMComMutiStyleTextView boundingRectWithSize:CGSizeMake(self.commentTableView.frame.size.width - CommentTableViewDeltaWidth,MAXFLOAT) font:font string:replayStr lineSpace:CommentViewLineSpace];
    cell.textView.frame = CGRectMake(cell.textView.frame.origin.x,0,self.commentTableView.frame.size.width - CommentTableViewDeltaWidth, rect.size.height+ComTextViewHeightOffset/2);
    cell.textView.font = font;
    cell.textView.lineSpace = CommentViewLineSpace;
    cell.textView.text = replayStr;
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

    if ([comment.creator.gender intValue] == 0) {
        [cell.profileImageView setPlaceholderImage:[UIImage imageNamed:@"female"]];
    } else{
        [cell.profileImageView setPlaceholderImage:[UIImage imageNamed:@"male"]];
    }

    [cell.profileImageView setImageURL:iconURL];
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



+ (NSArray *)commentCellHeightArrWithComments:(NSArray *)reloadComments withFrameWidth:(CGFloat)width isShowAllComment:(BOOL)isShowAllComment feed:(UMComFeed *)feed
{
    NSMutableArray *heightArr = [NSMutableArray array];
    for (UMComComment *comment in reloadComments) {
        NSMutableString * replayStr = [NSMutableString stringWithString:@""];
        NSString *commentUserName = @"";
        if (comment.creator.name) {
            commentUserName = comment.creator.name;
        }
        NSString *commentReplyName = @"";
        if (comment.reply_user.name) {
            commentReplyName = comment.reply_user.name;
        }
        UIFont *font = UMComFontNotoSansLightWithSafeSize(13);
        if (comment.reply_user) {
            [replayStr appendFormat:@"%@ 回复 %@",commentUserName,commentReplyName];
           
        } else {
            [replayStr appendString:commentUserName];
        }
        if (comment.content) {
            [replayStr appendFormat:@"：%@",comment.content];
        }
        CGRect rect = [UMComMutiStyleTextView boundingRectWithSize:CGSizeMake(width, MAXFLOAT) font:font string:replayStr lineSpace:CommentViewLineSpace];
        float height = rect.size.height + ComTextViewHeightOffset/2;
        [heightArr addObject:[NSNumber numberWithFloat:height]];
    }
    if (!isShowAllComment && feed.comments.count >= ShowCommentsNum && feed.comment_navigator) {
        [heightArr addObject:@20];
    }
    return heightArr;
}



@end
