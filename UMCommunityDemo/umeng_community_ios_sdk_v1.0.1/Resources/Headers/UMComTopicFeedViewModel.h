//
//  UMComTopicFeedsViewModel.h
//  UMCommunity
//
//  Created by Gavin Ye on 10/21/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMComFeedViewModel.h"
#import "UMComTopic.h"

@interface UMComTopicFeedViewModel : UMComFeedViewModel

@property (nonatomic, strong) NSMutableArray * feedsArray;

-(id)initWithTopic:(UMComTopic *)topic;


@end
