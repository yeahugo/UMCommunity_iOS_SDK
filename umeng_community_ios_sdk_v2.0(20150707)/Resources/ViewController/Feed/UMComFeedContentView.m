//
//  UMComFeedDetailView.m
//  UMCommunity
//
//  Created by umeng on 15/5/20.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComFeedContentView.h"
#import "UMComUser.h"
#import "UMComTopic.h"
#import "UMComSession.h"
#import "UMComFeed.h"
#import "UMComMutiStyleTextView.h"
#import "UMComImageView.h"
#import "UMComGridView.h"
#import "UMComFeedStyle.h"

@interface UMComFeedContentView ()

@property (nonatomic, strong) UMComFeed *feed;

@property (nonatomic, strong) UMComFeedStyle *feedStyle;

@property (nonatomic, assign) CGFloat subViewWidth;

@end

@implementation UMComFeedContentView

- (void)awakeFromNib
{
    self.portrait = [[[UMComImageView imageViewClassName] alloc]initWithFrame:CGRectMake(15, 10, 35, 35)];
    self.portrait.userInteractionEnabled = YES;
    [self addSubview:self.portrait];
    
    self.dateLabel.textColor = [UMComTools colorWithHexString:FontColorGray];
    
    UITapGestureRecognizer *tapPortrait = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapPortrait)];
    [self.portrait addGestureRecognizer:tapPortrait];
    
    UITapGestureRecognizer *tapOnGridView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnImageGridView)];
    [self.iamgeGridView addGestureRecognizer:tapOnGridView];
    [self.originFeedBackgroundView addGestureRecognizer:tapOnGridView];
}



