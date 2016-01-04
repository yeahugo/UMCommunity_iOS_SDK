//
//  UMComSysCommentCell.m
//  UMCommunity
//
//  Created by umeng on 15/11/30.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComSysCommentCell.h"
#import "UMComComment.h"
#import "UMComComment+UMComManagedObject.h"
#import "UMComUser.h"
#import "UMComTools.h"
#import "UMComImageView.h"
#import "UMComMutiStyleTextView.h"
#import "UMComFeed+UMComManagedObject.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComTopic.h"
#import "UMComClickActionDelegate.h"

const float CommentNameLabelHeight = 30;
const float CommentContentOriginY = 10;

@interface UMComSysCommentCell ()

@property (nonatomic, strong) UIImageView *bgimageView;

@property (nonatomic, strong) UMComComment *comment;

@end

@implementation UMComSysCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat textOriginX = 50;
        CGFloat textOriginY = CommentContentOriginY;
        self.portrait = [[[UMComImageView imageViewClassName] alloc]initWithFrame:CGRectMake(10, textOriginY, 30, 30)];
        self.portrait.userInteractionEnabled = YES;
        self.portrait.layer.cornerRadius = self.portrait.frame.size.width/2;
        self.portrait.clipsToBounds = YES;
        [self.contentView addSubview:self.portrait];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didSelectedUser)];
        [self.portrait addGestureRecognizer:tap];
        
        self.userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(textOriginX, textOriginY, self.frame.size.width-textOriginX-10-120, CommentNameLabelHeight)];
        self.userNameLabel.font = UMComFontNotoSansLightWithSafeSize(15);
        [self.contentView addSubview:self.userNameLabel];
        
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(textOriginX+self.userNameLabel.frame.size.width, textOriginY, 120, CommentNameLabelHeight)];
        self.timeLabel.textColor = [UMComTools colorWithHexString:FontColorGray];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        self.timeLabel.font = UMComFontNotoSansLightWithSafeSize(14);
        [self.contentView addSubview:self.timeLabel];
        
        self.commentTextView = [[UMComMutiStyleTextView alloc] initWithFrame:CGRectMake(textOriginX, textOriginY + self.userNameLabel.frame.size.height+10, self.frame.size.width-80, 50)];
        self.commentTextView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.commentTextView];
        
        self.replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.replyButton.frame = CGRectMake(self.commentTextView.frame.size.width+self.commentTextView.frame.origin.x+4, self.commentTextView.frame.origin.y, 16, 16);
        [self.replyButton addTarget:self action:@selector(didClickOnReplyButton) forControlEvents:UIControlEventTouchUpInside];
        [self.replyButton setBackgroundImage:UMComImageWithImageName(@"um_replyme") forState:UIControlStateNormal];
        [self.contentView addSubview:self.replyButton];
        
        self.bgimageView = [[UIImageView alloc]initWithFrame:CGRectMake(textOriginX, self.commentTextView.frame.origin.y+self.commentTextView.frame.size.height, self.frame.size.width-60, 100)];
        UIImage *resizableImage = [UMComImageWithImageName(@"origin_image_bg") resizableImageWithCapInsets:UIEdgeInsetsMake(20, 50, 0, 0)];
        self.bgimageView.image = resizableImage;
        [self.contentView addSubview:self.bgimageView];
        
        self.feedTextView = [[UMComMutiStyleTextView alloc] initWithFrame:CGRectMake(textOriginX, self.bgimageView.frame.origin.y+10, self.frame.size.width-60, 80)];
        self.feedTextView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.feedTextView];
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


