//
//  UMComFetchRequest.h
//  UMCommunity
//
//  Created by Gavin Ye on 9/26/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "UMComHttpPagesRequest.h"

typedef NS_ENUM(NSUInteger,UMComFetchRequestTag){
    UMComFetchRequestTagDefault,
    UMComFetchRequestTagFeeds,
    UMComFetchRequestTagTimeLine
};

typedef NS_ENUM(NSUInteger, UMComFetchSourceType) {
    UMComFetchSourceTypeDefault,
    UMComFetchSourceTypeOnlyLocal,
    UMComFetchSourceTypeOnlyWeb
};

typedef NS_ENUM(NSUInteger, UMComFetchResultType) {
    UMComFetchResultTypeLocal,
    UMComFetchResultTypeWeb
};

//定义每页的个数
#define BatchSize 20

//关注的话题个数
#define FocusTopicNum 100

//定义所有话题
#define TotalTopicSize 100

//定义所有好友数量
#define TotalFriendSize 1000

//获取所有喜欢
#define TotalLikesSize 100

//获取所有评论
#define TotalCommentsSize 100

//获取所有收藏
#define TotalCollectionsSize 50

typedef void (^DeleteFinish)(void);
typedef void (^DeleteHandler)(DeleteFinish);


@interface UMComFetchRequest : NSFetchRequest<NSCopying>

@property (nonatomic, copy) NSString * uid;

@property (nonatomic, copy) NSString * loginUid;

@property (nonatomic, copy) NSString * topicId;

@property (nonatomic, copy) NSString * nextPageUrl;

@property (nonatomic) UMComFetchSourceType fetchSourceType;

@property (nonatomic, strong, readonly) UMComHttpPagesRequest *httpPagesRequest;

@property (nonatomic, copy) PageDataResponse webCompletion;

@property (nonatomic, copy) DeleteHandler deleteHandler;

@property (nonatomic, copy) NSString * feedId;

- (void)setResponseCompletion:(PageDataResponse)response;

- (void)setPagesRequestWithClass:(Class)pagesRequestClass parameter:(id )parameter;

//请求之前，必须setResponseCompletion设置回掉
- (void)request;

- (void)setHttpPageRequestReInit:(BOOL)requestInit;
@end
