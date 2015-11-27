//
//  UMComFeed+UMComManagedObject.h
//  UMCommunity
//
//  Created by Gavin Ye on 11/12/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComFeed.h"

void printFeed ();

typedef void(^UMComFeedOperationComplection)(id responseObject, NSError *error);

@class UMComLocationModel;
@interface UMComFeed (UMComManagedObject)

/**
 *通过用户名从feed相关用户中查找对应的用户
 
 @param name 用户名
 *return 返回一个UMComUser对象
 */
- (UMComUser *)relatedUserWithUserName:(NSString *)name;

/**
 *通过话题名称从feed中查找对应的话题
 
 @param topicName 话题名称
 *return 返回一个UMComTopic对象
 */
- (UMComTopic *)relatedTopicWithTopicName:(NSString *)topicName;

/**
 获取feed的图片集
 
 @return 返回UMComImageModel对象数组
 */
- (NSArray *)imageModels;

- (UMComLocationModel *)locationModel;

@end

@interface ImagesArray : NSValueTransformer

@end

@interface LocationDictionary : NSValueTransformer

@end