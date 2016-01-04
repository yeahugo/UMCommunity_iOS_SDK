//
//  UMComForumSysCommentCell.m
//  UMCommunity
//
//  Created by umeng on 15/12/27.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumSysCommentCell.h"
#import "UMComComment.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComMutiStyleTextView.h"
#import "UMComImageView.h"
#import "UMComTools.h"
#import "UMComFeed+UMComManagedObject.h"
#import "UMComClickActionDelegate.h"

@interface UMComForumSysCommentCell () <UMComClickActionDelegate>

@property (nonatomic, strong) UMComComment *comment;

@property (nonatomic, assign) CGSize cellSize;

@end

@implementation UMComForumSysCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellSize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellSize:cellSize];
    if (self) {
        _cellSize = cellSize;
        
        self.commentTextView = [[UMComMutiStyleTextView alloc] initWithFrame:CGRectMake(UMCom_SysCommonCell_SubViews_LeftEdge, UMCom_SysCommonCell_Content_TopEdge + self.userNameLabel.frame.size.height+10, cellSize.width-80, 50)];
        self.commentTextView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.commentTextView];
        
        self.replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.replyButton.frame = CGRectMake(self.commentTextView.frame.size.width+self.commentTextView.frame.origin.x+4, self.commentTextView.frame.origin.y, 16, 16);
        [self.replyButton addTarget:self action:@selector(didClickOnReplyButton) forControlEvents:UIControlEventTouchUpInside];
        [self.replyButton setBackgroundImage:UMComImageWithImageName(@"um_replyme") forState:UIControlStateNormal];
        [self.contentView addSubview:self.replyButton];
    }
    return self;
}

- (void)reloadCellWithObj:(id)obj
               timeString:(NSString *)timeString
                 mutiText:(UMComMutiText *)commentMutiText
             feedMutiText:(UMComMutiText *)feedMutiText
{
    self.comment = (UMComComment *)obj;
    UMComUser *user = _comment.creator;
    NSString *iconUrl = [user iconUrlStrWithType:UMComIconSmallType];
    [self.portrait setImageURL:iconUrl placeHolderImage:[UMComImageView placeHolderImageGender:user.gender.integerValue]];
    
    self.userNameLabel.text = _comment.creator.name;
    self.timeLabel.text = timeString;
    
    CGRect commentFrame = self.commentTextView.frame;
    commentFrame.size.height = commentMutiText.textSize.height;
    if (self.replyButton.hidden) {
        commentFrame.size.width = _cellSize.width - UMCom_SysCommonCell_SubViews_LeftEdge - UMCom_SysCommonCell_SubViews_RightEdge;
    }else{
        commentFrame.size.width = _cellSize.width - UMCom_SysCommonCell_SubViews_LeftEdge - UMCom_SysCommonCell_SubViews_RightEdge - self.replyButton.frame.size.width - 1;
    }
    self.commentTextView.frame = commentFrame;
    CGRect bgimgeViewFrame = self.bgimageView.frame;
    bgimgeViewFrame.size.width = commentFrame.size.width;
    self.bgimageView.frame = bgimgeViewFrame;

    [self.commentTextView setMutiStyleTextViewWithMutiText:commentMutiText];
    
    __weak typeof(self) weakSelf = self;
    self.commentTextView.clickOnlinkText = ^(UMComMutiStyleTextView *styleView,UMComMutiTextRun *run){
        if ([run isKindOfClass:[UMComMutiTextRunClickUser class]]) {
            UMComUser *user = weakSelf.comment.reply_user;
            [weakSelf turnToUserCenterWithUser:user];
        }else if ([run isKindOfClass:[UMComMutiTextRunURL class]]){
            [weakSelf turnToWebViewWithUrlString:run.text];
        }
    };
    
    CGRect bgImageFrame = self.bgimageView.frame;
    bgImageFrame.origin.y = commentFrame.origin.y + commentFrame.size.height;
    bgImageFrame.size.height = feedMutiText.textSize.height+UMCom_SysCommonCell_FeedText_TopEdge + UMCom_SysCommonCell_FeedText_BottomEdge;
    self.bgimageView.frame = bgImageFrame;
//
    CGRect feedTextFrame = self.feedTextView.frame;
    feedTextFrame.origin.y = bgImageFrame.origin.y + UMCom_SysCommonCell_FeedText_TopEdge;
    feedTextFrame.size.height = feedMutiText.textSize.height;
    self.feedTextView.frame = feedTextFrame;
    [self.feedTextView setMutiStyleTextViewWithMutiText:feedMutiText];
    
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


@end
