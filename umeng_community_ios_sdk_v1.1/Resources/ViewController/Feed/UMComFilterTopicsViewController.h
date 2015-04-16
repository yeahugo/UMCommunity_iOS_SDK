//
//  UMComFilterTopicsViewController.h
//  UMCommunity
//
//  Created by Gavin Ye on 9/2/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComTableViewController.h"
#import "UMComFilterTopicsViewModel.h"

typedef enum topicRequestType {
    allTopicType = 0,
    recommendTopicType = 1
}TopicRequestType;

@interface UMComFilterTopicsViewController : UMComTableViewController <UISearchBarDelegate>

@property (nonatomic, copy) LoadDataCompletion completion;

@property (nonatomic,strong) UMComFilterTopicsViewModel *filterTopicsViewModel;

@property (nonatomic, assign) TopicRequestType topicRequestType;

@property (nonatomic, assign) BOOL isShowNextButton;

@end