- (void)reloadDetaiViewWithFeedStyle:(UMComFeedStyle *)feedStyle viewWidth:(CGFloat)viewWidth
{
    
    self.feed = feedStyle.feed;
    UMComFeed *feed = feedStyle.feed;
    self.feedStyle = feedStyle;
    self.nameLabel.text = feed.creator.name;
    self.subViewWidth = feedStyle.subViewWidth;//viewWidth - feedStyle.subViewDeltalWidth;

    //刷新头像
    [self reloadAvatarImageViewWithFeed:feed];
    
    if ([feed.type intValue] == 1) {
        self.acountType.text = @"公告";
        self.acountType.hidden = NO;
    }else{
        self.acountType.text = @"";
        self.acountType.hidden = YES;
    }
    self.nameLabel.frame = feedStyle.nameLabelFrame;
    float totalHeight = self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height+DeltaHeight;
    //刷新feedTextView
    [self reloadFeedTextViewWithFeed:feed originHeigt:totalHeight];
    
    totalHeight += self.feedStyleView.frame.size.height;
    float totalBgHeight = 0;
    NSString *locationName = nil;
    if (feed.origin_feed) {
        locationName = feed.origin_feed.location;
        //如果是转发，显示originFeedTextView，否则隐藏
        self.originFeedStyleView.hidden = NO;
        [self reloadOriginFeedTextViewWithFeed:feed originHeigt:totalBgHeight];
        totalBgHeight += self.originFeedStyleView.frame.size.height + OriginFeedOriginY;
        UIImage *resizableImage = [[UIImage imageNamed:@"origin_image_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 50, 0, 0)];
        self.originFeedBackgroundView.image = resizableImage;
    } else {
        locationName = feed.location;
        self.originFeedBackgroundView.image = nil;
        self.originFeedStyleView.hidden = YES;
    }
    
    NSDictionary *imagesArray = feedStyle.images;
    CGFloat originX = feedStyle.imageGridViewOriginX;
    //如果存在定位信息则显示否则隐藏
    if (locationName == nil) {
        self.locationBgView.hidden = YES;
    } else {
        totalBgHeight += 3;
        [self.locationLabel setText:locationName];
        self.locationLabel.frame = CGRectMake(self.locationLabel.frame.origin.x, self.locationLabel.frame.origin.y, self.subViewWidth, self.locationLabel.frame.size.height);
        self.locationBgView.hidden = NO;
        
        CGFloat locationBgWidth = self.feedStyle.subViewWidth;
        self.locationBgView.frame = CGRectMake(originX, totalBgHeight, locationBgWidth-2*originX, self.locationBgView.frame.size.height);
        totalBgHeight += self.locationBgView.frame.size.height;
    }
    

    if ([imagesArray count] == 0) {
        self.iamgeGridView.hidden = YES;
    } else {
        //如果有图片则刷新图片
        totalBgHeight += DeltaHeight;
        [self reloadGridViewWithFeed:feed originHeigt:totalBgHeight imagesArr:imagesArray originX:originX];
        totalBgHeight += self.iamgeGridView.frame.size.height;
    }
    
    self.originFeedBackgroundView.frame = CGRectMake(self.feedStyle.subViewOriginX, totalHeight, self.subViewWidth, totalBgHeight);
    totalHeight += self.originFeedBackgroundView.frame.size.height+DeltaHeight;
    [self.dateLabel setText:feedStyle.dateString];
    self.dateLabel.frame = CGRectMake(self.feedStyle.subViewOriginX, totalHeight, self.subViewWidth, self.dateLabel.frame.size.height);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, feedStyle.totalHeight);
}




- (void)reloadAvatarImageViewWithFeed:(UMComFeed *)feed
{
    NSDictionary * iconUrl = feed.creator.icon_url ? feed.creator.icon_url : nil;
    NSString *iconString = [iconUrl objectForKey:@"240"];
    
    UIImage *placeHolderImage = [UMComImageView placeHolderImageGender:[feed.creator.gender integerValue]];
    [self.portrait setImageURL:iconString placeHolderImage:placeHolderImage];
    self.portrait.clipsToBounds = YES;
    self.portrait.layer.cornerRadius = self.portrait.frame.size.width/2;
}

- (void)reloadFeedTextViewWithFeed:(UMComFeed *)feed originHeigt:(CGFloat)originHeigth
{
    self.feedStyleView.frame = CGRectMake(self.feedStyle.subViewOriginX, originHeigth, self.subViewWidth, self.feedStyle.feedStyleView.totalHeight);
    [self.feedStyleView setMutiStyleTextViewProperty:self.feedStyle.feedStyleView];
    self.feedStyleView.runType = UMComMutiTextRunFeedContentType;
    __weak UMComFeedContentView *weakSelf = self;
    self.feedStyleView.clickOnlinkText = ^(UMComMutiStyleTextView *styleView,UMComMutiTextRun *run){
        [weakSelf clickInTextView:weakSelf.feedStyleView mutiTextRun:run];
    };
}

- (void)reloadOriginFeedTextViewWithFeed:(UMComFeed *)feed originHeigt:(CGFloat)originHeigth
{
    self.originFeedStyleView.pointOffset = CGPointMake(0, OriginFeedHeightOffset);
    self.originFeedStyleView.frame = CGRectMake(self.originFeedStyleView.frame.origin.x, OriginFeedOriginY, self.subViewWidth-FeedAndOriginFeedDeltaWidth, self.feedStyle.originFeedStyleView.totalHeight);
    [self.originFeedStyleView setMutiStyleTextViewProperty:self.feedStyle.originFeedStyleView];
    self.originFeedStyleView.runType = UMComMutiTextRunFeedContentType;
    __weak UMComFeedContentView *weakSelf = self;
    self.originFeedStyleView.clickOnlinkText = ^(UMComMutiStyleTextView *styleView,UMComMutiTextRun *run){
        [weakSelf clickInTextView:weakSelf.originFeedStyleView mutiTextRun:run];
    };
}

- (void)reloadGridViewWithFeed:(UMComFeed *)feed originHeigt:(CGFloat)originHeigth imagesArr:(NSDictionary *)imagesArray originX:(CGFloat)originX
{
    NSMutableArray *showImageArray = [[NSMutableArray alloc] init];
    for (NSString *imageDictionary in imagesArray) {
        [showImageArray addObject:@[[imageDictionary valueForKey:@"360"],[imageDictionary valueForKey:@"origin"]]];
    }
    self.iamgeGridView.hidden = NO;
    CGFloat imageViewWidth = self.subViewWidth-originX*2;
    self.iamgeGridView.frame = CGRectMake(originX,  originHeigth, imageViewWidth, self.feedStyle.imagesViewHeight);
    [self.iamgeGridView setImages:showImageArray placeholder:[UIImage imageNamed:@"image-placeholder"] cellPad:ImageSpace];
    self.iamgeGridView.frame = CGRectMake(originX,  originHeigth, imageViewWidth, self.feedStyle.imagesViewHeight);
    __weak UMComFeedContentView *weakSelf = self;
    self.iamgeGridView.TapInImage = ^(UMComGridViewerController *viewerController, UIImageView *imageView){
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(customObj:clickOnImageView:complitionBlock:)]) {
            __strong UMComFeedContentView *strongSelf = weakSelf;
            [weakSelf.delegate customObj:strongSelf clickOnImageView:imageView complitionBlock:^(UIViewController *currentViewController) {
                [currentViewController presentViewController:viewerController animated:YES completion:^{
                    [viewerController startDownload];
                }];
            }];
        }
    };
}

