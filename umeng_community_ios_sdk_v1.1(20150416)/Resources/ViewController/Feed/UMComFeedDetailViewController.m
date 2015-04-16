//
//  UMComFeedDetailViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 11/13/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComFeedDetailViewController.h"
#import "UMComFeed.h"
#import "UMComPullRequest.h"
#import "UMComCoreData.h"
#import "UMComComment.h"
#import "UMComBarButtonItem.h"
#import "UMComAction.h"
#import "UMComPullRequest.h"

@interface UMComFeedDetailViewController ()

@property (nonatomic, copy) NSString *feedId;

@property (nonatomic, strong) UMComFeed *feed;

@property (nonatomic, copy) NSString *commentId;

@end

@implementation UMComFeedDetailViewController

- (id)initWithFeedId:(NSString *)feedId
{
    self = [super initWithNibName:@"UMComFeedDetailViewController" bundle:nil];
    if (self) {
        self.feedId = feedId;
        [self getFetchedResultsController];
    }
    return self;
}

- (id)initWithFeedId:(NSString *)feedId commentId:(NSString *)commentId
{
    self = [super initWithNibName:@"UMComFeedDetailViewController" bundle:nil];
    if (self) {
        self.feedId = feedId;
        self.commentId = commentId;
        [self getFetchedResultsController];
    }
    return self;
}

- (void)getFetchedResultsController
{
    UMComOneFeedRequest *oneFeedController = [[UMComOneFeedRequest alloc] initWithFeedId:self.feedId];
//    UMComFeedCommentsRequest *allCommentsController = [[UMComFeedCommentsRequest alloc] initWithFeedId:self.feedId count:TotalCommentsSize];
    self.fetchFeedsController = oneFeedController;
}

- (void)viewDidLoad
{
    [self.feedsTableView setFeedTableViewController:self];
    [super viewDidLoad];
    UIBarButtonItem *leftButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"Backx" target:self action:@selector(onClickClose:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
}

-(IBAction)onClickClose:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
