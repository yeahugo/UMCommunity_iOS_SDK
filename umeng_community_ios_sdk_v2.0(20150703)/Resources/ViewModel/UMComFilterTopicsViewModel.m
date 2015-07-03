//
//  UMComFilterTopicsViewModel.m
//  UMCommunity
//
//  Created by luyiyuan on 14/9/28.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComFilterTopicsViewModel.h"
#import "UMComFetchRequest.h"
#import "UMComTopic.h"
#import "UMComCoreData.h"
#import "UMComHttpPagesManager.h"
#import "UMComPullRequest.h"
#import "UMComSession.h"

@interface UMComFilterTopicsViewModel ()

@end
@implementation UMComFilterTopicsViewModel

- (void)loadLocusTopics:(LoadDataCompletion)localCompletion serverCompletion:(LoadDataCompletion)serverCompletion
{
    UMComAllTopicsRequest *allTopicsController = [[UMComAllTopicsRequest alloc]initWithCount:TotalTopicSize];
    UMComUserTopicsRequest *focusTopicsController = [[UMComUserTopicsRequest alloc] initWithUid:nil count:TotalTopicSize];
    
    [allTopicsController fetchRequestFromCoreData:^(NSArray *data, NSError *error) {
        localCompletion(data,error);
    }];
    
    [allTopicsController fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        [focusTopicsController fetchRequestFromServer:^(NSArray *focusData, BOOL haveNextPage, NSError *error) {
            if (!error) {
                [UMComSession sharedInstance].focus_topics = [NSMutableArray arrayWithArray:focusData];
                
            }
            serverCompletion(data,error);
        }];
    }];
}

- (void)loadLocusRecommendTopics:(LoadDataCompletion)localCompletion serverCompletion:(LoadDataCompletion)serverCompletion
{
    UMComRecommendTopicsRequest *recommendTopicsRequest = [[UMComRecommendTopicsRequest alloc]initWithCount:TotalTopicSize];
    [recommendTopicsRequest fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            serverCompletion(data,error);
    }];
}


- (void)searchTopicWithKeywords:(NSString *)keywords completion:(LoadDataCompletion)completion
{
    UMComSearchTopicRequest *serchTopicRequest = [[UMComSearchTopicRequest alloc]initWithKeywords:keywords];
    [serchTopicRequest fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        completion(data, error);
    }];
}


@end
