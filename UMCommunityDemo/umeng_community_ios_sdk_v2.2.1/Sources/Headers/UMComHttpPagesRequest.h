//
//  UMComHttpPagesRequest.h
//  UMCommunity
//
//  Created by luyiyuan on 14/10/28.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMComHttpClient.h"

@interface UMComHttpPagesRequest : NSObject

@property (nonatomic) BOOL hasAlreadyResponseForInit;
@property (nonatomic,readonly) BOOL hasNextPage;
@property (nonatomic) BOOL handleNextPage;
@property (nonatomic) BOOL isRelationshipData;      //获取的数据是否关系数据
@property (nonatomic) BOOL notSave;                 //只有搜索不保存

- (id)initWithMethod:(UMComHttpMethodType)method
                path:(NSString *)path
      pathParameters:(NSDictionary *)pathParameters
      bodyParameters:(NSDictionary *)bodyParameters
             headers:(NSDictionary *)headers
            response:(PageDataResponse)response;

- (void)setResponseCompletion:(PageDataResponse)response;

- (void)request;

- (void)requestFromFirst;
//call after responseit will response for init response
- (void)requestNextPageAndResponse;

@end
