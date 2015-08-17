//
//  UMComNotification.h
//  UMCommunity
//
//  Created by umeng on 15/7/15.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UMComManagedObject.h"

@class UMComUser;

@interface UMComNotification : UMComManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * ntype;
@property (nonatomic, retain) NSString * create_time;
@property (nonatomic, retain) UMComUser *creator;

@end
