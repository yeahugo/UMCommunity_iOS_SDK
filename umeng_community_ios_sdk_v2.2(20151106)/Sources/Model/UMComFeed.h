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

@class UMComComment, UMComFeed, UMComLike, UMComTopic, UMComUser;


@interface UMComFeed : UMComManagedObject

@property (nonatomic, retain) NSNumber * comments_count;
@property (nonatomic, retain) NSString * create_time;
@property (nonatomic, retain) NSString * custom;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * feedID;
@property (nonatomic, retain) NSNumber * forward_count;
@property (nonatomic, retain) NSNumber * has_collected;
@property (nonatomic, retain) id images;
@property (nonatomic, retain) NSString * is_follow;
@property (nonatomic, retain) NSNumber * is_recommended;
@property (nonatomic, retain) NSNumber * is_top;
@property (nonatomic, retain) NSNumber * liked;
@property (nonatomic, retain) NSNumber * likes_count;
@property (nonatomic, retain) id location;
@property (nonatomic, retain) NSString * origin_feed_id;
@property (nonatomic, retain) NSString * parent_feed_id;
@property (nonatomic, retain) NSNumber * seq;
@property (nonatomic, retain) NSNumber * seq_recommend;
@property (nonatomic, retain) NSNumber * share_count;
@property (nonatomic, retain) NSString * share_link;
@property (nonatomic, retain) NSNumber * source_mark;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSOrderedSet *comments;
@property (nonatomic, retain) UMComUser *creator;
@property (nonatomic, retain) NSOrderedSet *forward_feeds;
@property (nonatomic, retain) NSOrderedSet *likes;
@property (nonatomic, retain) UMComFeed *origin_feed;
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
