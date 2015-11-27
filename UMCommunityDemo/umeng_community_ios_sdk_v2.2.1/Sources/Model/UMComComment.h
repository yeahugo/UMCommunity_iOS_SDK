//
//  UMComComment.h
//  UMCommunity
//
//  Created by umeng on 15/11/2.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UMComManagedObject.h"

@class UMComFeed, UMComUser;

@interface UMComComment : UMComManagedObject

@property (nonatomic, retain) NSString * commentID;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * create_time;
@property (nonatomic, retain) NSString * custom;
@property (nonatomic, retain) id image_urls;
@property (nonatomic, retain) NSNumber * liked;
@property (nonatomic, retain) NSNumber * likes_count;
@property (nonatomic, retain) NSNumber * seq;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) UMComUser *creator;
@property (nonatomic, retain) UMComFeed *feed;
@property (nonatomic, retain) UMComUser *reply_user;

@end
