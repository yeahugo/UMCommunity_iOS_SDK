//
//  UMComFeedsTableViewCell.m
//  UMCommunity
//
//  Created by Gavin Ye on 8/27/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComFeedsTableViewCell.h"
#import "UMComSession.h"
#import "UMComFeedStyle.h"
#import "UMComClickActionDelegate.h"
#import "UMComTopic.h"
#import "UMComFeed.h"
#import "UMComMutiStyleTextView.h"
#import "UMComImageView.h"
#import "UMComGridView.h"
#import "UMComTools.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComLocationModel.h"

@interface UMComFeedsTableViewCell ()<UMComClickActionDelegate>

@property (nonatomic, assign) CGFloat cellSubviewCommonWidth;

@property (nonatomic, strong) UMComFeed *feed;

@property (nonatomic, strong) UMComFeedStyle *feedStyle;

@property (nonatomic, assign) CGFloat subViewWidth;

@end



@implementation UMComFeedsTableViewCell

-(void)awakeFromNib
{
    UIFont *font = UMComFontNotoSansLightWithSafeSize(10);
    self.likeCountLabel.font = font;
    self.commentCountLabel.font = font;
    self.forwardCountLabel.font = font;
    self.portrait = [[[UMComImageView imageViewClassName] alloc]initWithFrame:CGRectMake(15, 10, 35, 35)];
    self.portrait.userInteractionEnabled = YES;
    [self addSubview:self.portrait];
    
    self.dateLabel.textColor = [UMComTools colorWithHexString:FontColorGray];
    
    UITapGestureRecognizer *tapPortrait = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapPortrait)];
    [self.portrait addGestureRecognizer:tapPortrait];
    
    UITapGestureRecognizer *tapOnGridView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnImageGridView)];
    [self.imageGridView addGestureRecognizer:tapOnGridView];
    [self.originFeedBackgroundView addGestureRecognizer:tapOnGridView];
    
    UITapGestureRecognizer *tapLocationView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClicLocation:)];
    [self.locationBgView addGestureRecognizer:tapLocationView];
    
    self.nameLabel.font = UMComFontNotoSansLightWithSafeSize(17);
    self.locationDistance.font = UMComFontNotoSansLightWithSafeSize(12);
    self.locationLabel.font = UMComFontNotoSansLightWithSafeSize(12);
    self.dateLabel.font = UMComFontNotoSansLightWithSafeSize(10);
    
    UITapGestureRecognizer *tapSelfView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToFeedDetaiView)];
    [self addGestureRecognizer:tapSelfView];
    
    UITapGestureRecognizer *tapLike = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickLike:)];
    [self.likeBgView addGestureRecognizer:tapLike];
    UITapGestureRecognizer *tapForward = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickForward:)];
    [self.forwardBgView addGestureRecognizer:tapForward];
    UITapGestureRecognizer *tapComment = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickComment:)];
    [self.commentBgView addGestureRecognizer:tapComment];
//    [self.feedContentView addSubview:self.bottomMenuBgView];
}

/****************************reload cell views start *****************************/
- (void)reloadFeedWithfeedStyle:(UMComFeedStyle *)feedStyle tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.feed = feedStyle.feed;
    self.indexPath = indexPath;
    self.cellSubviewCommonWidth = feedStyle.subViewWidth;
    [self reloadDetaiViewWithFeedStyle:feedStyle viewWidth:tableView.frame.size.width];
  
    if ([self.feed.liked boolValue]) {
        [self.likeImageView setImage:UMComImageWithImageName(@"um_like+")];
    }else{
        [self.likeImageView setImage:UMComImageWithImageName(@"um_like")];
    }
    [self reloadMenuBgViewWithFeed:self.feed originHeigt:self.dateLabel.frame.origin.y];
    
    if ([self.feed.status intValue] >= FeedStatusDeleted){
        self.bottomMenuBgView.hidden = YES;
    } else {
        self.bottomMenuBgView.hidden = NO;
    }
}


