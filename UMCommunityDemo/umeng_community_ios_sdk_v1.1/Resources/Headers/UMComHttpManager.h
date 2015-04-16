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

//喜欢某feed
+ (void)likeFeed:(NSString *)feedId response:(void (^)(id responseObject,NSError *error))response;

//取消喜欢某feed
+ (void)disLikeFeed:(NSString *)feedId likeId:(NSString *)likeId response:(void (^)(id responseObject,NSError *error))response;

//对某 feed 发表评论
+ (void)commentFeed:(NSString *)centent feedID:(NSString *)feedID replyUid:(NSString *)commentUid response:(void (^)(id responseObject,NSError *error))response;

//对某 feed 转发
+ (void)forwardFeed:(NSString *)feedId
            content:(NSString *)content
        relatedUids:(NSArray *)uids
       locationName:(NSString *)location
      locationPoint:(CLLocationCoordinate2D *)coordinate
           response:(void (^)(id responseObject,NSError *error))response;

// 获取 地理位置数据
+ (void)locationNames:(CLLocationCoordinate2D)coordinate
             response:(void (^)(id responseObject,NSError *error))response;

//举报feed
+ (void)spamFeed:(NSString *)feedId response:(void (^)(id responseObject,NSError *error))response;


//删除feed
+ (void)deleteFeed:(NSString *)feedId response:(void (^)(id responseObject,NSError *error))response;
#pragma mark -
#pragma mark comments

//获取未读feed消息数
+ (void)feedCount:(void (^)(id responseObject,NSError *error))response;

//获取所有评论
+ (void)feedCommentsWithURL:(NSString *)feedCommentsURL response:(void (^)(id responseObject,NSError *error))response;


#pragma mark topic
+ (void)searchTopicWithKeyword:(NSString *)keyword response:(void (^)(id responseObject, NSError *error))response;
@end
