//
//  UMComTopicsTableView.h
//  UMCommunity
//
//  Created by umeng on 15/7/28.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UMComPullRequest, UMComRefreshView;

@protocol UMComClickActionDelegate, UMComScrollViewDelegate;


@interface UMComTopicsTableView : UITableView

@property (nonatomic, strong) UMComPullRequest *topicFecthRequest;

@property (strong, nonatomic) NSArray *topicsArray;

@property (nonatomic, strong) UMComRefreshView *headView;

@property (nonatomic, strong) UMComRefreshView *footView;

@property (nonatomic, weak) id<UMComClickActionDelegate> clickActionDelegate;

@property (nonatomic, weak) id<UMComScrollViewDelegate> scrollViewDelegate;


- (void)fecthTopicsData;


@end
