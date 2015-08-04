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
#import "UMComHttpPagesManager.h"

typedef enum {
    commentorderByDefault = 0,
    commentorderByTimeDesc = 1,
    commentorderByTimeAsc = 2
}UMComCommentOrderType;

typedef enum {
    UMComTimeLineTypeDefault = 0,
    UMComTimeLineTypeOrigin = 1,
    UMComTimeLineTypeForward = 2
}UMComTimeLineType;

@class UMComFetchRequest;

@class CLLocation;

#define kFetchLimit 20
#define kFetchCommentLimit 100

/**
 删除本地Feed返回
 
 */
typedef void (^DeleteCoreDataResponse)(NSArray *deleteData,NSError *error);

/**
 获取本地Feed返回
 
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
 获取服务器端数据返回
 
 */
typedef void (^RequestServerDataResponse)(NSDictionary *responseObject, NSError *error);

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

@end

/**
 拉取数据的请求
 
 */
@interface UMComPullRequest : NSFetchedResultsController<UMComPullResultDelegate>

- (id)initWithFetchRequest:(UMComFetchRequest *)request;

@end

/**
 获取所有Feed的请求
 
 */
@interface UMComAllFeedsRequest : UMComPullRequest

/**
 获取Feed的初始化方法
 
 @param count 数量
 
 @returns 初始化请求对象
 */
- (id)initWithCount:(NSInteger)count;

@end

/**
 获取社区最新的200条数据
 
 */
@interface UMComAllNewFeedsRequest : UMComPullRequest

/**
 获取Feed的初始化方法
 
 @param count 数量
 
 @returns 初始化请求对象
 */
- (id)initWithCount:(NSInteger)count;

@end

/**
 话题所有feed的排序类型
 
 */
typedef enum{
    UMComFeedSortTypeDefault,
    UMComFeedSortTypeComment,   //评论时间
    UMComFeedSortTypeLike,      //赞时间
    UMComFeedSortTypeForward,     //转发时间
    UMComFeedSortTypeAction,       //评论或赞或转发时间
}UMComFeedSortType;

/**
 获取话题聚合Feed的请求
 
 */
@interface UMComTopicFeedsRequest : UMComPullRequest

/**
 话题聚合Feed请求的初始化方法
 
 @param topicId 话题Id
 @param count 数量
 @param order 排序方式，默认传UMComFeedSortTypeDefault
 @param isReverse 是否按照倒序排序，即最新的排在前面,如果order传UMComFeedSortTypeDefault，不支持正序
 
 @returns 话题聚合请求对象
 */
- (id)initWithTopicId:(NSString *)topicId
                count:(NSInteger)count
                order:(UMComFeedSortType)order
            isReverse:(BOOL)isReverse;

@end

/**
 朋友圈Feed请求
 
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
 获取用户发送的Feed请求
 
 */
@interface UMComUserFeedsRequest : UMComPullRequest

/**
 获取用户发送的Feed的初始化方法
 
 @param uid 用户id
 @param count Feed数量
 @param type 获取用户feeds类型，原创或者转发，默认可以传`UMComTimeLineTypeDefault`
 
 @returns 获取用户发送Feed的请求对象
 */
- (id)initWithUid:(NSString *)uid count:(NSInteger)count type:(UMComTimeLineType)type;

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
 @param sourceUids 自定义用户登录的key和id
 
 @returns 获取用户详细信息请求对象
 */
- (id)initWithUid:(NSString *)uid sourceUid:(NSDictionary *)sourceUids;

@end

/**
 获取Feed所有评论请求
 
 */
@interface UMComFeedCommentsRequest : UMComPullRequest

/**
 获取Feed所有评论的初始化方法
 
 @param feedId FeedId
 @param count 评论数量
 @param order: desc/asc 时间正序倒序 不传默认为desc即倒序
 
 @returns 获取Feed所有评论请求对象
 */
- (id)initWithFeedId:(NSString *)feedId order:(UMComCommentOrderType)orderType count:(NSInteger)count;

@end

/**
 获取Feed所有赞的请求
 
 */
@interface UMComFeedLikesRequest : UMComPullRequest

/**
 获取Feed所有赞请求初始化方法
 
 @param feedId FeedId
 @param count 数量
 
 @returns 获取Feed所有赞请求对象
 */
- (id)initWithFeedId:(NSString *)feedId count:(NSInteger)count;

