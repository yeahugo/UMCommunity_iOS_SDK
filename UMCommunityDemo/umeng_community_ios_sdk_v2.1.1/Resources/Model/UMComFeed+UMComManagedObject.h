//
//  UMComFeed+UMComManagedObject.h
//  UMCommunity
//
//  Created by Gavin Ye on 11/12/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComFeed.h"


void printFeed ();

@interface UMComFeed (UMComManagedObject)

//- (void)addLikesObject:(UMComUser *)value;
- (UMComUser *)relatedUserWithUserName:(NSString *)name;
- (UMComTopic *)relatedTopicWithTopicName:(NSString *)topicName;

@end

@interface ImagesArray : NSValueTransformer

@end

@interface LocationDictionary : NSValueTransformer

@end