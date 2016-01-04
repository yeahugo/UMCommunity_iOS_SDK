//
//  UMComTopicPostTableViewController.h
//  UMCommunity
//
//  Created by umeng on 15/12/30.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComPostTableViewController.h"

@class UMComTopic;
@interface UMComTopicPostTableViewController : UMComPostTableViewController

- (instancetype)initWithTopic:(UMComTopic *)topic;

@property (nonatomic, strong) UMComTopic *topic;



@end
