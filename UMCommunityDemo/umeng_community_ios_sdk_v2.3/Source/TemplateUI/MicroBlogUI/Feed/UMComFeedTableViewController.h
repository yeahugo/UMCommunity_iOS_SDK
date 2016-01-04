//
//  UMComFeedsTableViewController.h
//  UMCommunity
//
//  Created by Gavin Ye on 8/27/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComRequestTableViewController.h"
#import "UMComFeedStyle.h"

#define DeltaBottom  45
#define DeltaRight 45

@class UMComComment,UMComPullRequest;
@interface UMComFeedTableViewController : UMComRequestTableViewController

@property (nonatomic, strong) UIButton *editButton;

@property (nonatomic, assign) UMComFeedType feedType;

@property (nonatomic, assign) BOOL isShowEditButton;

-(void)onClickEdit:(id)sender;

- (void)insertFeedStyleToDataArrayWithFeed:(UMComFeed *)newFeed;

- (void)deleteFeed:(UMComFeed *)feed;

@end
