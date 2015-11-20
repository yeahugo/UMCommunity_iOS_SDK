//
//  UMComUser.h
//  UMCommunity
//
//  Created by Gavin Ye on 9/15/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UMComManagedObject.h"

@class UMComAlbum, UMComComment, UMComFeed, UMComLike, UMComTopic, UMComUser;

@interface UMComUser : UMComManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSNumber * atype;
@property (nonatomic, retain) NSNumber * be_at_count;
@property (nonatomic, retain) NSNumber * comment_count;
@property (nonatomic, retain) NSString * custom;
@property (nonatomic, retain) NSNumber * fans_count;
@property (nonatomic, retain) NSNumber * feed_count;
@property (nonatomic, retain) NSNumber * following_count;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSNumber * has_followed;
@property (nonatomic, retain) id icon_url;
@property (nonatomic, retain) NSNumber * is_recommended;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSString * level_title;
@property (nonatomic, retain) NSNumber * like_count;
@property (nonatomic, retain) NSNumber * liked_count;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id permissions;
@property (nonatomic, retain) NSNumber * post_count;
@property (nonatomic, retain) NSNumber * registered;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * sum;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) UMComAlbum *album;
@property (nonatomic, retain) NSOrderedSet *comment;
@property (nonatomic, retain) NSOrderedSet *fans;
@property (nonatomic, retain) NSOrderedSet *feeds;
@property (nonatomic, retain) NSOrderedSet *followers;
@property (nonatomic, retain) NSOrderedSet *likes;
@property (nonatomic, retain) NSOrderedSet *related_feeds;
@property (nonatomic, retain) NSOrderedSet *reply_comments;
@property (nonatomic, retain) NSOrderedSet *topics;
@end

@interface UMComUser (CoreDataGeneratedAccessors)

- (void)insertObject:(UMComComment *)value inCommentAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCommentAtIndex:(NSUInteger)idx;
- (void)insertComment:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCommentAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCommentAtIndex:(NSUInteger)idx withObject:(UMComComment *)value;
- (void)replaceCommentAtIndexes:(NSIndexSet *)indexes withComment:(NSArray *)values;
- (void)addCommentObject:(UMComComment *)value;
- (void)removeCommentObject:(UMComComment *)value;
- (void)addComment:(NSOrderedSet *)values;
- (void)removeComment:(NSOrderedSet *)values;
- (void)insertObject:(UMComUser *)value inFansAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFansAtIndex:(NSUInteger)idx;
- (void)insertFans:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFansAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFansAtIndex:(NSUInteger)idx withObject:(UMComUser *)value;
- (void)replaceFansAtIndexes:(NSIndexSet *)indexes withFans:(NSArray *)values;
- (void)addFansObject:(UMComUser *)value;
- (void)removeFansObject:(UMComUser *)value;
- (void)addFans:(NSOrderedSet *)values;
- (void)removeFans:(NSOrderedSet *)values;
- (void)insertObject:(UMComFeed *)value inFeedsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFeedsAtIndex:(NSUInteger)idx;
- (void)insertFeeds:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFeedsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFeedsAtIndex:(NSUInteger)idx withObject:(UMComFeed *)value;
- (void)replaceFeedsAtIndexes:(NSIndexSet *)indexes withFeeds:(NSArray *)values;
- (void)addFeedsObject:(UMComFeed *)value;
- (void)removeFeedsObject:(UMComFeed *)value;
- (void)addFeeds:(NSOrderedSet *)values;
- (void)removeFeeds:(NSOrderedSet *)values;
- (void)insertObject:(UMComUser *)value inFollowersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFollowersAtIndex:(NSUInteger)idx;
- (void)insertFollowers:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFollowersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFollowersAtIndex:(NSUInteger)idx withObject:(UMComUser *)value;
- (void)replaceFollowersAtIndexes:(NSIndexSet *)indexes withFollowers:(NSArray *)values;
- (void)addFollowersObject:(UMComUser *)value;
- (void)removeFollowersObject:(UMComUser *)value;
- (void)addFollowers:(NSOrderedSet *)values;
- (void)removeFollowers:(NSOrderedSet *)values;
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
- (void)insertObject:(UMComFeed *)value inRelated_feedsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRelated_feedsAtIndex:(NSUInteger)idx;
- (void)insertRelated_feeds:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRelated_feedsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRelated_feedsAtIndex:(NSUInteger)idx withObject:(UMComFeed *)value;
- (void)replaceRelated_feedsAtIndexes:(NSIndexSet *)indexes withRelated_feeds:(NSArray *)values;
- (void)addRelated_feedsObject:(UMComFeed *)value;
- (void)removeRelated_feedsObject:(UMComFeed *)value;
- (void)addRelated_feeds:(NSOrderedSet *)values;
- (void)removeRelated_feeds:(NSOrderedSet *)values;
- (void)insertObject:(UMComComment *)value inReply_commentsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromReply_commentsAtIndex:(NSUInteger)idx;
- (void)insertReply_comments:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeReply_commentsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInReply_commentsAtIndex:(NSUInteger)idx withObject:(UMComComment *)value;
- (void)replaceReply_commentsAtIndexes:(NSIndexSet *)indexes withReply_comments:(NSArray *)values;
- (void)addReply_commentsObject:(UMComComment *)value;
- (void)removeReply_commentsObject:(UMComComment *)value;
- (void)addReply_comments:(NSOrderedSet *)values;
- (void)removeReply_comments:(NSOrderedSet *)values;
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