- (void)reloadCellWithLikeModel:(UMComCommentModel *)commentModel
{
    self.comment = commentModel.comment;
    UMComUser *user = commentModel.comment.creator;
    NSString *iconUrl = [user iconUrlStrWithType:UMComIconSmallType];
    [self.portrait setImageURL:iconUrl placeHolderImage:[UMComImageView placeHolderImageGender:user.gender.integerValue]];
    
    self.userNameLabel.text = commentModel.nameString;
    self.timeLabel.text = commentModel.timeString;
    self.userNameLabel.frame = CGRectMake(commentModel.subViewsOriginX, CommentContentOriginY, commentModel.subViewWidth-120, CommentNameLabelHeight);
    self.timeLabel.frame = CGRectMake(commentModel.subViewsOriginX+self.userNameLabel.frame.size.width, CommentContentOriginY, 120, CommentNameLabelHeight);
    self.commentTextView.frame = CGRectMake(commentModel.subViewsOriginX, CommentContentOriginY+CommentNameLabelHeight, commentModel.subViewWidth-commentModel.commentTextViewDelta, commentModel.commentMutiText.textSize.height);
    if (commentModel.commentTextViewDelta > 0) {
        self.replyButton.frame = CGRectMake(self.commentTextView.frame.size.width+self.commentTextView.frame.origin.x+4, self.commentTextView.frame.origin.y, 16, 16);
        self.replyButton.hidden = NO;
    }else{
        self.replyButton.hidden = YES;
    }
    
    [self.commentTextView setMutiStyleTextViewWithMutiText:commentModel.commentMutiText];
    __weak typeof(self) weakSelf = self;
    
    self.commentTextView.clickOnlinkText = ^(UMComMutiStyleTextView *styleView,UMComMutiTextRun *run){
        if ([run isKindOfClass:[UMComMutiTextRunClickUser class]]) {
            UMComUser *user = weakSelf.comment.reply_user;
            [weakSelf turnToUserCenterWithUser:user];
        }else if ([run isKindOfClass:[UMComMutiTextRunURL class]]){
            [weakSelf turnToWebViewWithUrlString:run.text];
        }
    };
    
    self.bgimageView.frame = CGRectMake(commentModel.subViewsOriginX, self.commentTextView.frame.origin.y+self.commentTextView.frame.size.height, commentModel.subViewWidth, commentModel.feedMutiText.textSize.height+commentModel.feedTextOrigin.y);
    
    self.feedTextView.frame = CGRectMake(commentModel.subViewsOriginX+commentModel.feedTextOrigin.x, self.bgimageView.frame.origin.y+commentModel.feedTextOrigin.y, commentModel.subViewWidth-commentModel.feedTextOrigin.x*2, commentModel.feedMutiText.textSize.height);
    [self.feedTextView setMutiStyleTextViewWithMutiText:commentModel.feedMutiText];
    self.feedTextView.clickOnlinkText = ^(UMComMutiStyleTextView *styleView,UMComMutiTextRun *run){
        if ([run isKindOfClass:[UMComMutiTextRunClickUser class]]) {
            UMComMutiTextRunClickUser *userRun = (UMComMutiTextRunClickUser *)run;
            UMComUser *user = [weakSelf.comment.feed relatedUserWithUserName:userRun.text];
            [weakSelf turnToUserCenterWithUser:user];
        }else if ([run isKindOfClass:[UMComMutiTextRunTopic class]])
        {
            UMComMutiTextRunTopic *topicRun = (UMComMutiTextRunTopic *)run;
            UMComTopic *topic = [weakSelf.comment.feed relatedTopicWithTopicName:topicRun.text];
            [weakSelf turnToTopicViewWithTopic:topic];
        }else{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(customObj:clickOnFeedText:)]) {
                __strong typeof(weakSelf)strongSelf = weakSelf;
                [weakSelf.delegate customObj:strongSelf clickOnFeedText:weakSelf.comment.feed];
            }
        }
    };
}


- (void)didClickOnReplyButton
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnComment:feed:)]) {
        [self.delegate customObj:self clickOnComment:self.comment feed:self.comment.feed];
    }
}

- (void)didSelectedUser
{
    [self turnToUserCenterWithUser:self.comment.creator];
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


@end



@implementation UMComCommentModel
{
    float mainViewWidth;
}
+ (UMComCommentModel *)commentModelWithComment:(UMComComment *)comment viewWidth:(float)viewWidth commentTextViewDelta:(CGFloat)commentTextViewDelta
{
    UMComCommentModel *commentModel = [[UMComCommentModel alloc]init];
    commentModel.subViewsOriginX = 50;
    commentModel.subViewWidth = viewWidth - commentModel.subViewsOriginX - 10;
    commentModel.viewWidth = viewWidth;
    [commentModel resetWithComment:comment];
    commentModel.feedTextOrigin = CGPointMake(2, 10);
    commentModel.commentTextViewDelta = commentTextViewDelta;
    return commentModel;
}

- (void)resetWithComment:(UMComComment *)comment
{
    self.comment = comment;
    UMComUser *user = comment.creator;
    UMComFeed *feed = comment.feed;
    self.portraitUrlString = [user iconUrlStrWithType:UMComIconSmallType];
    self.timeString = createTimeString(comment.create_time);
    self.nameString = [NSString stringWithFormat:@"%@",user.name];
    float totalHeight = CommentNameLabelHeight + CommentContentOriginY;
    
    if (comment.content) {
        NSMutableString * replayStr = [NSMutableString stringWithString:@""];
        NSMutableArray *checkWords = nil;
        if (comment.reply_user) {
            [replayStr appendString:@"回复"];
            checkWords = [NSMutableArray arrayWithObject:[NSString stringWithFormat:UserNameString,comment.reply_user.name]];;
            //            [replayStr appendFormat:@"@%@：",comment.reply_user.name];
            [replayStr appendFormat:UserNameString,comment.reply_user.name];
            [replayStr appendFormat:@"："];
        }
        if (comment.content) {
            [replayStr appendFormat:@"%@",comment.content];
        }
        UMComMutiText *mutiText = [UMComMutiText mutiTextWithSize:CGSizeMake(self.subViewWidth-self.commentTextViewDelta, MAXFLOAT) font:UMComFontNotoSansLightWithSafeSize(14) string:replayStr lineSpace:2 checkWords:checkWords];
        totalHeight += mutiText.textSize.height;
        self.commentMutiText = mutiText;
    }
    
    NSString * feedSting = @"";
    NSMutableArray *feedCheckWords = nil;
    if ([feed.status integerValue] < FeedStatusDeleted) {
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
    UMComMutiText *feedStyleView = [UMComMutiText mutiTextWithSize:CGSizeMake(self.subViewWidth-self.feedTextOrigin.x*2, MAXFLOAT) font:UMComFontNotoSansLightWithSafeSize(14) string:feedSting lineSpace:3 checkWords:feedCheckWords];
    self.feedMutiText = feedStyleView;
    totalHeight += feedStyleView.textSize.height;
    self.totalHeight = totalHeight+25;
}


@end

