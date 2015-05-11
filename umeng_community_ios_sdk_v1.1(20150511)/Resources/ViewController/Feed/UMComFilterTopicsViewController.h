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

@property (strong,nonatomic) NSArray *allTopicsArray;

@property (nonatomic, strong) void (^scrollViewScroll)(UIScrollView *scrollView);


@property (nonatomic, assign) BOOL isShowNextButton;

- (void)reloadTopicsDataWithSearchText:(NSString *)searchText;
- (void)searchWhenClickAtSearchButtonResult:(NSString *)keywords;

@end
