//
//  UMComAlbum.h
//  UMCommunity
//
//  Created by Gavin Ye on 6/1/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UMComManagedObject.h"

@class UMComUser;

@interface UMComAlbum : UMComManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * seq;
@property (nonatomic, retain) NSDate * create_time;
@property (nonatomic, retain) NSString * cover;
@property (nonatomic, retain) id image_urls;
@property (nonatomic, retain) UMComUser *user;

@end
