//
//  UMComManagedObject.m
//  UMCommunity
//
//  Created by luyiyuan on 14/9/28.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComManagedObject.h"
#import "UMComCoreData.h"

static inline NSString *getEntityName(NSString *className)
{
    return [className substringFromIndex:NSMaxRange([className rangeOfString:@"UMCom"])];
}

@implementation UMComManagedObject

- (id)initWithDictionary:(NSDictionary *)dictionary classer:(Class)classer
{
    self = [NSEntityDescription insertNewObjectForEntityForName:getEntityName(NSStringFromClass(classer)) inManagedObjectContext:[UMComCoreData sharedInstance].managedObjectContext];
    
    if(![dictionary count])
    {
        return self;
    }
    
    return self;
}

+ (BOOL)isDelete
{
    return NO;
}

+ (NSArray *)representationFromData:(id)representations fetchRequest:(UMComFetchRequest *)fetchRequest
{
    return representations;
}

+ (NSDictionary *)attributes:(NSDictionary *)representation
                    ofEntity:(NSEntityDescription *)entity
                fetchRequest:(UMComFetchRequest *)fetchRequest
{
    if ([representation isEqual:[NSNull null]]) {
        return nil;
    }
    
    NSMutableDictionary *mutableAttributes = [representation mutableCopy];
    @autoreleasepool {
        NSMutableSet *mutableKeys = [NSMutableSet setWithArray:[representation allKeys]];
        [mutableKeys minusSet:[NSSet setWithArray:[[entity attributesByName] allKeys]]];
        [mutableAttributes removeObjectsForKeys:[mutableKeys allObjects]];
        
        NSSet *keysWithNestedValues = [mutableAttributes keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
            return [obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]];
        }];
        [mutableAttributes removeObjectsForKeys:[keysWithNestedValues allObjects]];
    }
    
    return mutableAttributes;
}

+ (NSDictionary *)relationshipsFromRepresentation:(NSDictionary *)representation ofEntity:(NSEntityDescription *)entity fetchRequest:(UMComFetchRequest *)fetchRequest
{
    NSMutableDictionary *mutableRelationshipRepresentations = [NSMutableDictionary dictionaryWithCapacity:[entity.relationshipsByName count]];
    [entity.relationshipsByName enumerateKeysAndObjectsUsingBlock:^(id name, id relationship, BOOL *stop) {
        id value = [representation valueForKey:name];
        if (value) {
            if ([relationship isToMany]) {
                NSArray *arrayOfRelationshipRepresentations = nil;
                if ([value isKindOfClass:[NSArray class]]) {
                    arrayOfRelationshipRepresentations = value;
                } else {
                    arrayOfRelationshipRepresentations = [NSArray arrayWithObject:value];
                }
                
                [mutableRelationshipRepresentations setValue:arrayOfRelationshipRepresentations forKey:name];
            } else {
                [mutableRelationshipRepresentations setValue:value forKey:name];
            }
        }
    }];
    
    return mutableRelationshipRepresentations;
}


+ (id)entityName
{
    return getEntityName(NSStringFromClass(self));
}

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext*)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

+ (NSDate *)dateTransform:(NSString *)dateString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat : @"Y-M-d/ h:m:a"];
    NSDate *dateTime = [formatter dateFromString:dateString];
    return dateTime;
}

