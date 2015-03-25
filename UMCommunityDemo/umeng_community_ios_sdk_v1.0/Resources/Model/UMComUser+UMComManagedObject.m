//
//  UMComUser+UMComManagedObject.m
//  UMCommunity
//
//  Created by Gavin Ye on 11/12/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComUser+UMComManagedObject.h"
#import "UMComManagedObject.h"
#import "UMComCoreData.h"
#import "UMComSession.h"
#import "UMComFeed.h"
#import "UMComTopic.h"
@implementation ImageDictionary

+ (Class)transformedValueClass
{
    return [NSDictionary class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end

@implementation UMComUser (UMComManagedObject)
+ (BOOL)isDelete
{
    return NO;
}

- (BOOL)isMyFollower
{
    NSArray *followers = [UMComSession sharedInstance].followers;
    BOOL isMyFollower = NO;
    NSString *login_uid = self.uid;
    for (UMComUser * user in followers) {
        if ([user.uid isEqualToString:login_uid]) {
            isMyFollower = YES;
            break;
        }
    }
    return isMyFollower;
}

+ (NSArray *)representationFromData:(id)representations fetchRequest:(UMComFetchRequest *)fetchRequest
{
    UMComHttpPagesRequest * httpPagesRequest = fetchRequest.httpPagesRequest;
    
    NSArray *representation = representations;
    if ([[[httpPagesRequest class] description] isEqualToString:@"UMComHttpPagesUserFollowings"] && ![[[representations valueForKey:@"items"] firstObject] isKindOfClass:[NSNull class]])
    {
         representation = @[@{@"id":fetchRequest.uid,@"followers":[representations valueForKey:@"items"]}];
    } else if ([[[httpPagesRequest class] description] isEqualToString:@"UMComHttpPagesUserFans"] && ![[[representations valueForKey:@"items"] firstObject] isKindOfClass:[NSNull class]])
    {
        representation = @[@{@"id":fetchRequest.uid,@"fans":[representations valueForKey:@"items"]}];
    } else if ([representation isKindOfClass:[NSDictionary class]] && [representation valueForKey:@"items"]) {
        representation = [representations valueForKey:@"items"];
    }
    
//    NSArray *representation = fetchRequest.uid;
//
    return representation;
}
//
//- (void)addFollower:(UMComUser *)follower
//{
//    NSLog(@"%lu",self.followers.count);
//
//    NSMutableOrderedSet *followerSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.followers];
//    [followerSet addObject:follower];
//    [self setValue:followerSet forKey:@"followers"];
//
//    NSEntityDescription * entity = [NSEntityDescription entityForName:[[self entity] name] inManagedObjectContext:[UMComCoreData sharedInstance].backManagedObjectContext];
//    NSManagedObject * backFollower = [[UMComCoreData sharedInstance].incrementalStore backingObject:entity identifier:follower.uid];
//    UMComUser * backingManagedObject = (UMComUser *)[[UMComCoreData sharedInstance].incrementalStore backingObject:entity identifier:self.uid];
//    NSLog(@"%lu",backingManagedObject.followers.count);
//    NSMutableOrderedSet * newFollowers = [NSMutableOrderedSet orderedSetWithOrderedSet:backingManagedObject.followers];
//    [newFollowers addObject:backFollower];
//    [backingManagedObject setValue:newFollowers forKey:@"followers"];
//    NSLog(@"%lu",backingManagedObject.followers.count);
//
//}


- (void)deleteFeed:(UMComFeed *)feed
{
    NSMutableOrderedSet * feeds = [NSMutableOrderedSet orderedSetWithOrderedSet:self.feeds];
    [feeds removeObject:feed];
    [self setValue:feeds forKey:@"feeds"];
    
    NSEntityDescription * entity = [NSEntityDescription entityForName:[[self entity] name] inManagedObjectContext:[UMComCoreData sharedInstance].incrementalStore.backingManagedObjectContext];
    UMComUser * backingManagedObject = (UMComUser *)[[UMComCoreData sharedInstance].incrementalStore backingObject:entity identifier:self.uid];
    NSMutableOrderedSet * backingfeedsSet = [NSMutableOrderedSet orderedSetWithOrderedSet:backingManagedObject.feeds];

    [backingfeedsSet enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UMComFeed *feedItem = (UMComFeed *)obj;
        if ([feedItem.feedID isEqualToString:feed.feedID]) {
            *stop = YES;
        }
        if (*stop) {
            [backingfeedsSet removeObject:feed];
  
        }
        
    }];

    [backingManagedObject setValue:backingfeedsSet forKey:@"feeds"];
    [[UMComCoreData sharedInstance].managedObjectContext save:nil];
    [[UMComCoreData sharedInstance].backManagedObjectContext save:nil];
}


//- (void)deleteTopic:(UMComTopic *)topic
//{
//    
//    NSMutableOrderedSet * topics = [NSMutableOrderedSet orderedSetWithOrderedSet:self.topics];
//    [topics removeObject:topic];
////    topic.is_focused = [NSNumber numberWithInt:0];
//    [self setValue:topics forKey:@"topics"];
//    
//    NSEntityDescription * entity = [NSEntityDescription entityForName:[[self entity] name] inManagedObjectContext:[UMComCoreData sharedInstance].backManagedObjectContext];
//    UMComUser * backingManagedObject = (UMComUser *)[[UMComCoreData sharedInstance].incrementalStore backingObject:entity identifier:self.uid];
//    NSMutableOrderedSet * backingtopicsSet = [NSMutableOrderedSet orderedSetWithOrderedSet:backingManagedObject.topics];
//    [backingtopicsSet enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        UMComTopic *topicItem = (UMComTopic *)obj;
//        if ([topicItem.topicID isEqualToString:topic.topicID]) {
//            *stop = YES;
//        }
//        if (*stop) {
////            topicItem.is_focused = [NSNumber numberWithInt:0];
//            [backingtopicsSet removeObject:topic];
//        }
//        
//    }];
//    [backingManagedObject setValue:backingtopicsSet forKey:@"topics"];
//
//}

+ (NSDictionary *)attributes:(NSDictionary *)representation
                    ofEntity:(NSEntityDescription *)entity
                fetchRequest:(UMComFetchRequest *)fetchRequest
{
    NSDictionary * attributes = [UMComManagedObject attributes:representation ofEntity:entity fetchRequest:fetchRequest];
    NSMutableDictionary * newAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    if ([representation valueForKey:@"creator"]) {
        [newAttributes setValue:[representation valueForKeyPath:@"creator.id"] forKey:@"uid"];
        [newAttributes setValue:[representation valueForKeyPath:@"creator.icon_url"] forKey:@"icon_url"];
        [newAttributes setValue:[representation valueForKeyPath:@"creator.name"] forKey:@"name"];
        [newAttributes setValue:[representation valueForKey:@"creator.icon_url"] forKey:@"icon_url"];
        [newAttributes setValue:@"creator.gender" forKey:@"gender"];
    } else {
        [newAttributes setValue:[representation valueForKey:@"id"] forKey:@"uid"];
        [newAttributes setValue:[representation valueForKey:@"icon_url"] forKey:@"icon_url"]; //this is nessary
    }
    return newAttributes;
}

+ (NSDictionary *)relationshipsFromRepresentation:(NSDictionary *)representation ofEntity:(NSEntityDescription *)entity fetchRequest:(UMComFetchRequest *)fetchRequest
{
    NSDictionary * relationships = [UMComManagedObject relationshipsFromRepresentation:representation ofEntity:entity fetchRequest:nil];
    NSMutableDictionary * newRelationships = [NSMutableDictionary dictionaryWithDictionary:relationships];
//    UMComHttpPagesRequest * httpPagesRequest = fetchRequest.httpPagesRequest;
//    
//    if ([[[httpPagesRequest class] description] isEqualToString:@"UMComHttpPagesUserFollowings"])
//    {
//        if (![representation valueForKey:@"fans"] && representation.count > 1) {
//            NSMutableDictionary *newFollowers = [NSMutableDictionary dictionaryWithDictionary:representation];
//            [newFollowers setValue:@[@{@"id":fetchRequest.uid}] forKey:@"fans"];
//            newRelationships = newFollowers;
//        }
//    }
//    else if ([[[httpPagesRequest class] description] isEqualToString:@"UMComHttpPagesUserFans"]) {
//        if (![representation valueForKey:@"followers"] && representation.count > 1) {
//            NSMutableDictionary *newFans = [NSMutableDictionary dictionaryWithDictionary:representation];
//            [newFans setValue:@[@{@"id":fetchRequest.uid}] forKey:@"followers"];
//            newRelationships = newFans;
//        }
//    }
    
    return newRelationships;
}


@end
