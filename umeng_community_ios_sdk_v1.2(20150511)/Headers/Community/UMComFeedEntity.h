//
//  UMComFeedEntity.h
//  UMCommunity
//
//  Created by Gavin Ye on 1/6/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 消息实体，发送消息的方法使用此类构造消息内容
 
 */
@interface UMComFeedEntity : NSObject

/**
 消息文字内容
 
 */
@property (nonatomic, copy) NSString *text;

/**
 消息创建者的用户id
 
 */
@property (nonatomic, copy) NSString *uid;

/**
 消息的图片附件
 
 */
@property (nonatomic, strong) NSArray *images;

/**
 消息的相关话题
 
 */
@property (nonatomic, strong) NSArray *topicIDs;

/**
 @相关好友
 
 */
@property (nonatomic, strong) NSArray *atUserIds;

/**
 地理位置描述
 
 */
@property (nonatomic, copy) NSString *locationDescription;

/**
 地理位置坐标对象
 
 */
@property (nonatomic, strong) CLLocation *location;

/**
 账户类型
 */
@property (nonatomic, strong) NSNumber *type;

/**
 设置自定义数据
 
 */
+ (void)setCustomFeedContent:(NSString *)customContent;

/**
  设置自定义评论数据
 
 */
+ (void)setCustomCommentContent:(NSString *)customCommentContent;

/**
 返回自定义数据
 
 */
+ (NSString *)customContent;

/**
 返回自定义评论数据
 
 */
+ (NSString *)customCommentContent;

@end