- (void)reloadDetaiViewWithFeedStyle:(UMComFeedStyle *)feedStyle viewWidth:(CGFloat)viewWidth
{
    self.feed = feedStyle.feed;
    self.feedStyle = feedStyle;
    self.subViewWidth = feedStyle.subViewWidth;
    
    UMComFeed *feed = feedStyle.feed;
    self.nameLabel.text = feed.creator.name;
    
    //刷新头像
    [self reloadAvatarImageViewWithFeed:feed];
    
    if (feedStyle.isShowTopIamge) {
        self.topImage.hidden = NO;
    }else{
        self.topImage.hidden = YES;
    }
    if ([feed.type intValue] == 1) {
        if ([feed.is_top boolValue]) {
            self.publicImage.frame = CGRectMake(0, self.topImage.frame.size.height+self.topImage.frame.origin.y, self.publicImage.frame.size.width, self.publicImage.frame.size.height);
        }else{
            self.publicImage.frame = CGRectMake(0, self.topImage.frame.origin.y, self.publicImage.frame.size.width, self.publicImage.frame.size.height);
        }
        self.publicImage.hidden = NO;
    }else{
        self.publicImage.hidden = YES;
    }
    
    if ([feed.has_collected boolValue]) {
        [self.collectionButton setImage:UMComImageWithImageName(@"um_collection+") forState:UIControlStateNormal];
    }else{
        [self.collectionButton setImage:UMComImageWithImageName(@"um_collection") forState:UIControlStateNormal];
    }
    CGFloat nameLableOriginX = feedStyle.subViewOriginX;
    if (feedStyle.feedType == feedDetailType) {
        nameLableOriginX = 56;
    }
    self.nameLabel.frame = CGRectMake(nameLableOriginX, DeltaHeight, feedStyle.nameLabelWidth, self.nameLabel.frame.size.height);
    float totalHeight = self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height+DeltaHeight;
    
    if (feedStyle.feedType == feedFavourateType || feedStyle.feedType == feedDetailType) {
        self.collectionButton.hidden = NO;
    }else{
        self.collectionButton.hidden = YES;
    }
    
    if (feed) {
        //刷新feedTextView
        [self reloadFeedTextViewWithFeed:feed originHeigt:totalHeight];
        totalHeight += self.feedStyleView.frame.size.height;
        self.shareButton.hidden = NO;
    } else {
        self.shareButton.hidden = YES;
    }
    
    float totalBgHeight = 0;
    UMComFeed *originFeed = feedStyle.originFeed;
    if (originFeed) {
        //        locationName = [originFeed.location valueForKey:@"name"];
        //如果是转发，显示originFeedTextView，否则隐藏
        self.originFeedStyleView.hidden = NO;
        [self reloadOriginFeedTextViewWithFeed:feed originHeigt:totalBgHeight];
        totalBgHeight += self.originFeedStyleView.frame.size.height + OriginFeedOriginY;
        UIImage *resizableImage = [UMComImageWithImageName(@"origin_image_bg") resizableImageWithCapInsets:UIEdgeInsetsMake(20, 50, 0, 0)];
        self.originFeedBackgroundView.image = resizableImage;
    } else {
        //        locationName = [feed.location valueForKey:@"name"];
        self.originFeedBackgroundView.image = nil;
        self.originFeedStyleView.hidden = YES;
    }
    
    NSArray *imagesArray = feedStyle.imageModels;
    CGFloat originX = feedStyle.imageGridViewOriginX;
    //如果存在定位信息则显示否则隐藏
    if (feedStyle.locationModel == nil) {
        self.locationBgView.hidden = YES;
    } else {
        totalBgHeight += 3;
        [self.locationLabel setText:feedStyle.locationModel.name];
        self.locationLabel.frame = CGRectMake(self.locationLabel.frame.origin.x, self.locationLabel.frame.origin.y, self.subViewWidth, self.locationLabel.frame.size.height);
        self.locationBgView.hidden = NO;
        self.locationBgView.frame = CGRectMake(originX, totalBgHeight, self.locationBgView.frame.size.width, self.locationBgView.frame.size.height);
        totalBgHeight += self.locationBgView.frame.size.height;
    }
    
    if (feedStyle.feedType == feedDistanceType) {
        if (feed.distance > 0) {
            float showDistance = [feed.distance floatValue];
            self.locationLabel.frame = CGRectMake(self.locationLabel.frame.origin.x, self.locationLabel.frame.origin.y, self.locationBgView.frame.size.width-self.locationDistance.frame.size.width-6, self.locationLabel.frame.size.height);
            self.locationDistance.lineBreakMode = NSLineBreakByTruncatingMiddle;
            [self.locationDistance setText:[NSString stringWithFormat:@"100%dm",(int)showDistance]];
            self.locationDistance.hidden = NO;
        } else {
            self.locationDistance.hidden = YES;
        }
    }else{
        self.locationDistance.hidden = YES;
    }
    if ([imagesArray count] == 0) {
        self.imageGridView.hidden = YES;
    } else {
        //如果有图片则刷新图片
        totalBgHeight += DeltaHeight;
        [self reloadGridViewWithFeed:feed originHeigt:totalBgHeight imagesArr:imagesArray originX:originX];
        totalBgHeight += self.imageGridView.frame.size.height;
    }
    self.originFeedBackgroundView.frame = CGRectMake(self.feedStyle.subViewOriginX, totalHeight, self.subViewWidth, totalBgHeight);
    totalHeight += self.originFeedBackgroundView.frame.size.height+DeltaHeight;
    [self.dateLabel setText:feedStyle.dateString];
    self.dateLabel.frame = CGRectMake(self.feedStyle.subViewOriginX, totalHeight, self.subViewWidth, self.dateLabel.frame.size.height);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, feedStyle.totalHeight);
}

