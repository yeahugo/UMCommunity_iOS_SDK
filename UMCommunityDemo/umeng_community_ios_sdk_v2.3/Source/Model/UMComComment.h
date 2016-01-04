//
//  UMComComment.h
//  UMCommunity
//
//  Created by umeng on 15/11/2.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UMComManagedObject.h"

@class UMComFeed, UMComUser,UMComImageUrl;

@interface UMComComment : UMComManagedObject

@property (nonatomic, retain) NSString * commentID;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * create_time;
@property (nonatomic, retain) NSString * custom;
@property (nonatomic, retain) NSNumber * liked;
@property (nonatomic, retain) NSNumber * likes_count;
@property (nonatomic, retain) NSNumber * seq;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * floor;
@property (nonatomic, retain) NSNumber *permission;//字段值为111（Comment全部权限）或者100（删除feed权限）目前只有这两种权限可以操作feed,值为0则没有任何相关权限
@property (nonatomic, retain) NSNumber *ban_user;//用于判断是否可以对评论的用户禁言,值为1表示可以禁言，值为0表示不能禁言
@property (nonatomic, retain) UMComUser *creator;
@property (nonatomic, retain) UMComFeed *feed;
@property (nonatomic, retain) UMComUser *reply_user;
@property (nonatomic, retain) UMComComment *reply_comment;
@property (nonatomic, retain) NSOrderedSet *image_urls;

@end
