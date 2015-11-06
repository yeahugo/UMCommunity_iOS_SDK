//
//  UMComUser+UMComManagedObject.h
//  UMCommunity
//
//  Created by Gavin Ye on 11/12/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComUser.h"



void printUser();

@interface UMComUser (UMComManagedObject)

- (BOOL)isMyFollower;

- (void)setHaveFollow;

- (void)setDisFollow;

@end

@interface ImageDictionary : NSValueTransformer

@end


@interface Permissions : NSValueTransformer

@end