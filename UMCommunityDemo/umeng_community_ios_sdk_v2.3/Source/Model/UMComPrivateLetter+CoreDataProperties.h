//
//  UMComPrivateLetter+CoreDataProperties.h
//  UMCommunity
//
//  Created by umeng on 15/12/1.
//  Copyright © 2015年 Umeng. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "UMComPrivateLetter.h"
void privatePrivate();
NS_ASSUME_NONNULL_BEGIN

@interface UMComPrivateLetter (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *letter_id;
@property (nullable, nonatomic, retain) NSString *update_time;
@property (nullable, nonatomic, retain) NSNumber *unread_count;
@property (nullable, nonatomic, retain) UMComUser *user;
@property (nullable, nonatomic, retain) UMComPrivateMessage *last_message;
@property (nullable, nonatomic, retain) NSOrderedSet<UMComPrivateMessage *> *message_records;

@end

@interface UMComPrivateLetter (CoreDataGeneratedAccessors)

- (void)insertObject:(UMComPrivateMessage *)value inMessage_recordsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMessage_recordsAtIndex:(NSUInteger)idx;
- (void)insertMessage_records:(NSArray<UMComPrivateMessage *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMessage_recordsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMessage_recordsAtIndex:(NSUInteger)idx withObject:(UMComPrivateMessage *)value;
- (void)replaceMessage_recordsAtIndexes:(NSIndexSet *)indexes withMessage_records:(NSArray<UMComPrivateMessage *> *)values;
- (void)addMessage_recordsObject:(UMComPrivateMessage *)value;
- (void)removeMessage_recordsObject:(UMComPrivateMessage *)value;
- (void)addMessage_records:(NSOrderedSet<UMComPrivateMessage *> *)values;
- (void)removeMessage_records:(NSOrderedSet<UMComPrivateMessage *> *)values;

@end

NS_ASSUME_NONNULL_END
