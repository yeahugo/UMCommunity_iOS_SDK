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

@class UMComUser;

@interface UMComAlbum : UMComManagedObject

@property (nonatomic, retain) id cover;
@property (nonatomic, retain) NSDate * create_time;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) id image_urls;
@property (nonatomic, retain) NSString * seq;
@property (nonatomic, retain) UMComUser *user;

@end
