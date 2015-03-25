//
//  UMComFeed+UMComManagedObject.m
//  UMCommunity
//
//  Created by Gavin Ye on 11/12/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComFeed+UMComManagedObject.h"

@implementation UMComFeed (UMComManagedObject)

+ (BOOL)isDelete
{
    return NO;
}

+ (NSArray *)representationFromData:(NSDictionary *)representations fetchRequest:(UMComFetchRequest *)fetchRequest
{
    NSArray *returnData = @[representations];
    if ([representations valueForKey:@"items"]) {
        returnData = [representations valueForKey:@"items"];
    }
    return returnData;
}

+ (NSDictionary *)attributes:(NSDictionary *)representation
                    ofEntity:(NSEntityDescription *)entity
                fetchRequest:(UMComFetchRequest *)fetchRequest
{
    NSDictionary * attributes = [UMComManagedObject attributes:representation ofEntity:entity fetchRequest:fetchRequest];
    NSMutableDictionary * feedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    id feedId = [representation valueForKey:@"id"];
    if (feedId && [feedId isKindOfClass:[NSString class]]) {
        [feedAttributes setValue:[representation valueForKey:@"id"] forKey:@"feedID"];        
    }
    [feedAttributes setValue:fetchRequest.loginUid forKey:@"is_follow"];
    [feedAttributes setValue:[representation valueForKey:@"content"] forKey:@"text"];
    [feedAttributes setValue:[representation valueForKey:@"image_urls"] forKey:@"images"];
    [feedAttributes setValue:[representation valueForKeyPath:@"location.name"] forKey:@"location"];
    [feedAttributes setValue:[representation valueForKeyPath:@"comments.navigator"] forKey:@"comment_navigator"];
    return feedAttributes;
}

+ (BOOL)isStatusDeleted:(NSDictionary *)dict
{
    NSNumber *statusNum = @0;
    if ([dict valueForKey:@"status"]) {
        statusNum = [dict valueForKey:@"status"];
    }
    
    int status = [statusNum intValue];
    BOOL isdeleted = NO;
    if (status >= 2) {
        isdeleted = YES;
    }
    return isdeleted;
}

+ (NSDictionary *)relationshipsFromRepresentation:(NSDictionary *)representation ofEntity:(NSEntityDescription *)entity fetchRequest:(UMComFetchRequest *)fetchRequest
{
    NSMutableDictionary * relationships = [NSMutableDictionary dictionaryWithDictionary:[UMComManagedObject relationshipsFromRepresentation:representation ofEntity:entity fetchRequest:nil]];

//    NSMutableDictionary * newRelationships = [NSMutableDictionary dictionaryWithDictionary:relationships];
//    UMComHttpPagesRequest * httpPagesRequest = fetchRequest.httpPagesRequest;
//    if ([[[httpPagesRequest class] description] isEqualToString:@"UMComHttpPagesUserTopics"])
//    {
//        if (![representation valueForKey:@"creator"]) {
//            NSMutableDictionary *followsRelationships = [NSMutableDictionary dictionaryWithDictionary:representation];
//            NSString *uid = fetchRequest.uid;
//            [followsRelationships setValue:@[@{@"uid":uid}] forKey:@"creator"];
//            newRelationships = followsRelationships;
//        }
//    }
    
    return relationships;
}

@end


@implementation ImagesArray

+ (Class)transformedValueClass
{
    return [NSArray class];
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
