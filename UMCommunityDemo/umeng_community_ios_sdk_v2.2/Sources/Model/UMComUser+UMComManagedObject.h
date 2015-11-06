//
//  UMComUser+UMComManagedObject.h
//  UMCommunity
//
//  Created by Gavin Ye on 11/12/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComUser.h"




void printUser();
typedef enum IconType {
    UMComIconSmallType,
    UMComIconMiddleType,
    UMComIconLargeType
} UMComIconType;

@interface UMComUser (UMComManagedObject)

- (BOOL)isMyFollower;

- (NSString *)iconUrlStrWithType:(UMComIconType)type;

/*判断用户是否具有删除的权限*/
- (BOOL)isPermissionDelete;

/*判断用户是否具有发公告的权限*/
- (BOOL)isPermissionBulletin;

@end

@interface ImageDictionary : NSValueTransformer

@end


@interface Permissions : NSValueTransformer

@end