- (void)reloadAvatarImageViewWithFeed:(UMComFeed *)feed
{
    NSString *iconString = [feed.creator iconUrlStrWithType:UMComIconSmallType];
    UIImage *placeHolderImage = [UMComImageView placeHolderImageGender:[feed.creator.gender integerValue]];
    [self.portrait setImageURL:iconString placeHolderImage:placeHolderImage];
    self.portrait.clipsToBounds = YES;
    self.portrait.layer.cornerRadius = self.portrait.frame.size.width/2;
}

- (void)reloadFeedTextViewWithFeed:(UMComFeed *)feed originHeigt:(CGFloat)originHeigth
{
    self.feedStyleView.frame = CGRectMake(self.feedStyle.subViewOriginX, originHeigth, self.subViewWidth, self.feedStyle.feedStyleTextModel.textSize.height);
    [self.feedStyleView setMutiStyleTextViewWithMutiText:self.feedStyle.feedStyleTextModel];
    __weak typeof(self) weakSelf = self;
    self.feedStyleView.clickOnlinkText = ^(UMComMutiStyleTextView *styleView,UMComMutiTextRun *run){
        [weakSelf clickInTextView:weakSelf.feedStyleView mutiTextRun:run];
    };
}

- (void)reloadOriginFeedTextViewWithFeed:(UMComFeed *)feed originHeigt:(CGFloat)originHeigth
{
    self.originFeedStyleView.pointOffset = CGPointMake(0, OriginFeedHeightOffset);
    self.originFeedStyleView.frame = CGRectMake(self.originFeedStyleView.frame.origin.x, OriginFeedOriginY, self.originFeedStyleView.frame.size.width, self.feedStyle.originFeedStyleTextModel.textSize.height);
    [self.originFeedStyleView setMutiStyleTextViewWithMutiText:self.feedStyle.originFeedStyleTextModel];
    __weak typeof(self) weakSelf = self;
    self.originFeedStyleView.clickOnlinkText = ^(UMComMutiStyleTextView *styleView,UMComMutiTextRun *run){
        [weakSelf clickInTextView:weakSelf.originFeedStyleView mutiTextRun:run];
    };
}

