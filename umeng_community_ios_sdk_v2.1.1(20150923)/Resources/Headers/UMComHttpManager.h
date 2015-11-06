//
//  UMComHttpManager.h
//  UMCommunity
//
//  Created by luyiyuan on 14/8/27.
//  Copyright (c) 2014年 luyiyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "UMComUserAccount.h"
#import "UMComTools.h"

@interface UMComHttpManager : NSObject


#pragma mark -
#pragma mark User


//用户登录
+ (void)userLogin:(UMComUserAccount *)userAccount response:(LoadDataCompletion)response;
//+ (void)userLogin:(NSString *)source sourceId:(NSString *)sourceId  response:(void (^)(id responseObject,NSError *error))response;

//关注和取消关注用户
+ (void)userFollow:(NSString *)uid isDelete:(BOOL)isDelete response:(void (^)(id responseObject,NSError *error))response;

//获取用户的档案
+ (void)userProfile:(NSString *)uid response:(void (^)(id responseObject,NSError *error))response;

//修改用户资料
+ (void)updateProfile:(UMComUserAccount *)userProfile response:(void (^)(id responseObject,NSError *error))response;

//修改用户头像
+ (void)updateProfileImage:(UIImage *)icon response:(void (^)(id responseObject,NSError *error))response;

#pragma mark -
#pragma mark topic

//话题关注/取消关注
+ (void)topicFocuse:(BOOL)focuse topicId:(NSString *)topicId response:(void (^)(id responseObject,NSError *error))response;

#pragma mark -
#pragma mark feeds


//创建 feed（发消息）
+ (void)createFeed:(NSDictionary *)parameters response:(void (^)(id responseObject,NSError *error))response;

+ (void)postImage:(UIImage *)image response:(void (^)(id responseObject,NSError *error))response;

//喜欢某feed
+ (void)likeFeed:(NSString *)feedId response:(void (^)(id responseObject,NSError *error))response;

//取消喜欢某feed
+ (void)disLikeFeed:(NSString *)feedId response:(void (^)(id responseObject,NSError *error))response;

//对某 feed 发表评论
+ (void)commentFeed:(NSString *)centent feedID:(NSString *)feedID replyUid:(NSString *)commentUid response:(void (^)(id responseObject,NSError *error))response;

//对某 feed 转发
+ (void)forwardFeed:(NSString *)feedId
            content:(NSString *)content
        relatedUids:(NSArray *)uids
       locationName:(NSString *)location
      locationPoint:(CLLocationCoordinate2D *)coordinate
           feedType:(NSNumber *)type
           response:(void (^)(id responseObject,NSError *error))response;

// 获取 地理位置数据
+ (void)locationNames:(CLLocationCoordinate2D)coordinate
             response:(void (^)(id responseObject,NSError *error))response;

//举报feed
+ (void)spamFeed:(NSString *)feedId response:(void (^)(id responseObject,NSError *error))response;

//举报用户
+ (void)spamUser:(NSString *)userId response:(void (^)(id responseObject,NSError *error))response;

//删除feed
+ (void)deleteFeed:(NSString *)feedId response:(void (^)(id responseObject,NSError *error))response;


//举报feed的评论
+ (void)spamComment:(NSString *)commentId response:(void (^)(id responseObject,NSError *error))response;


//删除feed的评论
+ (void)deleteComment:(NSString *)commentId feedId:(NSString *)feedId response:(void (^)(id responseObject,NSError *error))response;
#pragma mark -
#pragma mark comments

//获取未读feed消息数
+ (void)feedCountWithSeq:(NSNumber *)seq resultBlock:(void (^)(id responseObject,NSError *error))response;

//获取所有评论
+ (void)feedCommentsWithURL:(NSString *)feedCommentsURL response:(void (^)(id responseObject,NSError *error))response;


#pragma mark topic
+ (void)searchTopicWithKeyword:(NSString *)keyword response:(void (^)(id responseObject, NSError *error))response;

//统计分享信息
#pragma mark share
+ (void)shareCallback:(NSString *)platform feedId:(NSString *)feedId response:(void (^)(id responseObject, NSError *error))response;


//获取未读消息数
+ (void)unreadMessageCountWithUid:(NSString *)uid resultBlock:(void (^)(id responseObject,NSError *error))response;

//feed收藏操作
+ (void)favouriteFeedWithFeedId:(NSString *)feedId resultBlock:(void (^)(id responseObject, NSError *))response;

//取消收藏操作
+ (void)disFavouriteFeedWithFeedId:(NSString *)feedId resultBlock:(void (^)(id responseObject, NSError *))response;

//检查用户名是否合法
+ (void)checkUserName:(NSString *)name resultBlock:(void (^)(id responseObject, NSError *))response;

@end
