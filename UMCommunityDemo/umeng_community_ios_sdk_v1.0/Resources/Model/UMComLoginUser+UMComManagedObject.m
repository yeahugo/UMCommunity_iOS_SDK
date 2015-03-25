//
//  UMComLoginUser+UMComManagedObject.m
//  UMCommunity
//
//  Created by Gavin Ye on 11/13/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComLoginUser+UMComManagedObject.h"
#import "UMComUser.h"
#import "UMComCoreData.h"

@implementation UMComLoginUser (UMComManagedObject)

//+ (void)addLoginUser:(NSDictionary *)userInfo
//{
//    NSString *uid = [userInfo valueForKey:@"id"];
////    NSString *openuid = [userInfo valueForKey:@"open_uid"];
//    NSString *nickName = [[userInfo valueForKey:@"name"] isKindOfClass:[NSString class]]? [userInfo valueForKey:@"name"] : nil;
//    NSString *token = [[userInfo valueForKey:@"token"] isKindOfClass:[NSString class]]? [userInfo valueForKey:@"token"] : nil;
//    
//    UMComLoginUser *loginUser = [NSEntityDescription insertNewObjectForEntityForName:[UMComLoginUser entityName] inManagedObjectContext:[UMComCoreData sharedInstance].managedObjectContext];
//    loginUser.current_login = @1;
//    loginUser.uid = uid;
//    loginUser.token = token;
//    UMComUser *user = [NSEntityDescription insertNewObjectForEntityForName:[UMComUser entityName] inManagedObjectContext:[UMComCoreData sharedInstance].managedObjectContext];
//    user.uid = uid;
//    user.name = nickName;
//#warning ToDo
////    user.icon_url = [NSDictionary dictionary];
//    user.icon_url = [userInfo valueForKey:@"icon_url"];
//    loginUser.user = user;
////    loginUser.openuid = openuid;
//    
//    NSEntityDescription * loginUserEntity = [NSEntityDescription entityForName:[UMComLoginUser entityName] inManagedObjectContext:[UMComCoreData sharedInstance].backManagedObjectContext];
//    UMComLoginUser *loginBackingUser = (UMComLoginUser *)[[UMComCoreData sharedInstance].incrementalStore backingObject:loginUserEntity identifier:uid];
//    loginBackingUser.token = token;
//    loginBackingUser.current_login = @1;
//    NSEntityDescription *userEntity = [NSEntityDescription entityForName:[UMComUser entityName] inManagedObjectContext:[UMComCoreData sharedInstance].backManagedObjectContext];
//    UMComUser *backingUser = (UMComUser *)[[UMComCoreData sharedInstance].incrementalStore backingObject:userEntity identifier:uid];
////    [loginBackingUser setValue:openuid forKey:kUMengComIncrementalStoreResourceIdentifierAttributeName];
//    [backingUser setValue:uid forKey:kUMengComIncrementalStoreResourceIdentifierAttributeName];
//    backingUser.uid = uid;
//    backingUser.name = nickName;
////    backingUser.icon_url = [NSDictionary dictionary];
//    backingUser.icon_url = [userInfo valueForKey:@"icon_url"];
//    loginBackingUser.user = backingUser;
//    loginBackingUser.uid = uid;
////    loginBackingUser.openuid = openuid;
//    
//    NSError *error = nil;
//    [[UMComCoreData sharedInstance].backManagedObjectContext save:&error];
//}


+ (NSDictionary *)attributes:(NSDictionary *)representation
                    ofEntity:(NSEntityDescription *)entity
                fetchRequest:(UMComFetchRequest *)fetchRequest
{
    NSDictionary * attributes = [UMComManagedObject attributes:representation ofEntity:entity fetchRequest:fetchRequest];
    NSMutableDictionary * newAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    
    [newAttributes setValue:[NSString stringWithFormat:@"%@",[representation valueForKey:@"id"]] forKey:@"uid"];
    return newAttributes;
}

+ (NSDictionary *)relationshipsFromRepresentation:(NSDictionary *)representation ofEntity:(NSEntityDescription *)entity fetchRequest:(UMComFetchRequest *)fetchRequest
{
    NSDictionary * relationships = [UMComManagedObject relationshipsFromRepresentation:representation ofEntity:entity fetchRequest:nil];
    NSMutableDictionary * newRelationships = [NSMutableDictionary dictionaryWithDictionary:relationships];
    NSString *uid = fetchRequest.uid;
    [newRelationships setValue:@{@"id":uid} forKey:@"user"];
    
    return newRelationships;
}
@end
