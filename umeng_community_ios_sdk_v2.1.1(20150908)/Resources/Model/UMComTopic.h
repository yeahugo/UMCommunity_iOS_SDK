//
//  UMComTopic.h
//  UMCommunity
//
//  Created by Gavin Ye on 9/1/15.
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
@property (nonatomic, retain) NSNumber * is_focused;
@property (nonatomic, retain) NSNumber * is_recommend;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * save_time;
@property (nonatomic, retain) NSNumber * seq;
@property (nonatomic, retain) NSNumber * seq_recommend;
@property (nonatomic, retain) NSString * topicID;
@property (nonatomic, retain) NSOrderedSet *creator;
@property (nonatomic, retain) NSOrderedSet *feeds;
@end

@interface UMComTopic (CoreDataGeneratedAccessors)

- (void)insertObject:(UMComUser *)value inCreatorAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCreatorAtIndex:(NSUInteger)idx;
- (void)insertCreator:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCreatorAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCreatorAtIndex:(NSUInteger)idx withObject:(UMComUser *)value;
- (void)replaceCreatorAtIndexes:(NSIndexSet *)indexes withCreator:(NSArray *)values;
- (void)addCreatorObject:(UMComUser *)value;
- (void)removeCreatorObject:(UMComUser *)value;
- (void)addCreator:(NSOrderedSet *)values;
- (void)removeCreator:(NSOrderedSet *)values;
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
@end
