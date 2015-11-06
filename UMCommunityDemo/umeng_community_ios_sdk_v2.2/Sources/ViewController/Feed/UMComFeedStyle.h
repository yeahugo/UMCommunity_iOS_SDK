//
//  UMComFeedStyle.h
//  UMCommunity
//
//  Created by Gavin Ye on 4/27/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>


#define TextViewLineSpace 3
#define LikeViewLineSpace 8
#define CommentViewLineSpace 8

#define DeltaHeight 10
#define OriginFeedHeightOffset 0.5
#define OriginFeedOriginY 11

#define ImageSpace 6
#define OriginUserNameString @"@%@：%@"

#define TableViewDeltaWidth 75
#define FeedAndOriginFeedDeltaWidth 10

#define LocationBackgroundViewHeight 21
#define UserNameLabelViewHeight      29

#define ShareButtonWidth  40

#define FeedFont UMComFontNotoSansLightWithSafeSize(15)
#define LikeFont UMComFontNotoSansLightWithSafeSize(14)
#define CommentFont UMComFontNotoSansLightWithSafeSize(13)

typedef enum {
    feedDefaultType = 0,
    feedDetailType = 1,
    feedFavourateType = 2,
    feedDistanceType = 3,
    feedFocusType = 4,
    feedUserType = 5,
    feedTopicType = 6
}UMComFeedType;


@class UMComFeed, UMComMutiStyleTextView, UMComLocationModel;

@interface UMComFeedStyle : NSObject

@property (nonatomic, strong) UMComMutiStyleTextView * feedStyleView;
@property (nonatomic, strong) UMComMutiStyleTextView * originFeedStyleView;
@property (nonatomic) float totalHeight;
@property (nonatomic, assign) int commentsCount;
@property (nonatomic, assign) int likeCount;
@property (nonatomic, assign) int forwordCount;
@property (nonatomic, strong) UMComFeed *feed;
@property (nonatomic, strong) UMComFeed *originFeed;

@property (nonatomic, assign) CGFloat subViewDeltalWidth;
@property (nonatomic, assign) CGFloat subViewOriginX;
@property (nonatomic, assign) CGFloat subViewWidth;
@property (nonatomic, assign) CGFloat imagesViewHeight;
@property (nonatomic, assign) CGFloat locationBgViewHeight;
@property (nonatomic, assign) CGFloat nameLabelWidth;
@property (nonatomic, assign) CGFloat imageGridViewOriginX;
@property (nonatomic, strong) NSArray *imageModels;
@property (nonatomic, copy)   NSString *dateString;
@property (nonatomic, strong) UMComLocationModel *locationModel;
@property (nonatomic, assign) BOOL isShowTopIamge;

@property (nonatomic, assign) UMComFeedType feedType;

+ (UMComFeedStyle *)feedStyleWithFeed:(UMComFeed *)feed viewWidth:(float)viewWidth feedType:(UMComFeedType)feedType;

- (void)resetWithFeed:(UMComFeed *)feed;
@end
