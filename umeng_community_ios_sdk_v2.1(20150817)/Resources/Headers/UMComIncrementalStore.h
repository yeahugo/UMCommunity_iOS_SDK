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


@interface UMComIncrementalStore : NSObject

extern NSString * UMComResourceIdentifierFromReferenceObject(id referenceObject);

extern NSString * UMComReferenceObjectFromResourceIdentifier(NSString *resourceIdentifier);

@property (readonly) NSManagedObjectContext *backingManagedObjectContext;

@property (nonatomic, strong) NSCache *backingObjectIDByObjectID;

@property (nonatomic, strong) NSCache *managedObjectIdentifier;

- (void)updateObject:(NSManagedObject *)managedObject objectId:(NSString *)backingObjectIDString handler:(void(^)(NSManagedObject *object, NSManagedObjectContext *manageContext))updateHandler;

- (void)deleteObject:(NSManagedObject *)managedObject objectId:(NSString *)backingObjectIDString;

- (void)saveRequestResultRequst:(UMComFetchRequest *)fetchRequest response:(id)responseObject  error:(NSError *)error;

- (id)executeFetchRequest:(UMComFetchRequest *)fetchRequest
              withContext:(NSManagedObjectContext *)context
                    error:(NSError *__autoreleasing *)error;

@end
