//
//  UMComFeed+UMComManagedObject.h
//  UMCommunity
//
//  Created by Gavin Ye on 11/12/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComFeed.h"

void printFeed ();

typedef void(^UMComFeedOperationComplection)(id responseObject, NSError *error);

@interface UMComFeed (UMComManagedObject)

/**
 *通过用户名从feed相关用户中查找对应的用户
 
 @param name 用户名
 *return 返回一个UMComUser对象
 */
- (UMComUser *)relatedUserWithUserName:(NSString *)name;

/**
 *通过话题名称从feed中查找对应的话题
 
 @param topicName 话题名称
 *return 返回一个UMComTopic对象
 */
- (UMComTopic *)relatedTopicWithTopicName:(NSString *)topicName;

///**
// *点赞或取消点赞，当前feed为已经点赞，则执行取消点赞方法，否则执行点赞方法
// 
// @param completion 点赞或取消点赞结果回调block
// */
//- (void)feedLikedWithCompletion:(UMComFeedOperationComplection)complection;
//
///**
// *收藏或取消收藏,当前feed为已经收藏，则执行取消收藏方法，否则执行收藏方法
// 
// @param completion 收藏或取消收藏结果回调block
// */
//- (void)feedHasCollectedWithCompletion:(UMComFeedOperationComplection)completion;
///**
// *举报feed
// 
// @param completion 举报结果回调block
// */
//- (void)feedSpamWithCompletion:(UMComFeedOperationComplection)completion;
//
///**
// *删除feed的一条评论
// 
// @param comment 要删除的评论
// @param completion 删除结果处理block
// */
//- (void)feedDeleteComment:(UMComComment *)comment completion:(UMComFeedOperationComplection)completion;
//
//
///**
// *评论feed
// 
// @param content 评论内容
// @param comment 回复的评论，当comment不为空时表示回复某人的评论，否则表示直接评轮
// @param completion 评论结果处理block
// */
//- (void)feedAddNewCommentWithContent:(NSString *)content replyComment:(UMComComment *)comment completion:(UMComFeedOperationComplection)completion;



@end

@interface ImagesArray : NSValueTransformer

@end

@interface LocationDictionary : NSValueTransformer

@end