/****************************reload subViews views end *****************************/

- (void)didTapPortrait
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnUser:)]) {
        [self.delegate customObj:self clickOnUser:self.feed.creator];
    }
}
- (void)clickInTextView:(UMComMutiStyleTextView *)styleView mutiTextRun:(UMComMutiTextRun *)mutiTextRun
{
    if ([mutiTextRun isKindOfClass:[UMComMutiTextRunClickUser class]]) {
        UMComMutiTextRunClickUser *userRun = (UMComMutiTextRunClickUser *)mutiTextRun;
        [self clickInUserWithUserNameString:userRun.text];
    }else if ([mutiTextRun isKindOfClass:[UMComMutiTextRunTopic class]])
    {
        UMComMutiTextRunTopic *topicRun = (UMComMutiTextRunTopic *)mutiTextRun;
        [self clickInTopicWithTopicNameString:topicRun.text];
    }else{
        if (styleView == self.feedStyleView) {
            [self goToFeedDetailView];
        }else if(styleView == self.originFeedStyleView){
            [self goToForwardDetailView];
        }

    }
}

- (void)goToForwardDetailView
{
    if (self.feed.origin_feed.isDeleted || [self.feed.origin_feed.status intValue] >= FeedStatusDeleted) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnOriginFeedText:)]) {
        [self.delegate customObj:self clickOnOriginFeedText:self.feed.origin_feed];
    }
}

- (void)goToFeedDetailView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnFeedText:)]) {
        [self.delegate customObj:self clickOnFeedText:self.feed];
    }
}
- (void)tapOnImageGridView
{
    if (self.feed.origin_feed) {
        [self goToForwardDetailView];
    }else{
        [self goToFeedDetailView];
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
    for (UMComTopic * topic in self.feed.topics) {
        if ([topicName isEqualToString:topic.name]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnTopic:)]) {
                [self.delegate customObj:self clickOnTopic:topic];
            }
            break;
        }
    }
}

- (void)turnToUserCenterWithUser:(UMComUser *)user
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnUser:)]) {
        [self.delegate customObj:self clickOnUser:user];
    }
}

- (IBAction)onClickOnShareButton:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnShare:)]) {
        [self.delegate customObj:self clickOnShare:self.feed];
    }
}


-(void)onClickUserProfile:(id)sender
{
    UMComUser *feedCreator = self.feed.creator;
    [self turnToUserCenterWithUser:feedCreator];
}




@end
