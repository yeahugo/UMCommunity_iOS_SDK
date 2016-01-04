//
//  UMComSysLikeTableViewCell.m
//  UMCommunity
//
//  Created by umeng on 15/12/28.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumSysLikeTableViewCell.h"
#import "UMComLike.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComMutiStyleTextView.h"
#import "UMComImageView.h"
#import "UMComTools.h"
#import "UMComFeed+UMComManagedObject.h"
#import "UMComClickActionDelegate.h"

@interface UMComForumSysLikeTableViewCell ()

@property (nonatomic, strong) UMComLike *like;

@end

@implementation UMComForumSysLikeTableViewCell


- (void)reloadCellWithObj:(id)obj
               timeString:(NSString *)timeString
                 mutiText:(UMComMutiText *)commentMutiText
             feedMutiText:(UMComMutiText *)feedMutiText
{
    self.like = (UMComLike *)obj;
    UMComUser *user = _like.creator;
    NSString *iconUrl = [user iconUrlStrWithType:UMComIconSmallType];
    [self.portrait setImageURL:iconUrl placeHolderImage:[UMComImageView placeHolderImageGender:user.gender.integerValue]];
    
    self.userNameLabel.text = [NSString stringWithFormat:@"%@ 赞了你",user.name];;
    self.timeLabel.text = timeString;

    CGRect bgImageFrame = self.bgimageView.frame;
    bgImageFrame.origin.y = self.userNameLabel.frame.origin.y + self.userNameLabel.frame.size.height;
    bgImageFrame.size.height = feedMutiText.textSize.height+UMCom_SysCommonCell_FeedText_TopEdge + UMCom_SysCommonCell_FeedText_BottomEdge;
    self.bgimageView.frame = bgImageFrame;
    //
    CGRect feedTextFrame = self.feedTextView.frame;
    feedTextFrame.origin.y = bgImageFrame.origin.y + UMCom_SysCommonCell_FeedText_TopEdge;
    feedTextFrame.size.height = feedMutiText.textSize.height;
    self.feedTextView.frame = feedTextFrame;
    [self.feedTextView setMutiStyleTextViewWithMutiText:feedMutiText];
    __weak typeof(self) weakSelf = self;
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

@end
