//
//  UMComUserProfile.h
//  UMCommunity
//
//  Created by umeng on 15-3-3.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UMComManagedObject.h"

@class UMComUser;

@interface UMComUserProfile : UMComManagedObject

@property (nonatomic, retain) NSNumber * account_type;
@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * fans_count;
@property (nonatomic, retain) NSString * feed_count;
@property (nonatomic, retain) NSString * following_count;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) id icon_url;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSString * level_title;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSNumber * is_follow;
@property (nonatomic, retain) UMComUser *user;

@end
