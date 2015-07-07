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
    if (feedType == feedCellType) {
        feedStyle.subViewDeltalWidth = TableViewDeltaWidth;
        feedStyle.subViewOriginX = 59;
        feedStyle.nameLabelFrame = CGRectMake(59, 10, viewWidth-2*feedStyle.subViewOriginX, 21);

    }else if (feedType == feedDetailType){
        feedStyle.subViewDeltalWidth = 30;
        feedStyle.subViewOriginX = 15;
        feedStyle.nameLabelFrame = CGRectMake(56, 10, viewWidth-2*feedStyle.subViewOriginX, 35);
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
        feedSting = feed.text;
        NSMutableDictionary *feedClickTextDict = [NSMutableDictionary dictionaryWithCapacity:1];
        if (feed.topics.count > 0) {
            [feedClickTextDict setObject:feed.topics.array forKey:@"topics"];
        }
        if (feed.related_user.count > 0) {
            [feedClickTextDict setObject:feed.related_user.array forKey:@"related_user"];
        }
        UMComMutiStyleTextView *feedStyleView = [UMComMutiStyleTextView rectDictionaryWithSize:CGSizeMake(self.subViewWidth, MAXFLOAT) font:FeedFont attString:feedSting lineSpace:TextViewLineSpace runType:UMComMutiTextRunFeedContentType clickArray:[NSMutableArray arrayWithObject:feedClickTextDict]];
        
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
        if ([origin_feed.status intValue] >= FeedStatusDeleted) {
            origin_feed.text = UMComLocalizedString(@"Delete Content", @"该内容已被删除");
            origin_feed.images = [NSArray array];
        }
        [oringFeedString appendFormat:OriginUserNameString,originUserName,feed.origin_feed.text];
        NSMutableDictionary *originFeedClickTextDict = [NSMutableDictionary dictionaryWithCapacity:1];
        if (origin_feed.topics.count > 0) {
            [originFeedClickTextDict setObject:feed.origin_feed.topics.array forKey:@"topics"];
        }
        NSMutableArray *relatedUsers = [NSMutableArray arrayWithCapacity:1];
        [relatedUsers addObject:origin_feed.creator];
        [relatedUsers addObject:feed.creator];
        if (origin_feed.related_user.count > 0) {
            [relatedUsers addObjectsFromArray:origin_feed.related_user.array];
        }
        [originFeedClickTextDict setObject:relatedUsers forKey:@"related_user"];
        
        UMComMutiStyleTextView *originStyleView = [UMComMutiStyleTextView rectDictionaryWithSize:CGSizeMake(self.subViewWidth-FeedAndOriginFeedDeltaWidth, MAXFLOAT) font:FeedFont attString:oringFeedString lineSpace:TextViewLineSpace runType:UMComMutiTextRunFeedContentType clickArray:[NSMutableArray arrayWithObject:originFeedClickTextDict]];
        originStyleView.totalHeight += OriginFeedHeightOffset;
        totalHeight += originStyleView.totalHeight + OriginFeedOriginY;
        originStyleView.frame = CGRectMake(0, 0, self.subViewWidth-FeedAndOriginFeedDeltaWidth, originStyleView.totalHeight);
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
