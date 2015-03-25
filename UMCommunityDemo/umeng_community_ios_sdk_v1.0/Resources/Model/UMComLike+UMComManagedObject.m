//
//  UMComLike+UMComManagedObject.m
//  UMCommunity
//
//  Created by Gavin Ye on 12/25/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComLike+UMComManagedObject.h"
#import "UMComCoreData.h"

@implementation UMComLike (UMComManagedObject)

+ (NSArray *)representationFromData:(NSArray *)representations fetchRequest:(UMComFetchRequest *)fetchRequest
{
    NSArray *representation = nil;
    
    if ([[[fetchRequest.httpPagesRequest class] description] isEqualToString:@"UMComHttpPagesFeedLikes"] && ![[[representations valueForKey:@"items"] firstObject] isKindOfClass:[NSNull class]])
    {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:[UMComCoreData sharedInstance].managedObjectContext];
        representation = @[@{@"id":fetchRequest.feedId,@"likes":[representations valueForKey:@"items"],@"entity":entity}];
    } else if ([representations isKindOfClass:[NSArray class]] && [[representations firstObject] objectForKey:@"items"]) {
        representation = [[representations firstObject] valueForKey:@"items"];
    }  else {
        representation = representations;
    }
    return representation;
}

+ (id)attributes:(NSDictionary *)representation ofEntity:(NSEntityDescription *)entity fetchRequest:(UMComFetchRequest *)fetchRequest
{
    NSMutableDictionary *returnData = [NSMutableDictionary dictionaryWithDictionary:[UMComManagedObject attributes:representation ofEntity:entity fetchRequest:fetchRequest]];
    if ([[[fetchRequest.httpPagesRequest class] description] isEqualToString:@"UMComHttpPagesFeedLikes"] && ![[[representation valueForKey:@"items"] firstObject] isKindOfClass:[NSNull class]])
    {
        
        [returnData setValue:[representation valueForKey:@"likes"] forKey:@"likes"];

//        returnData = @{@"likes":[representation valueForKey:@"likes"],@"entity":entity};
    }
//    else if ([representation isKindOfClass:[NSDictionary class]]) {
//        returnData = [representation valueForKey:@"items"];
//    }
    return returnData;

}

+ (NSDictionary *)relationshipsFromRepresentation:(NSDictionary *)representation ofEntity:(NSEntityDescription *)entity fetchRequest:(UMComFetchRequest *)fetchRequest
{
    NSDictionary * relationships = [UMComManagedObject relationshipsFromRepresentation:representation ofEntity:entity fetchRequest:nil];
    NSMutableDictionary * newRelationships = [NSMutableDictionary dictionaryWithDictionary:relationships];
    [newRelationships setValue:@{@"id":[representation valueForKey:@"feed_id"]} forKey:@"feed"];
    return newRelationships;
}
@end
