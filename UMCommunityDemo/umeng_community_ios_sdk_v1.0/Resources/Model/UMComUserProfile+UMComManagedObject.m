//
//  UMComUserProfile+UMComManagedObject.m
//  UMCommunity
//
//  Created by luyiyuan on 14/10/30.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComUserProfile+UMComManagedObject.h"

@implementation UMComUserProfile (UMComManagedObject)
+ (BOOL)isDelete
{
    return NO;
}

+ (NSDictionary *)attributes:(NSDictionary *)representation
                    ofEntity:(NSEntityDescription *)entity
                fetchRequest:(UMComFetchRequest *)fetchRequest
{
    NSDictionary * attributes = [UMComManagedObject attributes:representation ofEntity:entity fetchRequest:fetchRequest];
    NSMutableDictionary * newAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];

    [newAttributes setValue:[NSString stringWithFormat:@"%@",[representation valueForKey:@"fans_count"]] forKey:@"fans_count"];
    [newAttributes setValue:[NSString stringWithFormat:@"%@",[representation valueForKey:@"feed_count"]] forKey:@"feed_count"];
    [newAttributes setValue:[NSString stringWithFormat:@"%@",[representation valueForKey:@"following_count"]] forKey:@"following_count"];
    [newAttributes setValue:[NSString stringWithFormat:@"%@",[representation valueForKey:@"id"]] forKey:@"uid"];
    [newAttributes setValue:[representation valueForKey:@"accout_type"] forKey:@"account_type"];
    [newAttributes setValue:[representation valueForKey:@"has_followed"] forKey:@"is_follow"];
//    accout_type
    return newAttributes;
}

+ (NSDictionary *)relationshipsFromRepresentation:(NSDictionary *)representation ofEntity:(NSEntityDescription *)entity fetchRequest:(UMComFetchRequest *)fetchRequest
{
    NSDictionary * relationships = [UMComManagedObject relationshipsFromRepresentation:representation ofEntity:entity fetchRequest:nil];
    NSMutableDictionary * newRelationships = [NSMutableDictionary dictionaryWithDictionary:relationships];
    NSString *uid = fetchRequest.uid;
    if (!uid) {
        if (uid) {
            [newRelationships setValue:@{@"uid":uid} forKey:@"user"];
        }
    }
//    assert(uid);
    
    return newRelationships;
}


@end
