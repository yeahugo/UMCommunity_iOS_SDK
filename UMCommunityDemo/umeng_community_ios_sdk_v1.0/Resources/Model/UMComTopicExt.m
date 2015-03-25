//
//  UMComTopicExt.m
//  UMCommunity
//
//  Created by Gavin Ye on 10/29/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComTopicExt.h"
#import "UMComSession.h"

@implementation UMComTopic(UMComManagedObject)

+ (NSDictionary *)attributes:(NSDictionary *)representation ofEntity:(NSEntityDescription *)entity fetchRequest:(id)fetchRequest
{
    NSDictionary * attributes = [UMComManagedObject attributes:representation ofEntity:entity fetchRequest:fetchRequest];
    NSMutableDictionary * newAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [newAttributes setValue:[representation valueForKey:@"description"] forKey:@"descriptor"];
    [newAttributes setValue:[representation valueForKeyPath:@"icon_url.thumbnail"] forKey:@"icon_url"];
    [newAttributes setValue:[representation valueForKey:@"id"] forKey:@"topicID"];
    [newAttributes setValue:@YES forKey:@"is_focused"];
    [newAttributes setValue:[UMComManagedObject dateTransform:[representation valueForKeyPath:@"create_time"]] forKey:@"create_time"];
    return newAttributes;
}

+ (NSDictionary *)relationshipsFromRepresentation:(NSDictionary *)representation ofEntity:(NSEntityDescription *)entity fetchRequest:(UMComFetchRequest *)fetchRequest managedObject:(UMComManagedObject *)managedObject
{
    //保存话题的关注者
    NSString *uid = (fetchRequest.uid) ? fetchRequest.uid : [UMComSession sharedInstance].uid;
    if (uid == nil) {
        return nil;
    }
    NSDictionary * relationships = [UMComManagedObject relationshipsFromRepresentation:representation ofEntity:entity fetchRequest:fetchRequest];
    NSMutableDictionary *newRelationships = [NSMutableDictionary dictionaryWithDictionary:relationships];
    NSDictionary * creator = @{@"uid":uid};
    [newRelationships setValue:creator forKey:@"creator"];
    return newRelationships;
}
@end
