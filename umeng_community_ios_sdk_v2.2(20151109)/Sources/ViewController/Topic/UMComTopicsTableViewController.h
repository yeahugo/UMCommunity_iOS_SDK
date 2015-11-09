//
//  UMComTopicsTableViewController.h
//  UMCommunity
//
//  Created by umeng on 15/7/15.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComViewController.h"

@class UMComPullRequest, UMComTopicsTableView;

@interface UMComTopicsTableViewController : UMComViewController

@property (nonatomic, strong) UMComPullRequest *fetchRequest;

@property (nonatomic, strong) UMComTopicsTableView *tableView;

@property (nonatomic, copy) void (^completion)(NSArray *data, NSError *error);

@property (nonatomic, assign) BOOL isShowNextButton;

- (void)fecthTopicsData;

@end
