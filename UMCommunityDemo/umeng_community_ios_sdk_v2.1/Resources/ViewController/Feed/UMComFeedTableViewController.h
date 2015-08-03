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

@property (nonatomic, strong) UMComFeedsTableView *feedsTableView;

- (void)refreshAllData;
- (void)refreshDataFromServer:(void (^)(NSArray *data, NSError *error))completion;
@end
