//
//  UMComComment.h
//  UMCommunity
//
//  Created by Gavin Ye on 11/20/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UMComManagedObject.h"

@class UMComFeed, UMComUser;

@interface UMComComment : UMComManagedObject

@property (nonatomic, retain) NSString * commentID;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) UMComUser *creator;
@property (nonatomic, retain) UMComFeed *feed;
@property (nonatomic, retain) UMComUser *reply_user;

@end
