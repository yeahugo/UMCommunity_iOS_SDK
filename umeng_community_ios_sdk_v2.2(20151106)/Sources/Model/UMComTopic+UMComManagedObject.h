//
//  UMComTopic+UMComManagedObject.h
//  UMCommunity
//
//  Created by Gavin Ye on 11/5/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComTopic.h"

void printTopic();

//
@interface UMComTopic (UMComFormateForResponse)


@end

@interface UMComTopic (UMComManagedObject)

//返回UMComImageModel对象数组
- (NSArray*)umComImageModels;

@end


