//
//  UMComCoreData.h
//  UMCommunity
//
//  Created by Gavin Ye on 8/28/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UMComIncrementalStore.h"

extern NSString *const kUMCommanagedObjectContextDidMergeNotification;

typedef NS_ENUM(NSInteger, UMComCoreDataErrorCode)
{
    UMComCoreDataErrorCodeUnknown,
    UMComCoreDataErrorNoMoreFeed
};

@interface UMComCoreData : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;

@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) NSManagedObjectContext *backManagedObjectContext;

@property (nonatomic, strong) UMComIncrementalStore *incrementalStore;

+ (UMComCoreData *)sharedInstance;

+ (NSError *)errorWithCode:(UMComCoreDataErrorCode)code reason:(NSString *)reason;

- (void)saveContext;

@end
