//
//  UMComFeed.h
//  UMCommunity
//
//  Created by umeng on 15/11/6.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UMComManagedObject.h"

#define FeedStatusDeleted 2

@class UMComComment, UMComFeed, UMComLike, UMComTopic, UMComUser,UMComImageUrl;


@interface UMComFeed : UMComManagedObject

@property (nonatomic, retain) NSNumber * comments_count;//评论个数
@property (nonatomic, retain) NSString * create_time;//创建时间
@property (nonatomic, retain) NSString * custom;//自定义字段(创建Feed的时候加自定义的内容)
@property (nonatomic, retain) NSNumber * distance;//距离（在获取附近的Feed`UMComNearbyFeedsRequest`的时候返回）
@property (nonatomic, retain) NSString * feedID;//feedID feed的唯一ID
@property (nonatomic, retain) NSNumber * forward_count;//转发个数
@property (nonatomic, retain) NSNumber * has_collected;//是否收藏
@property (nonatomic, retain) NSString * is_follow;//是否关注
@property (nonatomic, retain) NSNumber * is_recommended;//是否推荐
@property (nonatomic, retain) NSNumber * is_top;//是否是全局置顶
@property (nonatomic, retain) NSNumber * liked;//是否已经点赞
@property (nonatomic, retain) NSNumber * likes_count;//点赞个数
@property (nonatomic, retain) id location;//NSDictionary 结构为{"geo_point" = ("116.361453","39.978916");name = "地点名称";}
@property (nonatomic, retain) NSString * origin_feed_id;//原始Feed的id，如果Feed不是转发，则为空
@property (nonatomic, retain) NSString * parent_feed_id;//转发Feed的id，如果Feed不是转发，则为空
@property (nonatomic, retain) NSNumber * seq;
@property (nonatomic, retain) NSNumber * seq_recommend;//(内部使用)
@property (nonatomic, retain) NSNumber * share_count;//分享次数
@property (nonatomic, retain) NSString * share_link;//分享链接
@property (nonatomic, retain) NSNumber * source_mark;//
@property (nonatomic, retain) NSNumber * status;//feed状态，大于或等与2表示已被删除，小于2表示正常
@property (nonatomic, retain) NSString * text;//feed的内容
@property (nonatomic, retain) NSString * title;//feed标题
@property (nonatomic, retain) NSNumber * type;//feed类型，1表示公告，0表示普通
@property (nonatomic, retain) NSNumber *permission;//字段值为111（Feed全部权限）或者100（删除feed权限）目前只有这两种权限可以操作feed,值为0则没有任何相关权限
@property (nonatomic, retain) NSNumber *ban_user;//用于判断是否可以对Feed创建者禁言,值为1表示可以禁言，值为0表示不能禁言
@property (nonatomic, retain) NSNumber *  tag;//判断Feed是否为精华，0为普通，1为精华
@property (nonatomic, retain) NSOrderedSet *image_urls;//feed图片url数组 保存的对象为`UMComImageUrl`
@property (nonatomic, retain) NSOrderedSet *comments;
@property (nonatomic, retain) UMComUser *creator;//feed创建者
@property (nonatomic, retain) NSOrderedSet *forward_feeds;
@property (nonatomic, retain) NSOrderedSet *likes;
@property (nonatomic, retain) UMComFeed *origin_feed;//原始Feed，如果Feed不是转发，则为空
@property (nonatomic, retain) NSOrderedSet *related_user;
@property (nonatomic, retain) NSOrderedSet *topics;

@end

@interface UMComFeed (CoreDataGeneratedAccessors)

- (void)insertObject:(UMComComment *)value inCommentsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCommentsAtIndex:(NSUInteger)idx;
- (void)insertComments:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCommentsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCommentsAtIndex:(NSUInteger)idx withObject:(UMComComment *)value;
- (void)replaceCommentsAtIndexes:(NSIndexSet *)indexes withComments:(NSArray *)values;
- (void)addCommentsObject:(UMComComment *)value;
- (void)removeCommentsObject:(UMComComment *)value;
- (void)addComments:(NSOrderedSet *)values;
- (void)removeComments:(NSOrderedSet *)values;
- (void)insertObject:(UMComFeed *)value inForward_feedsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromForward_feedsAtIndex:(NSUInteger)idx;
- (void)insertForward_feeds:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeForward_feedsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInForward_feedsAtIndex:(NSUInteger)idx withObject:(UMComFeed *)value;
- (void)replaceForward_feedsAtIndexes:(NSIndexSet *)indexes withForward_feeds:(NSArray *)values;
- (void)addForward_feedsObject:(UMComFeed *)value;
- (void)removeForward_feedsObject:(UMComFeed *)value;
- (void)addForward_feeds:(NSOrderedSet *)values;
- (void)removeForward_feeds:(NSOrderedSet *)values;
- (void)insertObject:(UMComLike *)value inLikesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLikesAtIndex:(NSUInteger)idx;
- (void)insertLikes:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLikesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLikesAtIndex:(NSUInteger)idx withObject:(UMComLike *)value;
- (void)replaceLikesAtIndexes:(NSIndexSet *)indexes withLikes:(NSArray *)values;
- (void)addLikesObject:(UMComLike *)value;
- (void)removeLikesObject:(UMComLike *)value;
- (void)addLikes:(NSOrderedSet *)values;
- (void)removeLikes:(NSOrderedSet *)values;
- (void)insertObject:(UMComUser *)value inRelated_userAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRelated_userAtIndex:(NSUInteger)idx;
- (void)insertRelated_user:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRelated_userAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRelated_userAtIndex:(NSUInteger)idx withObject:(UMComUser *)value;
- (void)replaceRelated_userAtIndexes:(NSIndexSet *)indexes withRelated_user:(NSArray *)values;
- (void)addRelated_userObject:(UMComUser *)value;
- (void)removeRelated_userObject:(UMComUser *)value;
- (void)addRelated_user:(NSOrderedSet *)values;
- (void)removeRelated_user:(NSOrderedSet *)values;
- (void)insertObject:(UMComTopic *)value inTopicsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTopicsAtIndex:(NSUInteger)idx;
- (void)insertTopics:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTopicsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTopicsAtIndex:(NSUInteger)idx withObject:(UMComTopic *)value;
- (void)replaceTopicsAtIndexes:(NSIndexSet *)indexes withTopics:(NSArray *)values;
- (void)addTopicsObject:(UMComTopic *)value;
- (void)removeTopicsObject:(UMComTopic *)value;
- (void)addTopics:(NSOrderedSet *)values;
- (void)removeTopics:(NSOrderedSet *)values;
@end
