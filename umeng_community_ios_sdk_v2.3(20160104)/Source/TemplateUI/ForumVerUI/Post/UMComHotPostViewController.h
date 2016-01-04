//
//  UMComPostListViewController.h
//  UMCommunity
//
//  Created by umeng on 12/2/15.
//  Copyright © 2015 Umeng. All rights reserved.
//

#import "UMComViewController.h"

@class UMComTopic;
@interface UMComHotPostViewController : UMComViewController


@property (nonatomic, strong) UMComTopic *topic;


- (instancetype)initWithTopic:(UMComTopic *)topic;

- (void)setPage:(NSInteger)page;

@end