+ (NSArray *)fetchArrayFromResponse:(NSArray *)response
                             entity:(NSEntityDescription *)entity
                      manageContext:(NSManagedObjectContext *)manageContext
                       fetchRequest:fetchRequest
{
    NSManagedObjectContext *theManageContext = [UMComCoreData sharedInstance].tempManageObjectContext;
//    NSLog(@"entity name is %@",fetchRequest.entityName);
    if (!manageContext) {
         theManageContext = [UMComCoreData sharedInstance].tempManageObjectContext;
    }
    NSMutableArray *fetchArray = [NSMutableArray array];
    
    if ([entity.name isEqualToString:@"Comment"]) {
        UMLog(@"eneity is %@",entity);
    }
    response = [NSClassFromString([entity managedObjectClassName]) representationFromData:response fetchRequest:fetchRequest];
    
    if ([response isKindOfClass:[NSDictionary class]]) {
        response = @[response];
    }
    for (id object in response) {
        NSDictionary *attributes = [NSClassFromString([entity managedObjectClassName]) attributes:object ofEntity:entity fetchRequest:fetchRequest];
        if (attributes.count == 0) {
            continue;
        }
        NSManagedObject *managedObject = [self insertNewObjectIntoContext:theManageContext];
        [managedObject setValuesForKeysWithDictionary:attributes];
        [fetchArray addObject:managedObject];
        id representation_object = [NSClassFromString([entity managedObjectClassName]) representationFromData:object fetchRequest:fetchRequest];
        
        id relationshipRepresentations = [NSClassFromString([entity managedObjectClassName]) relationshipsFromRepresentation:representation_object ofEntity:entity fetchRequest:fetchRequest];
        
        if (!relationshipRepresentations || [relationshipRepresentations isEqual:[NSNull null]] || [relationshipRepresentations count] == 0) {
            continue;
        }
        
        for (NSString *relationshipName in relationshipRepresentations) {

            NSRelationshipDescription *relationship = [[entity relationshipsByName] valueForKey:relationshipName];
            NSEntityDescription * destinationEntity = relationship.destinationEntity;
            id relationshipRepresentation = [relationshipRepresentations objectForKey:relationshipName];
            if ([relationshipRepresentation isKindOfClass:[NSNull class]] || [relationshipRepresentation count] == 0 || ([relationshipRepresentation isKindOfClass:[NSArray class]] && [[relationshipRepresentation firstObject] isKindOfClass:[NSNull class]])) {
                continue;
            }
            if ([relationshipName isEqualToString:@"likes"] && [[[relationshipRepresentation firstObject] valueForKey:@"count"] intValue] > 0) {
                UMLog(@"relation is %@ ",relationshipRepresentation);
            }
//            NSLog(@"---relationship is %@ class is %@",relationshipRepresentation,[relationshipRepresentation class]);
            id relationValue = [NSClassFromString([destinationEntity managedObjectClassName]) fetchArrayFromResponse:relationshipRepresentation entity:destinationEntity manageContext:manageContext fetchRequest:fetchRequest];
            
            if ([relationValue count] > 0) {
                if (relationship.toMany) {
                    if (relationship.isOrdered) {
                        NSOrderedSet *relationOrderSet = [NSOrderedSet orderedSetWithArray:relationValue];
                        [managedObject setValue:relationOrderSet forKey:relationshipName];
                    } else {
                        NSSet *relationSet = [NSSet setWithArray:relationValue];
                        [managedObject setValue:relationSet forKey:relationshipName];
                    }
                } else {
                    [managedObject setValue:[relationValue firstObject] forKey:relationshipName];
                }
            }
            
            //            [self fetchArrayFromResponse:relationshipRepresentation fetchRequest:fetchRequest manageContext:manageContext];
        }
        
        
    }
    return fetchArray;
}


+ (void)deletedMangagerObject:(NSManagedObject *)managerObj blok:(void(^)(NSError *error))block
{
    NSError *error = nil;
    [managerObj.managedObjectContext deleteObject:managerObj];
    [managerObj.managedObjectContext save:&error];
    if (block) {
        block(error);
    }
//    if (managerObj) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
////            UMComCoreData *coreData = [UMComCoreData sharedInstance];
//            NSError *error = nil;
//            [managerObj.managedObjectContext deleteObject:managerObj];
//            [managerObj.managedObjectContext save:&error];
////            if (managerObj.managedObjectContext == coreData.managedObjectContext) {
////                [coreData.managedObjectContext deleteObject:managerObj];
////                [coreData.managedObjectContext save:&error];
////            }
////            if (managerObj.managedObjectContext == coreData.backManagedObjectContext) {
////                [coreData.backManagedObjectContext deleteObject:managerObj];
////                [coreData.backManagedObjectContext save:&error];
////            }
////            if (managerObj.managedObjectContext == coreData.tempManageObjectContext) {
////                [coreData.tempManageObjectContext deleteObject:managerObj];
////                [coreData.tempManageObjectContext save:&error];
////            }
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (block) {
//                    block(error);
//                }
//            });
//        });
//    }
}

@end
