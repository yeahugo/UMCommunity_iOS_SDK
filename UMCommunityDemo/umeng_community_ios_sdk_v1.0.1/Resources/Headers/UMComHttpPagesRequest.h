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
@property (nonatomic) BOOL needDelete;
@property (nonatomic) BOOL handleNextPage;

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
