//
//  UMComFeedsTableViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 8/27/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComFeedTableViewController.h"
#import "UMComFeedsTableViewCell.h"
#import "UMComCoreData.h"
#import "UMComSession.h"
#import "UMComFeedsTableViewCell.h"
#import "UMComHttpManager.h"
#import "UMComPullRequest.h"
#import "UMComFeedsTableView.h"
#import "UMComPushRequest.h"
#import "UMComShowToast.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMUtils.h"

@interface UMComFeedTableViewController ()<NSFetchedResultsControllerDelegate,UITextFieldDelegate> {
    NSFetchedResultsController *_fetchedResultsController;
}

@end

@implementation UMComFeedTableViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //只有在当前ViewController才接收通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postFeedComplete:) name:kNotificationPostFeedResult object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.feedsTableView
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];

    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.feedsTableView dismissAllEditView];
    [self.feedsTableView.showCommentDictionary removeAllObjects];
    [self.feedsTableView reloadData];
    //视图消失时注销观察者
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationPostFeedResult object:nil];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.feedsTableView reloadData];
    self.feedsTableView.indicatorView.center = CGPointMake(self.feedsTableView.frame.size.width/2, self.feedsTableView.indicatorView.center.y);
}
- (void)viewDidLoad
{
     [super viewDidLoad];
    self.feedsTableView.dataSource = self;
    //设置commentInputView必须写在registerNib之前，否则会有问题
     [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    self.resultArray = [NSMutableArray array];
    
    if (![NSStringFromClass([self class]) isEqualToString:@"UMComUserCenterViewController"]) {
         [self refreshAllData];
    }
    
    [(UMComFeedsTableView *)self.feedsTableView setViewController:self];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center = CGPointMake(self.view.frame.size.width/2 - 30, -30);
    self.activityView = activityView;
    [self.view addSubview:self.activityView];

    [[NSNotificationCenter defaultCenter] addObserver:self.feedsTableView
                                             selector:@selector(keyboardHiden:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    UITapGestureRecognizer *tapGestureReg = [[UITapGestureRecognizer alloc] initWithTarget:self.feedsTableView action:@selector(dismissAllEditView)];
    [self.feedsTableView addGestureRecognizer:tapGestureReg];
    
}

- (void)refreshAllData
{
    [self.resultArray removeAllObjects];
    [self.fetchFeedsController fetchRequestFromCoreData:^(NSArray *coreData, NSError *error) {
        if (coreData.count > 0) {
            if ([[[UIDevice currentDevice] systemVersion]floatValue] < 8.0) {
                self.feedsTableView.footView.backgroundColor = TableViewSeparatorRGBColor;
            }        }
        if (coreData && [coreData isKindOfClass:[NSArray class]]) {
            for (UMComFeed * feed in coreData) {
                if ([feed.status intValue] < FeedStatusDeleted) {
                    [self.resultArray addObject:feed];
                }
            }
            [self.feedsTableView reloadData];
        }
        
        [self.fetchFeedsController fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if (error) {
                [UMComShowToast fetchFeedFail:error];
            } else {
                if (data && data.count > 0) {
                    [self.resultArray removeAllObjects];
                    [self.resultArray addObjectsFromArray:data];
                    if ([[[UIDevice currentDevice] systemVersion]floatValue] < 8.0) {
                        self.feedsTableView.footView.backgroundColor = TableViewSeparatorRGBColor;
                    }                }
                [self.feedsTableView reloadData];
                
                if (haveNextPage) {
                    [self.feedsTableView addFootView];
                }
            }
        }];
    }];
}

-(void)postCommentContent:(NSString *)content
                   feedID:(NSString *)feedID
               commentUid:(NSString *)commentUid
               completion:(PostDataResponse)completion
{
    [UMComCommentFeedRequest postWithSourceFeedId:feedID commentContent:content replyUserId:commentUid completion:^(NSError *error) {
        if (error) {
            [UMComShowToast createCommentFail:error];
        }
        if (completion) {
            completion(error);
        }
    }];
}


-(void)postFeedComplete:(NSNotification *)notification
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (notification.object) {
        UMLog(@"postFeedComplete:error is %@",notification.object);
    } else {
        
        [((UMComFeedsTableView *)self.feedsTableView) refreshFeedsData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadMoreDataWithCompletion:(LoadDataCompletion)completion getDataFromWeb:(LoadServerDataCompletion)fromWeb
{
    [self.fetchFeedsController fetchNextPageFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        if (fromWeb) {
            fromWeb(data, haveNextPage, error);
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resultArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"FeedsTableViewCell";
    UMComFeedsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    __weak UMComFeedTableViewController *weakSelf = self;
    cell.deleteFeedSucceedAction = ^(UMComFeed *feed){
        if (feed) {
            feed.status = @(FeedStatusDeleted);
            [[UMComCoreData sharedInstance].incrementalStore updateObject:feed objectId:feed.feedID handler:^(NSManagedObject *object,NSManagedObjectContext *managedContext) {
                UMComFeed *backingFeedObject = (UMComFeed *)object;
                backingFeedObject.status = @(FeedStatusDeleted);
                [managedContext save:nil];
            }];
            if (indexPath.row < weakSelf.resultArray.count) {
                [weakSelf.resultArray removeObject:[weakSelf.resultArray objectAtIndex:indexPath.row]];
            }
            [weakSelf.feedsTableView refreshFeedsData];
            if (weakSelf.feedsTableView.deletedFeedSucceedAction) {
                weakSelf.feedsTableView.deletedFeedSucceedAction();
            }
        }
    };
    if (indexPath.row < self.resultArray.count) {
        [cell reload:[self.resultArray objectAtIndex:indexPath.row] tableView:tableView cellForRowAtIndexPath:indexPath];
  
    }
    return cell;
}

@end
