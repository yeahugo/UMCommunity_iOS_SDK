//
//  UMComPostDataRequest.h
//  UMCommunity
//
//  Created by Gavin Ye on 12/22/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMComTools.h"

@class UMComUserAccount;
@class UMComFeedEntity;
@class UMComUser;
@class UMComTopic;
@class UMComFeed;
@class UMComComment;

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
@interface UMComPushRequest : NSObject

#pragma mark - User
/**
 提交登录用户数据
 
 @param userAccount 登录用户
 @param result 返回结果,responseObject是包含登录完成的`UMComUser`对象的NSArray
 */
+ (void)loginWithUser:(UMComUserAccount *)userAccount
           completion:(PostResponseResultResponse)result;


/**
 更新登录用户数据
 
 @param userAccount 登录用户
 @param result 返回结果
 */
+ (void)updateWithUser:(UMComUserAccount *)userAccount
            completion:(PostResultResponse)result;
//
//
///**
// 更新用户头像
// 
// @param image 头像图片
// @param result 结果
// */
//+ (void)updateWithProfileImage:(UIImage *)image
//                    completion:(PostResultResponse)result;


/**
 举报用户
 
 @param userId 用户Id
 @param result 结果
 */
+ (void)spamWithUser:(UMComUser *)user
          completion:(PostResultResponse)result;



/**
 关注用户或者取消关注
 
 @param user 用户
 @param isFollow 关注用户或者取消关注
 @param result 结果
 */
+ (void)followerWithUser:(UMComUser *)user
                isFollow:(BOOL)isFollow
              completion:(PostResultResponse)result;




/**
 检查用户名合法接口
 
 @param name           用户名
 @param userNameType   用户名规范，`userNameNoBlank`没有空格，`userNameNoRestrict`没有限制
 @param userNameLength 用户名长度，`userNameLengthDefault`默认长度，`userNameLengthNoRestrict`没有长度限制
 @param result         error的code :
                       10010 户名长度错误
                       10012 用户名敏感
                       10016  用户名格式错误
 */
+ (void)checkUserName:(NSString *)name
         userNameType:(UMComUserNameType)userNameType
       userNameLength:(UMComUserNameLength)userNameLength
           completion:(PostResultResponse)completion;


/**
 获取初始化数据
 
 @param result 初始化数据结果，`responseObject`的key`config.feed_length`为设置最大feed文字内容
               `responseObject`的key`message_box`是各个未读消息数，`message_box`下面的`total`为所有未读通知数，key为`notice`为管理员未读通知数，`comment`为被评论未读通知数，`at`为被@未读通知数，`like`为被点赞未读通知数
 
 */
+ (void)requestConfigDataWithResult:(PostResponseResultResponse)result;

#pragma mark - Feed

/**
 创建新feed,例如
 
 ```
 UMComFeedEntity *feedEntity = [[UMComFeedEntity alloc] init];
 NSString *dateString = [[NSDate date] description];
 NSString *feedString = [NSString stringWithFormat:@"测试发送feed消息 %@",dateString];
 feedEntity.text = feedString;
 [UMComPushRequest postWithFeed:feedEntity completion:^(NSError *error) {
 }];
 ```
 
 @param newFeed newFeed构造参考'UMComFeedEntity'
 @param result 结果
 */
+ (void)postWithFeed:(UMComFeedEntity *)newFeed
          completion:(PostResponseResultResponse)result;


/**
 转发Feed
 
 @param feed 被转发的Feed
 @param newFeed 新Feed，只有`text`和`atUsers`有效，newFeed构造参考'UMComFeedEntity'
 @param result 结果
 */
+ (void)forwardWithFeed:(UMComFeed *)feed
                newFeed:(UMComFeedEntity *)newFeed
             completion:(PostResponseResultResponse)result;


/**
 发送Feed 点赞或取消点赞请求
 
 @param feed 被赞的Feed
 @param isLiek 当isLike为YES时为点赞反之取消点赞
 @param result 结果
 */
+ (void)likeWithFeed:(UMComFeed *)feed
              isLike:(BOOL)isLike
          completion:(PostResponseResultResponse)result;

/**
 举报Feed
 
 @param feed Feed
 @param result 结果
 */
+ (void)spamWithFeed:(UMComFeed *)feed
          completion:(PostResultResponse)result;

/**
 删除Feed
 
 @param feed 被删除的Feed
 @param result 结果
 */
+ (void)deleteWithFeed:(UMComFeed *)feed
            completion:(PostResultResponse)result;

/**
 feed收藏操作和取消收藏操作
 
 @param feed        被收藏的 feed
 @param isFavourite 是否收藏，YES为收藏操作，为NO则为取消收藏操作
 @param result      结果
 */
+ (void)favouriteFeedWithFeed:(UMComFeed *)feed
                  isFavourite:(BOOL)isFavourite
                   completion:(PostResultResponse)result;

/**
 发送统计分享次数
 
 @param feed 分享成功的feed
 @param result 结果
 */
+ (void)postShareStaticsWithPlatformName:(NSString *)platform
                                    feed:(UMComFeed *)feed
                              completion:(PostResultResponse)result;

/**
 获取未读feed个数
 
 @parma seq 返回的Feed流列表第一个Feed的seq属性值
 @param result 结果
 */
+ (void)fetchUnreadFeedCountWithSeq:(NSNumber *)seq
                             result:(PostResponseResultResponse)result;

#pragma mark - Comment

/**
 发送Feed带自定义字段的评论
 
 @param feed   被评论的Feed
 @param commentContent 评论内容
 @param replyUser 回复的用户
 @param commentCustomContent 评论自定义字段
 @param images 评论附带图片（images中的对象可以是UIIamge类对象，也可以是UMComImageModel类对象）
 @param result 结果
 */
+ (void)postWithSourceFeed:(UMComFeed *)feed
            commentContent:(NSString *)commentContent
                 replyUser:(UMComUser *)replyUser
      commentCustomContent:(NSString *)commentCustomContent
                    images:(NSArray *)images
                completion:(PostResultResponse)result;
/**
 举报feed的评论
 
 @param commentId 评论Id
 @param result    返回结果
 */
+ (void)spamWithComment:(UMComComment *)comment
             completion:(PostResponseResultResponse)result;

/**
 删除feed的评论
 
 @param comment   删除的评论
 @param feed      评论的Feed
 @param result    返回结果
 */
+ (void)deleteWithComment:(UMComComment *)comment
                     feed:(UMComFeed *)feed
               completion:(PostResponseResultResponse)result;

/**
 评论点赞或取消点赞
 
 @param commentId 评论Id
 @param isLike    是否点赞，如果点赞则为YES,取消点赞则为NO
 @param result    返回结果
 */
+ (void)likeWithComment:(UMComComment *)comment
                 isLike:(BOOL)isLike
             completion:(PostResponseResultResponse)result;

#pragma mark - Topic

/**
 关注话题
 
 @param topic 关注或取消关注的话题
 @param isFollower 是否关注该话题,或者取消关注话题，isFollower为YES表示关注，否则取消关注
 @param result 结果
 */
+ (void)followerWithTopic:(UMComTopic *)topic
               isFollower:(BOOL)isFollower
               completion:(PostResultResponse)result;
@end



