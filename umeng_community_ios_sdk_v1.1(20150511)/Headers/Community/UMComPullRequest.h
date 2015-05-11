//
//  UMComFetchedResultsController.h
//  UMCommunity
//
//  Created by luyiyuan on 14/10/15.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "UMComUser.h"
#import "UMComTopic.h"
#import "UMComFeed.h"
#import "UMComComment.h"
//#import "UMComUserProfile.h"
#import "UMComHttpPagesManager.h"

@class UMComFetchRequest;

#define kFetchLimit 20
#define kFetchCommentLimit 100

/**
 删除本地消息返回
 
 */
typedef void (^DeleteCoreDataResponse)(NSArray *deleteData,NSError *error);

/**
 获取本地消息返回
 
 */
typedef void (^FetchCoreDataResponse)(NSArray *data, NSError *error);

/**
 获取服务器端数据返回
 
 */
typedef void (^FetchServerDataResponse)(NSArray *data,BOOL haveNextPage, NSError *error);


/**
 仅从服务器端获取数据(没有缓存)
 
 */
typedef void (^OnlyFetchFromServerRespone)(NSArray *data,BOOL haveNextPage, NSError *error);

/**
 拉取数据协议
 
 */
@protocol UMComPullResultDelegate <NSObject>


/**
 返回coredata数据
 
 @param 返回结果
 */
- (void)fetchRequestFromCoreData:(FetchCoreDataResponse)coreDataResponse;

/**
 返回服务器端数据
 
 @param 返回结果
 */
- (void)fetchRequestFromServer:(FetchServerDataResponse)serverResponse;

/**
 从服务器返回下一页数据
 
 @param 返回结果
 */
- (void)fetchNextPageFromServer:(FetchServerDataResponse)serverResponse;

/**
 删除coredata数据，删除数量也是由类的参数指定的
 
 @param 返回结果
 */
- (void)deleteDataFromCoreData:(DeleteCoreDataResponse)deleteDataResponse;


///**
// 返回服务器原始数据
// 
// @oaram 返回结果
// */
//- (void)fetchRequestOnlyFromServer:(OnlyFetchFromServerRespone)serverResponse;
//
///**
// 从服务器返回原始下一页数据
// 
// @param 返回结果
// */
//- (void)fetchNextPageOnlyFromServer:(OnlyFetchFromServerRespone)serverResponse;


@end

/**
 拉取数据的请求
 
 */
@interface UMComPullRequest : NSFetchedResultsController<UMComPullResultDelegate>


@end

/**
 获取所有消息的请求
 
 */
@interface UMComAllFeedsRequest : UMComPullRequest

/**
 获取消息的初始化方法
 
 @param count 数量
 
 @returns 初始化请求对象
 */
- (id)initWithCount:(NSInteger)count;

@end

/**
 获取话题聚合消息的请求
 
 */
@interface UMComTopicFeedsRequest : UMComPullRequest

/**
 话题聚合消息请求的初始化方法
 
 @param topicId 话题Id
 @param count 数量
 
 @returns 话题聚合请求对象
 */
- (id)initWithTopicId:(NSString *)topicId count:(NSInteger)count;

@end

/**
 朋友圈消息请求
 
 */
@interface UMComFriendFeedsRequest : UMComPullRequest

/**
 获取朋友圈请求的初始化方法
 
 @param count 数量
 
 @returns 朋友圈请求对象
 */
- (id)initWithCount:(NSInteger)count;

@end

/**
 获取用户发送的消息请求
 
 */
@interface UMComUserFeedsRequest : UMComPullRequest

/**
 获取用户发送的消息的初始化方法
 
 @param uid 用户id
 @param count 消息数量
 
 @returns 获取用户发送消息的请求对象
 */
- (id)initWithUid:(NSString *)uid count:(NSInteger)count;

@end

/**
 搜索Feed的请求
 
 */
@interface UMComSearchFeedRequest : UMComPullRequest

/**
 搜索Feed请求的初始化方法
 
 @param keywords 搜索关键字
 @param count 搜索结果数量
 
 @returns 搜索Feed请求对象
 */
- (id)initWithKeywords:(NSString *)keywords count:(NSInteger)count;

@end

/**
 搜索用户的请求
 
 */
@interface UMComSearchUserRequest : UMComPullRequest

/**
 搜索用户请求的初始化方法
 
 @param keywords 搜索关键字
 @param count 搜索结果数量
 
 @returns 搜索用户请求对象
 */
