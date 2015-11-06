//
//  UMComFeedStyle.m
//  UMCommunity
//
//  Created by Gavin Ye on 4/27/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import "UMComFeedStyle.h"
#import "UMComSession.h"
#import "UMComTools.h"
#import "UMComMutiStyleTextView.h"
#import "UMComFeed.h"
#import "UMComTopic.h"
#import "UMComFeed+UMComManagedObject.h"
#import "UMComLocationModel.h"
#import "UMComPullRequest.h"


@implementation UMComFeedStyle

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (UMComFeedStyle *)feedStyleWithFeed:(UMComFeed *)feed viewWidth:(float)viewWidth feedType:(UMComFeedType)feedType
{
    UMComFeedStyle *feedStyle = [[UMComFeedStyle alloc]init];
    feedStyle.feedType = feedType;
    if (feedType == feedDetailType){
        feedStyle.subViewDeltalWidth = 30;
        feedStyle.subViewOriginX = 15;
        feedStyle.nameLabelWidth = viewWidth-2*69;
    }else{
        feedStyle.subViewDeltalWidth = TableViewDeltaWidth;
        feedStyle.subViewOriginX = 59;
        if (feedType == feedFavourateType) {
            feedStyle.nameLabelWidth = viewWidth-2*(feedStyle.subViewOriginX+10);
        }else{
            feedStyle.nameLabelWidth = viewWidth-feedStyle.subViewOriginX-ShareButtonWidth;
        }
    }
    feedStyle.subViewWidth = viewWidth - feedStyle.subViewDeltalWidth;
    [feedStyle resetWithFeed:feed];
    
    return feedStyle;
}

