//
//  UMComFeedsTableViewController.h
//  UMCommunity
//
//  Created by Gavin Ye on 8/27/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>


@class UMComComment, UMComFeedsTableView,UMComPullRequest;
@interface UMComFeedTableViewController : UIViewController

@property (nonatomic, strong) UMComPullRequest *fetchFeedsController;

@property (nonatomic, weak) IBOutlet UMComFeedsTableView *feedsTableView;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) UIViewController *myParentViewController;


- (void)refreshAllData;
- (void)refreshDataFromServer;
@end
