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
 用户登录请求
 
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
 创建新feed
 
 */
@interface UMComCreateFeedRequest : NSObject

/**
 发送新feed
 
 @param feed 消息，消息构造参考'UMComFeedEntity'
 @param result 结果
 */
+ (void)postWithFeed:(UMComFeedEntity *)feed
          completion:(PostResultResponse)result;

@end

/**
 转发消息请求
 
 */
@interface UMComForwardFeedReqeust : NSObject

/**
 转发消息
 
 @param feedId 消息id
 @param feed 新消息
 @param result 结果
 */
+ (void)forwardWithFeedId:(NSString *)feedId
                  newFeed:(UMComFeedEntity *)feed
               completion:(PostResponseResultResponse)result;

@end

/**
 评论消息请求
 
 */
@interface UMComCommentFeedRequest : NSObject

/**
 发送消息的评论
 
 @param feedId 消息Id
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
 @param feedId    消息Id
 @param result    返回结果
 */
+ (void)postDeleteWithComment:(NSString *)commentId feedId:(NSString *)feedId completion:(PostResponseResultResponse)result;


@end

/**
 喜欢消息请求
 
 */
@interface UMComLikeFeedRequest : NSObject

/**
 发送喜欢消息
 
 @param feedId 消息Id
 @param result 结果
 */
+ (void)postLikeWithFeedId:(NSString *)feedId completion:(PostResponseResultResponse)result;

/**
 取消喜欢消息
 
 @param feedId 消息Id 
 @param likeId 喜欢Id
 @param result 结果
 */
+ (void)postDisLikeWithFeedId:(NSString *)feedId completion:(PostResultResponse)result;

@end

/**
 举报消息请求
 
 */
@interface UMComSpamFeedRequest : NSObject

/**
 举报消息
 
 @param feedId 消息Id
 @param result 结果
 */
+ (void)spamWithFeedId:(NSString *)feedId
            completion:(PostResultResponse)result;

@end

/**
 删除消息请求
 
 */
@interface UMComDeleteFeedRequest : NSObject

/**
 删除消息
 
 @param feedId 消息Id
 @param result 结果
 */
+ (void)deleteWithFeedId:(NSString *)feedId completion:(PostResultResponse)result;

@end

/**
 获取未读消息个数
 
 */
@interface UMComUnreadFeedCountRequest : NSObject

/**
 获取未读消息个数
 
 @parma seq 返回的消息流列表第一个消息的seq属性值
 @param result 结果
 */
+ (void)fetchUnreadFeedCountWithSeq:(NSNumber *)seq result:(PostResponseResultResponse)result;

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
