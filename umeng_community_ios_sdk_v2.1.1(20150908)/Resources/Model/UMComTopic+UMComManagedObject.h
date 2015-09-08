//
//  UMComTopic+UMComManagedObject.h
//  UMCommunity
//
//  Created by Gavin Ye on 11/5/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComTopic.h"

void printTopic();

//设置话题关注
@interface UMComTopic (UMComLogicAccessors)

- (void)setFocused:(BOOL)focused block:(void (^)(NSError * error))block;
@end


//
@interface UMComTopic (UMComFormateForResponse)

//- (id)initWithDictionary:(NSDictionary *)dictionary;

@end

@interface UMComTopic (UMComManagedObject)

@end