- (void)reloadGridViewWithFeed:(UMComFeed *)feed originHeigt:(CGFloat)originHeigth imagesArr:(NSArray *)imagesArray originX:(CGFloat)originX
{
    self.imageGridView.hidden = NO;
    CGFloat imageViewWidth = self.subViewWidth-originX*2;
    self.imageGridView.frame = CGRectMake(originX,  originHeigth, imageViewWidth, self.feedStyle.imagesViewHeight);
    [self.imageGridView setImages:imagesArray placeholder:UMComImageWithImageName(@"image-placeholder") cellPad:ImageSpace];
    self.imageGridView.frame = CGRectMake(originX,  originHeigth, self.originFeedBackgroundView.frame.size.width-originX*2, self.feedStyle.imagesViewHeight);
    __weak typeof(self) weakSelf = self;
    self.imageGridView.TapInImage = ^(UMComGridViewerController *viewerController, UIImageView *imageView){
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(customObj:clickOnImageView:complitionBlock:)]) {
            __strong typeof(self) strongSelf = weakSelf;
            [weakSelf.delegate customObj:strongSelf clickOnImageView:imageView complitionBlock:^(UIViewController *currentViewController) {
                [currentViewController presentViewController:viewerController animated:YES completion:^{
                }];
            }];
        }
    };
}


- (void)reloadMenuBgViewWithFeed:(UMComFeed *)feed originHeigt:(CGFloat)originHeigth
{
    self.likeCountLabel.text = [NSString stringWithFormat:@"%d",[self.feed.likes_count intValue]];
    self.commentCountLabel.text = [NSString stringWithFormat:@"%d",[self.feed.comments_count intValue]];
    self.forwardCountLabel.text = [NSString stringWithFormat:@"%d",[self.feed.forward_count intValue]];
    self.bottomMenuBgView.frame = CGRectMake(self.bottomMenuBgView.frame.origin.x, originHeigth, self.bottomMenuBgView.frame.size.width, self.bottomMenuBgView.frame.size.height);
}

/****************************reload subViews views end *****************************/
#pragma mark - UMComClickActionDelegate
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
    } else if ([mutiTextRun isKindOfClass:[UMComMutiTextRunURL class]]){
        [self clickInUrl:mutiTextRun.text];
    }
    else{
        if (styleView == self.feedStyleView) {
            [self goToFeedDetailView];
        }else if(styleView == self.originFeedStyleView){
            [self goToForwardDetailView];
        }
    }
}

- (void)clickInUrl:(NSString *)text
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnURL:)]) {
        [self.delegate customObj:self clickOnURL:text];
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

- (void)onClicLocation:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnLocationText:)]) {
        [self.delegate customObj:self clickOnLocationText:self.feed];
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

- (IBAction)onClickOnAddCollection:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnFavouratesFeed:)]) {
        [self.delegate customObj:self clickOnFavouratesFeed:self.feed];
    }
}

-(void)onClickUserProfile:(id)sender
{
    UMComUser *feedCreator = self.feed.creator;
    [self turnToUserCenterWithUser:feedCreator];
}

- (void)goToFeedDetaiView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnFeedText:)]) {
        [self.delegate customObj:self clickOnFeedText:self.feed];
    }
}

-(void)onClickComment:(UITapGestureRecognizer *)sender
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnComment:feed:)]) {
        [self.delegate customObj:self clickOnComment:nil feed:self.feed];
    }
}

-(void)onClickLike:(UITapGestureRecognizer *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnLikeFeed:)]) {
        [self.delegate customObj:self  clickOnLikeFeed:self.feed];
    }
}
-(void)onClickForward:(UITapGestureRecognizer *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnForward:)]) {
        [self.delegate customObj:self clickOnForward:self.feed];
    }
}

@end