- (void)resetWithFeed:(UMComFeed *)feed
{
    if ((self.feedType == feedFocusType || self.feedType == feedUserType || self.feedType == feedTopicType)  && [feed.is_top boolValue]) {
        self.isShowTopIamge = YES;
    }else{
        self.isShowTopIamge = NO;
    }
    self.likeCount = [feed.likes_count intValue];
    self.commentsCount = [feed.comments_count intValue];
    self.forwordCount = 0;
    float totalHeight = UserNameLabelViewHeight + DeltaHeight;
    self.feed = feed;
    NSString * feedSting = @"";
    if (feed.text && [feed.status intValue] < FeedStatusDeleted) {
        if (self.feedType != feedDetailType && [UMComTools getStringLengthWithString:self.feed.text] > kFeedContentLength) {
            feedSting = [feed.text substringWithRange:NSMakeRange(0, kFeedContentLength)];
        }
        else
        {
            feedSting = feed.text;
        }
                
        NSMutableArray *feedCheckWords = [NSMutableArray array];
        for (UMComTopic *topic in feed.topics) {
            NSString *topicName = [NSString stringWithFormat:TopicString,topic.name];
            [feedCheckWords addObject:topicName];
        }
        for (UMComUser *user in feed.related_user) {
            NSString *userName = [NSString stringWithFormat:UserNameString,user.name];
            [feedCheckWords addObject:userName];
        }
        UMComMutiStyleTextView *feedStyleView = [UMComMutiStyleTextView rectDictionaryWithSize:CGSizeMake(self.subViewWidth, MAXFLOAT) font:FeedFont attString:feedSting lineSpace:TextViewLineSpace runType:UMComMutiTextRunFeedContentType checkWords:feedCheckWords];
        self.feedStyleView = feedStyleView;
        
        totalHeight += feedStyleView.totalHeight;
        feedStyleView.totalHeight += OriginFeedHeightOffset;
        //此处是为了字数过多时进行高度纠偏而用的
        if (self.feedType == feedDetailType && [UMComTools getStringLengthWithString:feedSting] > kFeedContentLength) {
            feedStyleView.totalHeight += DeltaHeight;
        }
    }
    
    UMComFeed *origin_feed = feed.origin_feed;
    if ([feed.status integerValue] >= FeedStatusDeleted) {
        origin_feed = feed;
        origin_feed.images = [NSArray array];
    }
    self.originFeed = origin_feed;
    if (origin_feed) {
        if (origin_feed.location) {
            self.locationModel = [origin_feed locationModel];
        }
        NSMutableString *oringFeedString = [NSMutableString stringWithString:@""];
        NSString *originUserName = origin_feed.creator.name? origin_feed.creator.name : @"";
        if ([feed.status intValue] >= FeedStatusDeleted ) {
            origin_feed.text = UMComLocalizedString(@"Delete Content", @"该内容已被删除");
        }
        else if ([origin_feed.status intValue] >= FeedStatusDeleted) {
            origin_feed.text = UMComLocalizedString(@"Delete Content", @"该内容已被删除");
            origin_feed.images = [NSArray array];
        }
        //若把当前feed当成原feed显示的话，不需要显示@用户：
        if ([feed.status intValue] >= FeedStatusDeleted) {
            [oringFeedString appendString:origin_feed.text];
        } else {
            [oringFeedString appendFormat:OriginUserNameString,originUserName,feed.origin_feed.text];
        }
        NSString *originFeedStr = oringFeedString;
        
        if (self.feedType != feedDetailType && [UMComTools getStringLengthWithString:oringFeedString] > kFeedContentLength) {
            originFeedStr = [originFeedStr substringWithRange:NSMakeRange(0, kFeedContentLength)];
        }
        NSMutableArray *originFeedCheckWords = [NSMutableArray array];
        for (UMComTopic *topic in origin_feed.topics) {
            NSString *topicName = [NSString stringWithFormat:TopicString,topic.name];
            [originFeedCheckWords addObject:topicName];
        }
        for (UMComUser *user in origin_feed.related_user) {
            NSString *userName = [NSString stringWithFormat:UserNameString,user.name];
            [originFeedCheckWords addObject:userName];
        }
        if (origin_feed.creator) {
            [originFeedCheckWords addObject:[NSString stringWithFormat:UserNameString,origin_feed.creator.name]];
        }
        UMComMutiStyleTextView *originStyleView = [UMComMutiStyleTextView rectDictionaryWithSize:CGSizeMake(self.subViewWidth-FeedAndOriginFeedDeltaWidth, MAXFLOAT) font:FeedFont attString:originFeedStr lineSpace:TextViewLineSpace runType:UMComMutiTextRunFeedContentType checkWords:originFeedCheckWords];
        originStyleView.totalHeight += OriginFeedHeightOffset;
        totalHeight += originStyleView.totalHeight + OriginFeedOriginY;
        self.originFeedStyleView = originStyleView;
    }else{
        self.locationModel = [feed locationModel];
    }
    if (self.locationModel) {
        totalHeight += LocationBackgroundViewHeight + 3;
    }
    self.imageModels = [feed imageModels];
    self.imageGridViewOriginX = 0;
    if (origin_feed && !origin_feed.isDeleted && [origin_feed.status intValue] < FeedStatusDeleted) {
        self.imageModels = [origin_feed imageModels];
        self.imageGridViewOriginX = FeedAndOriginFeedDeltaWidth/2;
    }
    if(self.imageModels.count > 0) {
        CGFloat imagesViewHeight = (self.subViewWidth- self.imageGridViewOriginX*2-ImageSpace*2)/3;
        self.imagesViewHeight = imagesViewHeight+self.imageGridViewOriginX;
        if (self.imageModels.count > 3) {
            self.imagesViewHeight += (imagesViewHeight + ImageSpace);
            if (self.imageModels.count > 6) {
                self.imagesViewHeight += (imagesViewHeight + ImageSpace);
            }
        }
        totalHeight += self.imagesViewHeight+DeltaHeight;
    }
    totalHeight += 45;
    self.totalHeight = totalHeight;
    self.dateString = createTimeString(feed.create_time);
}

@end
