//
//  UMComTopic.h
//  UMCommunity
//
//  Created by Gavin Ye on 9/15/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UMComManagedObject.h"

@class UMComFeed, UMComUser;

@interface UMComTopic : UMComManagedObject

@property (nonatomic, retain) NSString * custom;
@property (nonatomic, retain) NSString * descriptor;
@property (nonatomic, retain) NSNumber * fan_count;
@property (nonatomic, retain) NSNumber * feed_count;
@property (nonatomic, retain) NSString * icon_url;
@property (nonatomic, retain) id image_urls;
@property (nonatomic, retain) NSNumber * is_focused;
@property (nonatomic, retain) NSNumber * is_recommend;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * save_time;
@property (nonatomic, retain) NSNumber * seq;
@property (nonatomic, retain) NSNumber * seq_recommend;
@property (nonatomic, retain) NSString * topicID;
@property (nonatomic, retain) NSOrderedSet *feeds;
@property (nonatomic, retain) NSOrderedSet *follow_users;
@end

@interface UMComTopic (CoreDataGeneratedAccessors)

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
- (void)insertObject:(UMComUser *)value inFollow_usersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFollow_usersAtIndex:(NSUInteger)idx;
- (void)insertFollow_users:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFollow_usersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFollow_usersAtIndex:(NSUInteger)idx withObject:(UMComUser *)value;
- (void)replaceFollow_usersAtIndexes:(NSIndexSet *)indexes withFollow_users:(NSArray *)values;
- (void)addFollow_usersObject:(UMComUser *)value;
- (void)removeFollow_usersObject:(UMComUser *)value;
- (void)addFollow_users:(NSOrderedSet *)values;
- (void)removeFollow_users:(NSOrderedSet *)values;
@end
