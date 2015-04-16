//
//  UMComFeedsTableViewController.h
//  UMCommunity
//
//  Created by Gavin Ye on 8/27/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComFeedsTableView.h"
#import "UMComPullRequest.h"

#define kNotificationPostFeedResult @"PostFeedResult"


@class UMComComment;

@interface UMComFeedTableViewController : UIViewController
<UIScrollViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UMComPullRequest *fetchFeedsController;


@property (nonatomic, weak) IBOutlet UMComFeedsTableView *feedsTableView;

@property (nonatomic, strong) UMComFeedsTableView *reloadTableView;

//@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;


- (void)loadMoreDataWithCompletion:(LoadDataCompletion)completion getDataFromWeb:(LoadServerDataCompletion)fromWeb;

-(void)postCommentContent:(NSString *)content
                   feedID:(NSString *)feedID
               commentUid:(NSString *)commentUid
               completion:(PostDataResponse)completion;
- (void)refreshAllData;

@end
