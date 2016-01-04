//
//  UMComTopicType.h
//  UMCommunity
//
//  Created by umeng on 15/11/24.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UMComManagedObject.h"

@class UMComTopic;

@interface UMComTopicType : UMComManagedObject

@property (nonatomic, retain) NSString * category_id;
@property (nonatomic, retain) NSString * create_time;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type_description;
@property (nonatomic, retain) NSString * icon_url;
@property (nonatomic, retain) NSOrderedSet *topics;
@end

@interface UMComTopicType (CoreDataGeneratedAccessors)

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
