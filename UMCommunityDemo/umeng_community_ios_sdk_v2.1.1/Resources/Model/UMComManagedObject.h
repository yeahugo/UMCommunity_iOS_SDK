//
//  UMComManagedObject.h
//  UMCommunity
//
//  Created by luyiyuan on 14/9/28.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "UMComFetchRequest.h"

@interface UMComManagedObject : NSManagedObject
- (id)initWithDictionary:(NSDictionary *)dictionary classer:(Class)classer;

+ (BOOL)isDelete;

+ (NSDictionary *)attributes:(NSDictionary *)representation
                    ofEntity:(NSEntityDescription *)entity
                fetchRequest:(UMComFetchRequest *)fetchRequest;

+ (NSDictionary *)relationshipsFromRepresentation:(NSDictionary *)representation ofEntity:(NSEntityDescription *)entity fetchRequest:(UMComFetchRequest *)fetchRequest;

+ (NSArray *)representationFromData:(id)representations fetchRequest:(UMComFetchRequest *)fetchRequest;

+ (NSDate *)dateTransform:(NSString *)dateString;

//+ (id)managedObjectWithEntity:(NSEntityDescription *)entity;
+ (id)entityName;
+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext*)context;


/**
 删除一个对象
 @param managerObj 要删除的对象
 @param block 处理结果
 */
+ (void)deletedMangagerObject:(NSManagedObject *)managerObj blok:(void(^)(NSError *error))block;


@end
