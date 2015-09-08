//
//  UMComPostDataRequest.h
//  UMCommunity
//
//  Created by Gavin Ye on 12/22/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UMComUserAccount;
@class UMComFeedEntity;
@class UMComFetchRequest;
@class UMComPullRequest;

/**
 返回结果回调
 
 */
typedef void (^PostResultResponse)(NSError *error);

/**
 带有数据的返回结果回调
 
 */
typedef void (^PostResponseResultResponse)(id responseObject, NSError *error);

/**
 用户登录请求，直接把userAccount的数据上传到server，返回上传的用户资料
 
 */
@interface UMComLoginRequest : NSObject

/**
 提交登录用户数据
 
 @param userAccount 登录用户
 @param result 返回结果
 */
+ (void)postWithUser:(UMComUserAccount *)userAccount completion:(PostResultResponse)result;

@end

/**
 更新登录用户请求
 
 */
@interface UMComUpdateProfileRequest : NSObject

/**
 更新登录用户数据
 
 @param userAccount 登录用户
 @param result 返回结果
 */
+ (void)updateWithUser:(UMComUserAccount *)userAccount completion:(PostResultResponse)result;

@end

/**
 更新用户头像请求
 
 */
@interface UMComUpdateProfileImageRequest : NSObject

/**
 更新用户头像
 
 @param image 头像图片
 @param result 结果
 */
+ (void)updateWithProfileImage:(UIImage *)image completion:(PostResultResponse)result;

@end

/**
 创建新feed,例如
 
 ```
 UMComFeedEntity *feedEntity = [[UMComFeedEntity alloc] init];
 NSString *dateString = [[NSDate date] description];
 NSString *feedString = [NSString stringWithFormat:@"测试发送feed消息 %@",dateString];
 feedEntity.text = feedString;
 [UMComCreateFeedRequest postWithFeed:feedEntity completion:^(NSError *error) {
 }];
 ```
 
 */
@interface UMComCreateFeedRequest : NSObject

/**
 发送新feed
 
 @param feed Feed，Feed构造参考'UMComFeedEntity'
 @param result 结果
 */
+ (void)postWithFeed:(UMComFeedEntity *)feed
          completion:(PostResponseResultResponse)result;

@end

/**
 转发Feed请求
 
 */
@interface UMComForwardFeedReqeust : NSObject

/**
 转发Feed
 
 @param feedId 被转发的Feedid
 @param feed 新Feed，只有`text`和`atUserIds`有效
 @param result 结果
 */
+ (void)forwardWithFeedId:(NSString *)feedId
                  newFeed:(UMComFeedEntity *)feed
               completion:(PostResponseResultResponse)result;

@end

/**
 评论Feed请求
 
 */
@interface UMComCommentFeedRequest : NSObject

/**
 发送Feed的评论
 
 @param feedId FeedId
 @param commentContent 评论内容
 @param userId 回复的用户id
 @param result 结果
 */
+ (void)postWithSourceFeedId:(NSString *)feedId
              commentContent:(NSString *)commentContent
                 replyUserId:(NSString *)userId
                  completion:(PostResultResponse)result;

/**
 举报feed的评论
 
 @param commentId 评论Id
 @param result    返回结果
 */
+ (void)postSpamWithComment:(NSString *)commentId completion:(PostResponseResultResponse)result;

/**
 删除feed的评论
 
 @param commentId 评论Id
 @param feedId    FeedId
 @param result    返回结果
 */
+ (void)postDeleteWithComment:(NSString *)commentId feedId:(NSString *)feedId completion:(PostResponseResultResponse)result;


@end

/**
 点赞Feed请求
 
 */
@interface UMComLikeFeedRequest : NSObject

/**
 发送Feed 点赞请求
 
 @param feedId FeedId
 @param result 结果
 */
+ (void)postLikeWithFeedId:(NSString *)feedId completion:(PostResponseResultResponse)result;

/**
 取消点赞Feed
 
 @param feedId FeedId 
 @param likeId 点赞Id
 @param result 结果
 */
+ (void)postDisLikeWithFeedId:(NSString *)feedId completion:(PostResultResponse)result;

@end

/**
 举报Feed请求
 
 */
@interface UMComSpamFeedRequest : NSObject

/**
 举报Feed
 
 @param feedId FeedId
 @param result 结果
 */
+ (void)spamWithFeedId:(NSString *)feedId
            completion:(PostResultResponse)result;

@end

/**
 举报用户
 
 */
@interface UMComSpamUserRequest : NSObject

/**
 封禁用户
 
 @param userId 用户Id
 @param result 结果
 */
+ (void)spamWithUserId:(NSString *)userId
            completion:(PostResultResponse)result;

@end

/**
 删除Feed请求
 
 */
@interface UMComDeleteFeedRequest : NSObject

/**
 删除Feed
 
 @param feedId FeedId
 @param result 结果
 */
+ (void)deleteWithFeedId:(NSString *)feedId completion:(PostResultResponse)result;

@end



/**
 添加关注用户请求
 
 */
@interface UMComFollowUserRequest : NSObject

/**
 关注用户
 
 @param userId 用户Id
 @param result 结果
 */
+ (void)postFollowerWithUserId:(NSString *)userId completion:(PostResultResponse)result;

/**
 取消关注用户
 
 @param userId 用户Id
 @param result 结果
 */
+ (void)postDisFollowerWithUserId:(NSString *)userId completion:(PostResultResponse)result;

@end

/**
 添加关注话题请求
 
 */
@interface UMComFollowTopicRequest : NSObject

/**
 关注话题
 
 @param topicId 话题Id
 @param result 结果
 */
+ (void)postFollowerWithTopicId:(NSString *)topicId completion:(PostResultResponse)result;

/**
 取消关注话题
 
 @param topicId 话题Id
 @param result 结果
 */
+ (void)postDisFollowerWithTopicId:(NSString *)topicId completion:(PostResultResponse)result;

@end

/**
 发送统计分享次数
 
 @param feedId 分享成功的feedId
 @param result 结果
 */
@interface UMComShareStaticsRequest : NSObject

+ (void)postShareStaticsWithPlatformName:(NSString *)platform feedId:(NSString *)feedId completion:(PostResultResponse)result;

@end



/**
 feed收藏操作和取消收藏操作
 
 */
@interface UMComFavouriteFeedRequest : NSObject

/**
 feed收藏操作和取消收藏操作
 
 @param feedId      feed的ID
 @param isFavourite 是否收藏，YES为收藏操作，为NO则为取消收藏操作
 @param result      结果
 */
+ (void)favouriteFeedWithFeedId:(NSString *)feedId isFavourite:(BOOL)isFavourite completion:(PostResultResponse)result;

@end


/**
 检查用户名合法接口
 
 */
@interface UMComCheckUserNameRequest : NSObject
/**
 检查用户名合法接口
 
 @param name        用户名
 @param result      成功: {‘ret’:’ok’};
                    失败: {error_code:xxx},
                    error_code对应表：{10010 户名长度错误
                                     10012 用户名敏感
                                     10016  用户名格式错误}
 */
+ (void)checkUserName:(NSString *)name completion:(PostResultResponse)completion;

@end



