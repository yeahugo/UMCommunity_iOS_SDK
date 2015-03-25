//
//  UMComComment+UMComManagedObject.m
//  UMCommunity
//
//  Created by Gavin Ye on 11/17/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComComment+UMComManagedObject.h"

@implementation UMComComment (UMComManagedObject)

+ (NSArray *)representationFromData:(NSArray *)representations fetchRequest:(UMComFetchRequest *)fetchRequest
{
    NSArray *representation = nil;
    if ([representations isKindOfClass:[NSArray class]]) {
        representation = [[representations firstObject] valueForKey:@"items"];
    } else if ([representations valueForKey:@"items"]) {
        representation = [representations valueForKey:@"items"];
    }
    return representation;
}

+ (NSDictionary *)attributes:(NSDictionary *)representation ofEntity:(NSEntityDescription *)entity fetchRequest:(UMComFetchRequest *)fetchRequest
{
    NSDictionary * attributes = [UMComManagedObject attributes:representation ofEntity:entity fetchRequest:fetchRequest];
    NSMutableDictionary * newAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [newAttributes setValue:[representation valueForKey:@"id"] forKey:@"commentID"];
    return newAttributes;
}

+ (NSDictionary *)relationshipsFromRepresentation:(NSDictionary *)representation ofEntity:(NSEntityDescription *)entity fetchRequest:(UMComFetchRequest *)fetchRequest
{
    if (representation.count == 0) {
        return nil;
    }
    NSDictionary * relationshipDic = [UMComManagedObject relationshipsFromRepresentation:representation ofEntity:entity fetchRequest:nil];

    NSMutableDictionary *relationships = [NSMutableDictionary dictionaryWithDictionary:relationshipDic];
    NSDictionary * feed = @{@"id":[representation valueForKey:@"feed_id"]};
    NSDictionary * creator = @{@"id":[representation valueForKeyPath:@"creator.id"]};
    [relationships setValue:feed forKey:@"feed"];
    [relationships setValue:creator forKey:@"creator"];
    return relationships;
}
@end