@end

/**
 获取一个Feed的请求
 
 */
@interface UMComOneFeedRequest : UMComPullRequest

/**
 获取一个Feed请求的初始化方法
 
 @param feedId FeedId
 @param viewExtra sdk内部参数，用作接收消息推送之后获取feed详情数据，上传给server，一般传nil
 
 @returns 获取一个Feed请求对象
 */
- (id)initWithFeedId:(NSString *)feedId
           viewExtra:(NSString *)viewExtra;

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
 搜索推荐Feed
 
 */
@interface UMComRecommendFeedsRequest : UMComPullRequest
/**
 获取推荐Feed初始化方法
 
 @param count 请求个数（暂时用于本地请求）
 
 @returns 获取推荐Feed请求对象
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
 返回该话题对应的热门用户
 
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

/**
 获取用户相册
 
 */
@interface UMComUserAlbumRequest : UMComPullRequest

/**
 获取相册
 
 @param count 请求个数
 @param fuid 请求的用户uid
 
 @returns 获取用户相册的请求对象
 */
- (id)initWithCount:(NSInteger)count fuid:(NSString *)fuid;

@end


/**
 获取附近的feeds
 
 */
@interface UMComNearbyFeedsRequest : UMComPullRequest

/**
 获取附近的feeds
 
 @param location 位置信息
 @param count 请求个数
 
 @returns 获取附近feedsFeed的请求对象
 */
- (id)initWithLocation:(CLLocation *)location count:(NSInteger)count;

@end


/**
 获取用户被点赞的列表
 
 */
@interface UMComUserLikesReceivedRequest : UMComPullRequest

/**
 获取用户被点赞的列表
 
 @param uid 用户uid
 @param count 请求个数
 
 @returns 获取用户被点赞的列表的请求对象
 */
- (id)initWithUid:(NSString *)uid count:(NSInteger)count;

@end


/**
 获取用户被评论的列表
 
 */
@interface UMComUserCommentsReceivedRequest : UMComPullRequest

/**
 获取用户被评论的列表
 
 @param uid 用户uid
 @param count 请求个数
 
 @returns 获取用户被评论的列表的请求对象
 */
- (id)initWithUid:(NSString *)uid count:(NSInteger)count;

@end


/**
 根据feedId获取feed列表，每次最多20条，过多返回错误码20011
 
 @param feedIds feedId
 
 */
@interface UMComFeedsByFeedIdsRequest : UMComPullRequest

- (id)initWithFeedIds:(NSArray *)feedIds;

@end

/**
 获取用户发出的评论列表
 
 */
@interface UMComUserCommentsSentRequest : UMComPullRequest

/**
 获取用户发出的评论列表
 
 @param uid 用户uid
 @param count 请求个数
 
 @returns 获取用户的评论列表的请求对象
 */
- (id)initWithUid:(NSString *)uid count:(NSInteger)count;

@end


/**
 获取用户被@的feeds
 
 */
@interface UMComUserFeedBeAtRequest : UMComPullRequest

/**
 获取用户被@的feeds
 
 @param uid 用户uid
 @param count 请求个数
 
 @returns  获取用户被@的feedsFeed的请求对象
 */
- (id)initWithUid:(NSString *)uid count:(NSInteger)count;

@end



/**
 获取管理员的通知列表
 
 */
@interface UMComUserNotificationRequest : UMComPullRequest

/**
 获取管理员的通知列表
 
 @param uid 用户uid
 @param count 请求个数
 
 @returns  获取管理员的通知列表的请求对象
 */
- (id)initWithUid:(NSString *)uid count:(NSInteger)count;

@end


/**
 获取用户收藏列表
 
 */
@interface UMComUserFavouritesRequest : UMComPullRequest

/**
 获取用户收藏列表
 
 @param uid 用户uid
 @param count 请求个数
 
 @returns  获取用户收藏列表的请求对象
 */
- (id)initWithUid:(NSString *)uid count:(NSInteger)count;

@end


/**
 获取用户未读消息个数
 
 */
@interface UMComUserUnreadMeassageRequest : NSObject

/**
 获取用户未读消息个数
 
 @param uid 用户uid
 @param result 请求结果处理
 
 @returns  void
 */
+ (void)requestUnreadMessageCountWithUid:(NSString *)uid result:(RequestServerDataResponse)result;
@end


