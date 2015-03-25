//
//  UMComTopic+UMComManagedObject.m
//  UMCommunity
//
//  Created by Gavin Ye on 11/5/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComTopic+UMComManagedObject.h"
#import "UMComHttpManager.h"
#import "UMComCoreData.h"
#import "UMComSession.h"

@implementation UMComTopic(UMComLogicAccessors)

+ (BOOL)isDelete
{
    return YES;
}

#pragma mark -
#pragma mark UMComLogicAccessors

- (void)setFocused:(BOOL)focused block:(void (^)(NSError *))block
{
    [UMComHttpManager topicFocuse:focused topicId:self.topicID response:^(id responseObject, NSError *error) {
        if (!error && ([responseObject isKindOfClass:[NSDictionary class]] && ![responseObject valueForKey:@"err_code"])){
            if (focused) {
                [[UMComSession sharedInstance].focus_topics addObject:self];
            } else {
                [[UMComSession sharedInstance].focus_topics removeObject:self];
            }
        }
        if (block) {
            block(error);
        }
    }];
}

- (BOOL)isFocus
{
//    return [self.is_focused boolValue];
    BOOL returnFocus = NO;
    NSArray *focusTopics = [UMComSession sharedInstance].focus_topics;
    for (UMComTopic *topic in focusTopics) {
        if ([topic.topicID isEqualToString:self.topicID]) {
            returnFocus = YES;
            break;
        }
    }
    return returnFocus;
}

#pragma mark -
#pragma mark UMComFormateForResponse
- (id)initWithDictionary:(NSDictionary *)dictionary classer:(Class)classer
{
    self = [super initWithDictionary:dictionary classer:classer];
    
    if(self)
    {
        //        self.create_time = [UMUtils getStringFromDictionary:dictionary key:@"create_time"];
        self.descriptor = [UMUtils getStringFromDictionary:dictionary key:@"descriptor"];
        self.icon_url = [UMUtils getStringFromDictionary:dictionary key:@"icon_url"];
        self.name = [UMUtils getStringFromDictionary:dictionary key:@"name"];
        self.topicID = [UMUtils getStringFromDictionary:dictionary key:@"id"];
        //        self.is_focused = [UMUtils getStringFromDictionary:dictionary key:@"is_focused"];
    }
    
    return self;
}

@end


@implementation UMComTopic(UMComManagedObject)

+ (NSArray *)representationFromData:(id)representations fetchRequest:(UMComFetchRequest *)fetchRequest
{
    NSArray *returnData = representations;
    if ([[[fetchRequest.httpPagesRequest class] description] isEqualToString:@"UMComHttpPagesUserTopics"] && ![[[representations valueForKey:@"items"] firstObject] isKindOfClass:[NSNull class]])
    {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:[UMComCoreData sharedInstance].managedObjectContext];
        returnData = @[@{@"id":fetchRequest.uid,@"topics":[representations valueForKey:@"items"],@"entity":entity}];
    } else if ([[[fetchRequest.httpPagesRequest class] description] isEqualToString:@"UMComHttpPagesTopics"]){
        NSArray *represenData = [representations valueForKey:@"items"];
        NSMutableArray * newItemsData = [NSMutableArray array];
        [represenData enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] initWithDictionary:obj];
            [newDictionary setValue:@(idx) forKey:@"seq"];
            [newItemsData addObject:newDictionary];
        }];
        returnData = newItemsData;
    }
    else if ([representations isKindOfClass:[NSDictionary class]]) {
        returnData = [representations valueForKey:@"items"];
    }
    return returnData;
}

+ (NSDictionary *)attributes:(NSDictionary *)representation ofEntity:(NSEntityDescription *)entity fetchRequest:(UMComFetchRequest *)fetchRequest
{
    NSDictionary * attributes = [UMComManagedObject attributes:representation ofEntity:entity fetchRequest:fetchRequest];
    NSMutableDictionary * newAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [newAttributes setValue:[representation valueForKey:@"description"] forKey:@"descriptor"];
    [newAttributes setValue:[representation valueForKeyPath:@"icon_url.thumbnail"] forKey:@"icon_url"];
    [newAttributes setValue:[representation valueForKey:@"id"] forKey:@"topicID"];
   
    if (![representation valueForKey:@"is_focused"]) {
        if ([UMComSession sharedInstance].isFocus) {
            if (fetchRequest.uid) {
                [newAttributes setValue:@YES forKey:@"is_focused"];
            }else{
                [newAttributes setValue:@NO forKey:@"is_focused"];
            }
        }
    }
    if (![[representation valueForKey:@"create_time"] isKindOfClass:[NSNull class]]) {
        [newAttributes setValue:[UMComManagedObject dateTransform:[representation valueForKeyPath:@"create_time"]] forKey:@"create_time"];        
    }
    return newAttributes;
}

+ (NSDictionary *)relationshipsFromRepresentation:(NSDictionary *)representation ofEntity:(NSEntityDescription *)entity fetchRequest:(UMComFetchRequest *)fetchRequest
{
    NSDictionary * relationships = [UMComManagedObject relationshipsFromRepresentation:representation ofEntity:entity fetchRequest:nil];
    NSMutableDictionary * newRelationships = [NSMutableDictionary dictionaryWithDictionary:relationships];
    UMComHttpPagesRequest * httpPagesRequest = fetchRequest.httpPagesRequest;
    if ([[[httpPagesRequest class] description] isEqualToString:@"UMComHttpPagesUserTopics"])
    {
        if (![representation valueForKey:@"creator"]) {
            NSMutableDictionary *followsRelationships = [NSMutableDictionary dictionaryWithDictionary:representation];
            NSString *uid = fetchRequest.uid;
            [followsRelationships setValue:@[@{@"id":uid}] forKey:@"creator"];
            newRelationships = followsRelationships;
        }
    }
    
    return newRelationships;
}

@end
