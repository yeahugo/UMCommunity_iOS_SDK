//
//  UMComFeedsTableViewController.h
//  UMCommunity
//
//  Created by Gavin Ye on 8/27/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComViewController.h"

#define DeltaBottom  45
#define DeltaRight 45

@class UMComComment, UMComFeedTableView,UMComPullRequest;
@interface UMComFeedTableViewController : UMComViewController

@property (nonatomic, strong) UMComPullRequest *fetchFeedsController;

@property (nonatomic, strong) UMComFeedTableView *feedsTableView;

@property (nonatomic, assign) BOOL isShowLocalData;

@property (nonatomic, strong) UIButton *editButton;

-(void)onClickEdit:(id)sender;
- (void)refreshAllData;
- (void)refreshDataFromServer:(void (^)(NSArray *data, NSError *error))completion;
@end
