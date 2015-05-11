//
//  UMComUser+UMComManagedObject.h
//  UMCommunity
//
//  Created by Gavin Ye on 11/12/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComUser.h"

@interface UMComUser (UMComManagedObject)

- (BOOL)isMyFollower;

- (void)deleteFeed:(UMComFeed *)feed;

@end

@interface ImageDictionary : NSValueTransformer

@end