- (id)initWithKeywords:(NSString *)keywords count:(NSInteger)count;

@end

/**
 用户关注话题的请求
 
 */
@interface UMComUserTopicsRequest : UMComPullRequest

/**
 获取用户关注话题的初始化方法
 
 @param uid 用户id
 @param count 数量
 
 @returns 用户关注话题请求对象
 */
- (id)initWithUid:(NSString *)uid count:(NSInteger)count;

@end

/**
 获取所有话题的请求
 
 */
@interface UMComAllTopicsRequest : UMComPullRequest

/**
 获取所有话题的初始化方法
 
 @param count 数量
 
 @returns 获取所有话题请求的对象
 */
- (id)initWithCount:(NSInteger)count;

@end

/**
 获取粉丝请求
 
 */
@interface UMComFansRequest : UMComPullRequest

/**
 获取粉丝的初始化方法
 
 @param uid 用户id
 
 @returns 获取粉丝请求对象
 */
- (id)initWithUid:(NSString *)uid count:(NSInteger)count;

@end

/**
 获取关注用户请求
 
 */
@interface UMComFollowersRequest : UMComPullRequest

/**
 获取用户关注者请求的初始化方法
 
 @param uid 用户id
 
 @returns 获取关注用户请求的对象
 */
- (id)initWithUid:(NSString *)uid count:(NSInteger)count;

@end

/**
 获取用户的账户信息请求
 
 */
@interface UMComUserProfileRequest : UMComPullRequest

/**
 获取用户详细信息请求的初始化方法
 
 @param uid 用户id
 
 @returns 获取用户详细信息请求对象
 */
- (id)initWithUid:(NSString *)uid;

@end

/**
 获取消息所有评论请求
 
 */
@interface UMComFeedCommentsRequest : UMComPullRequest

/**
 获取消息所有评论的初始化方法
 
 @param feedId 消息Id
 @param count 评论数量
 
 @returns 获取消息所有评论请求对象
 */
- (id)initWithFeedId:(NSString *)feedId count:(NSInteger)count;

@end

/**
 获取消息所有喜欢请求
 
 */
@interface UMComFeedLikesRequest : UMComPullRequest

/**
 获取消息所有喜欢请求初始化方法
 
 @param feedId 消息Id
 @param count 数量
 
 @returns 获取消息所有喜欢请求对象
 */
- (id)initWithFeedId:(NSString *)feedId count:(NSInteger)count;

@end

/**
 获取一个消息的请求
 
 */
@interface UMComOneFeedRequest : UMComPullRequest

/**
 获取一个消息请求的初始化方法
 
 @param feedId 消息Id
 
 @returns 获取一个消息请求对象
 */
- (id)initWithFeedId:(NSString *)feedId;

@end

/**
 搜索话题请求
 
 */
@interface UMComSearchTopicRequest : UMComPullRequest

/**
 搜索话题请求的初始化方法
 
 @param keywords 搜索话题关键字
 
 @returns 搜索话题请求对象
 */
- (id)initWithKeywords:(NSString *)keywords;

@end

/**
 搜索推荐用户
 
 */
@interface UMComRecommendUsersRequest : UMComPullRequest
/**
 获取推荐用户初始化方法

 @param count 请求个数（暂时用于本地请求）
 
 @returns 获取推荐用户请求对象
 */
- (id)initWithCount:(NSInteger)count;

@end

/**
 搜索推荐消息
 
 */
@interface UMComRecommendFeedsRequest : UMComPullRequest
/**
 获取推荐消息初始化方法
 
 @param count 请求个数（暂时用于本地请求）
 
 @returns 获取推荐消息请求对象
 */
- (id)initWithCount:(NSInteger)count;

@end

/**
 搜索推荐话题
 
 */
@interface UMComRecommendTopicsRequest : UMComPullRequest
/**
 获取推荐话题请求初始化方法
 
 @param count 请求个数（暂时用于本地请求）
 
 @returns 获取推荐话题请求对象
 */
- (id)initWithCount:(NSInteger)count;

@end

/**
 搜索话题推荐用户
 
 */
@interface UMComRecommendTopicUsersRequest : UMComPullRequest
/**
 获取话题推荐用户请求初始化方法
 
 @param topicId 话题ID
 
 @param count 请求个数（暂时用于本地请求）
 
 @returns 获取话题推荐用户请求对象
 */
- (id)initWithTopicId:(NSString *)topicId count:(NSInteger)count;

@end
