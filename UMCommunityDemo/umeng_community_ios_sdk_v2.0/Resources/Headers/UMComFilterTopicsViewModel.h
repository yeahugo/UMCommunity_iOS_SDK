//
//  UMComFilterTopicsViewModel.h
//  UMCommunity
//
//  Created by luyiyuan on 14/9/28.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMComViewModel.h"

@interface UMComFilterTopicsViewModel : UMComViewModel
@property (nonatomic, strong) NSArray *topicsArray;
@property (nonatomic, strong) NSFetchedResultsController * fetchedResultsController;

- (void)searchTopicWithKeywords:(NSString *)keywords completion:(LoadDataCompletion)completion;

- (void)loadLocusTopics:(LoadDataCompletion)localCompletion serverCompletion:(LoadDataCompletion)serverCompletion;

- (void)loadLocusRecommendTopics:(LoadDataCompletion)localCompletion serverCompletion:(LoadDataCompletion)serverCompletion;


@end
