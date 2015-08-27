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
    if (feedType == feedDefaultType || feedType == feedFavourateType || feedType == feedDistanceType) {
        feedStyle.subViewDeltalWidth = TableViewDeltaWidth;
        feedStyle.subViewOriginX = 59;
        if (feedType == feedFavourateType) {
            feedStyle.nameLabelWidth = viewWidth-2*(feedStyle.subViewOriginX+10);
        }else{
            feedStyle.nameLabelWidth = viewWidth-feedStyle.subViewOriginX-ShareButtonWidth;
        }
    } else if (feedType == feedDetailType){
        feedStyle.subViewDeltalWidth = 30;
        feedStyle.subViewOriginX = 15;
        feedStyle.nameLabelWidth = viewWidth-2*69;
    }
    feedStyle.subViewWidth = viewWidth - feedStyle.subViewDeltalWidth;
    [feedStyle resetWithFeed:feed];
    
    return feedStyle;
}


- (void)resetWithFeed:(UMComFeed *)feed
{
    self.feed = feed;
    self.likeCount = [feed.likes_count intValue];
    self.commentsCount = [feed.comments_count intValue];
    self.forwordCount = 0;
    float totalHeight = UserNameLabelViewHeight + DeltaHeight;
    NSString * feedSting = @"";
    if (feed.text) {
        //当feed被删除时，把feed设置成原feed，可以在收藏列表中显示
        if ([feed.status intValue] >= FeedStatusDeleted) {
            feedSting = @"";
            feed.origin_feed = feed;
        }
        if (self.feedType != feedDetailType && feed.text.length > kFeedContentLenght) {
            feedSting = [feed.text substringWithRange:NSMakeRange(0, kFeedContentLenght)];
        }else{
            feedSting = feed.text;
        }
        NSMutableArray *feedCheckWords = [NSMutableArray array];
        for (UMComTopic *topic in feed.topics) {
            NSString *topicName = [NSString stringWithFormat:@"#%@#",topic.name];
            [feedCheckWords addObject:topicName];
        }
        for (UMComUser *user in feed.related_user) {
            NSString *userName = [NSString stringWithFormat:@"@%@",user.name];
            [feedCheckWords addObject:userName];
        }
        UMComMutiStyleTextView *feedStyleView = [UMComMutiStyleTextView rectDictionaryWithSize:CGSizeMake(self.subViewWidth, MAXFLOAT) font:FeedFont attString:feedSting lineSpace:TextViewLineSpace runType:UMComMutiTextRunFeedContentType checkWords:feedCheckWords];
        
        self.feedStyleView = feedStyleView;
        
        totalHeight += feedStyleView.totalHeight;
    }
    
    UMComFeed *origin_feed = feed.origin_feed;
    if (origin_feed) {
        if (origin_feed.location) {
            self.location = origin_feed.location;
        }
        NSMutableString *oringFeedString = [NSMutableString stringWithString:@""];
        NSString *originUserName = origin_feed.creator.name? origin_feed.creator.name : @"";
        if ([feed.status intValue] >= FeedStatusDeleted ) {
            origin_feed.text = UMComLocalizedString(@"Spam Content", @"该收藏Feed内容已被删除");
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
        
        if (self.feedType != feedDetailType && oringFeedString.length > kFeedContentLenght) {
            originFeedStr = [originFeedStr substringWithRange:NSMakeRange(0, kFeedContentLenght)];
        }
        NSMutableArray *originFeedCheckWords = [NSMutableArray array];
        for (UMComTopic *topic in origin_feed.topics) {
            NSString *topicName = [NSString stringWithFormat:@"#%@#",topic.name];
            [originFeedCheckWords addObject:topicName];
        }
        for (UMComUser *user in origin_feed.related_user) {
            NSString *userName = [NSString stringWithFormat:@"@%@",user.name];
            [originFeedCheckWords addObject:userName];
        }
        if (origin_feed.creator) {
            [originFeedCheckWords addObject:[NSString stringWithFormat:@"@%@",origin_feed.creator.name]];
        }
        UMComMutiStyleTextView *originStyleView = [UMComMutiStyleTextView rectDictionaryWithSize:CGSizeMake(self.subViewWidth-FeedAndOriginFeedDeltaWidth, MAXFLOAT) font:FeedFont attString:originFeedStr lineSpace:TextViewLineSpace runType:UMComMutiTextRunFeedContentType checkWords:originFeedCheckWords];
        originStyleView.totalHeight += OriginFeedHeightOffset;
        totalHeight += originStyleView.totalHeight + OriginFeedOriginY;
//        originStyleView.frame = CGRectMake(0, 0, self.subViewWidth-FeedAndOriginFeedDeltaWidth, originStyleView.totalHeight);
        self.originFeedStyleView = originStyleView;
    }else{
        if (feed.location) {
            self.location = feed.location;
        }
    }
    if (self.location) {
        totalHeight += LocationBackgroundViewHeight + 3;
    }
    self.images = feed.images;
    self.imageGridViewOriginX = 0;
    if (origin_feed && !origin_feed.isDeleted) {
        self.images = origin_feed.images;
        self.imageGridViewOriginX = FeedAndOriginFeedDeltaWidth/2;
    }
    if(self.images.count > 0) {
        CGFloat imagesViewHeight = (self.subViewWidth- self.imageGridViewOriginX*2-ImageSpace*2)/3;
        self.imagesViewHeight = imagesViewHeight+self.imageGridViewOriginX;
        if (self.images.count > 3) {
            self.imagesViewHeight += (imagesViewHeight + ImageSpace);
            if (self.images.count > 6) {
                self.imagesViewHeight += (imagesViewHeight + ImageSpace);
            }
        }
        totalHeight += self.imagesViewHeight+DeltaHeight;
    }else{
        
    }
    totalHeight += 45;
    self.totalHeight = totalHeight;
    self.dateString = createTimeString(feed.create_time);
}

@end
