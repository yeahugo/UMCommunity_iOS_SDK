//
//  UMComLike.h
//  UMCommunity
//
//  Created by umeng on 15/7/10.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UMComManagedObject.h"

@class UMComFeed, UMComUser;

@interface UMComLike : UMComManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * create_time;
@property (nonatomic, retain) UMComUser *creator;
@property (nonatomic, retain) UMComFeed *feed;

@end
