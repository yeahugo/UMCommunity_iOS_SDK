//
//  UMComLoginUser.h
//  UMCommunity
//
//  Created by Gavin Ye on 1/12/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UMComManagedObject.h"

@class UMComUser;

@interface UMComLoginUser : UMComManagedObject

@property (nonatomic, retain) NSNumber * current_login;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) UMComUser *user;

@end
