//
//  UMComAlbum.h
//  UMCommunity
//
//  Created by umeng on 15/9/23.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UMComManagedObject.h"

@class UMComUser, UMComImageUrl;

@interface UMComAlbum : UMComManagedObject

@property (nonatomic, retain) NSDate * create_time;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * seq;
@property (nonatomic, retain) UMComImageUrl *cover;
@property (nonatomic, retain) UMComUser *user;
@property (nonatomic, retain) NSOrderedSet<UMComImageUrl *> *image_urls;


@end
