//
//  UMComIncrementalStore.h
//  UMCommunity
//
//  Created by Gavin Ye on 9/3/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "UMComHttpClient.h"
#import "UMComFetchRequest.h"

static char kUMengComResourceIdentifierObjectKey;
static NSString * const kUMengComReferenceObjectPrefix = @"__umeng_";
static NSString * const kUMengComIncrementalStoreResourceIdentifierAttributeName = @"__umeng_resourceIdentifier";
static NSString * const kUMengComIncrementalStoreLastModifiedAttributeName = @"__umeng_lastModified";


@interface UMComIncrementalStore : NSIncrementalStore

extern NSString * UMComResourceIdentifierFromReferenceObject(id referenceObject);

extern NSString * UMComReferenceObjectFromResourceIdentifier(NSString *resourceIdentifier);

@property (readonly) NSPersistentStoreCoordinator *backingPersistentStoreCoordinator;

@property (readonly) NSManagedObjectContext *backingManagedObjectContext;

@property (nonatomic, strong) NSCache *backingObjectIDByObjectID;

+ (NSString *)type;

- (void)updateObject:(NSManagedObject *)managedObject objectId:(NSString *)backingObjectIDString handler:(void(^)(NSManagedObject *object, NSManagedObjectContext *manageContext))updateHandler;

- (void)deleteObject:(NSManagedObject *)managedObject objectId:(NSString *)backingObjectIDString;

- (NSManagedObject *)backingObject:(NSEntityDescription *)entity identifier:(NSString *)identifier;

- (void)saveRequestResultRequst:(UMComFetchRequest *)fetchRequest response:(id)responseObject  error:(NSError *)error;

- (id)fetchCoreDataRequest:(UMComFetchRequest *)fetchRequest context:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error;

@end
