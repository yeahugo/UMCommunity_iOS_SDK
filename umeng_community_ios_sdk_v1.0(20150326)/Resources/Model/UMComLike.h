//
//  UMComLike.h
//  UMCommunity
//
//  Created by Gavin Ye on 1/12/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UMComManagedObject.h"

@class UMComFeed, UMComUser;

@interface UMComLike : UMComManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) UMComUser *creator;
@property (nonatomic, retain) UMComFeed *feed;

@end
