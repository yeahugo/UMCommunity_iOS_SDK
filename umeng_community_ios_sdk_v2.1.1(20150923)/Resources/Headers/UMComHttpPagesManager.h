//
//  UMComHttpPagesManager.h
//  UMCommunity
//
//  Created by luyiyuan on 14/10/28.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComHttpPagesRequest.h"


#pragma mark -
#pragma mark User

@class CLLocation;

@interface UMComHttpPagesAllNewFeeds : UMComHttpPagesRequest

- (id)initWithCount:(NSUInteger)count response:(PageDataResponse)response;

@end

@interface UMComHttpPagesUserFeeds : UMComHttpPagesRequest
//获取用户首页的feeds
- (id)initWithCount:(NSUInteger)count response:(PageDataResponse)response;
@end

@interface UMComHttpPagesOneFeed : UMComHttpPagesRequest
//获取单个feed
- (id)initWithFeedId:(NSString *)feedId
           viewExtra:(NSDictionary *)viewExtra
            response:(PageDataResponse)response;
@end

@interface UMComHttpPagesFriendFeeds : UMComHttpPagesRequest

- (id)initWithCount:(NSUInteger)count response:(PageDataResponse)response;

@end

@interface UMComHttpSearchFeeds : UMComHttpPagesRequest

- (id)initWithCount:(NSUInteger)count keywords:(NSString *)keywords response:(PageDataResponse)response;

@end

@interface UMComHttpNearbyFeeds : UMComHttpPagesRequest

- (id)initWithLocation:(CLLocation *)location count:(NSInteger)count response:(PageDataResponse)response;

@end

@interface UMComHttpSearchUsers : UMComHttpPagesRequest

- (id)initWithCount:(NSUInteger)count keywords:(NSString *)keywords response:(PageDataResponse)response;

@end


@interface UMComHttpPagesUserTimeline : UMComHttpPagesRequest
//获取用户自己发布的时间线
- (id)initWithCount:(NSUInteger)count uid:(NSString *)uid parameter:(NSString *)parameter response:(PageDataResponse)response;
@end

@interface UMComHttpPagesUserTopics : UMComHttpPagesRequest
//获取用户的已关注的话题(注意，已关注的话题不需要再获取，第一次进入需要获取)
- (id)initWithCount:(NSUInteger)count uid:(NSString *)uid response:(PageDataResponse)response;
@end

@interface UMComHttpPagesUserFans : UMComHttpPagesRequest
//获取用户的粉丝
- (id)initWithCount:(NSUInteger)count uid:(NSString *)uid response:(PageDataResponse)response;
@end

@interface UMComHttpPagesUserFollowings : UMComHttpPagesRequest
//获取用户的关注人
- (id)initWithCount:(NSUInteger)count uid:(NSString *)uid response:(PageDataResponse)response;
@end

@interface UMComHttpUserProfile : UMComHttpPagesRequest
//获取用户详情
- (id)initWithUid:(NSString *)uid source:(NSString *)source source_uid:(NSString *)source_uid response:(LoadDataCompletion)response;

@end

@interface UMComHttpPagesUserLikesReceived : UMComHttpPagesRequest
//获取用户的被喜欢feed
- (id)initWithCount:(NSInteger)count response:(LoadDataCompletion)response;
@end

@interface UMComHttpPagesUserCommentsReceived : UMComHttpPagesRequest
//获取用户收到的评论
- (id)initWithCount:(NSInteger)count response:(LoadDataCompletion)response;
@end

@interface UMComHttpPagesUserCommentsSent : UMComHttpPagesRequest
//获取用户发出的评论
- (id)initWithCount:(NSInteger)count response:(LoadDataCompletion)response;
@end

@interface UMComHttpPagesUserFeedBeAt : UMComHttpPagesRequest
//获取用户被at的feed
- (id)initWithCount:(NSInteger)count response:(LoadDataCompletion)response;
@end

@interface UMComHttpPagesUserNotifications : UMComHttpPagesRequest
//获取用户被at的feed
- (id)initWithCount:(NSInteger)count response:(LoadDataCompletion)response;
@end

@interface UMComHttpPagesUserFavourites : UMComHttpPagesRequest
//获取用户收藏的feed
- (id)initWithCount:(NSInteger)count response:(LoadDataCompletion)response;
@end

@interface UMComHttpFeedsByFeedIds : UMComHttpPagesRequest

- (id)initWithFeedIds:(NSArray *)feedIds response:(LoadDataCompletion)response;
@end

#pragma mark -
#pragma mark Feed

@interface UMComHttpPagesComments : UMComHttpPagesRequest

//获取Feed对应的所有评论
- (id)initWithFeedId:(NSString *)feedId count:(NSInteger)count order:(NSString *)order response:(PageDataResponse)response;

@end

@interface UMComHttpPagesFeedLikes : UMComHttpPagesRequest

- (id)initWithFeedId:(NSString *)feedId count:(NSInteger)count response:(PageDataResponse)response;

@end

#pragma mark -
#pragma mark topic



@interface UMComHttpPagesTopics : UMComHttpPagesRequest
//获取所有的话题
- (id)initWithCount:(NSUInteger)count response:(PageDataResponse)response;
@end

@interface UMComHttpPagesTopicsSearch : UMComHttpPagesRequest
//话题搜索
- (id)initWithCount:(NSUInteger)count keywords:(NSString *)keywords response:(PageDataResponse)response;

@end

@interface UMComHttpPagesTopicFeeds : UMComHttpPagesRequest
//获取该话题下的feeds
- (id)initWithCount:(NSUInteger)count topicId:(NSString *)topicId order:(NSString *)order response:(PageDataResponse)response;
@end



#pragma mark - recommend 

@interface UMComHttpPagesRecommendUsers : UMComHttpPagesRequest

- (id)initWithCount:(NSInteger)count response:(PageDataResponse)response;

@end

@interface UMComHttpPagesRecommendFeeds : UMComHttpPagesRequest

- (id)initWithCount:(NSInteger)count response:(PageDataResponse)response;

@end

@interface UMComHttpPagesRecommendTopics : UMComHttpPagesRequest

- (id)initWithCount:(NSInteger)count response:(PageDataResponse)response;

@end

@interface UMComHttpPagesRecommendTopicUsers : UMComHttpPagesRequest

- (id)initWithCount:(NSInteger)count topicId:(NSString *)topicId response:(PageDataResponse)response;
@end

@interface UMComHttpPagesUserAlbum : UMComHttpPagesRequest

- (id)initWithCount:(NSInteger)count fuid:(NSString *)fuid response:(PageDataResponse)response;

@end


@interface UMComHttpPagesTopicRecommendFeeds : UMComHttpPagesRequest

- (id)initWithTopicId:(NSString *)topicId response:(PageDataResponse)response;

@end


