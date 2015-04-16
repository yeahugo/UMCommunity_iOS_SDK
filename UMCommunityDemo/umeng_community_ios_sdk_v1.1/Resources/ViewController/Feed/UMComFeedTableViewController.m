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
//    [self.feedsTableView reloadData];
    //视图消失时注销观察者
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationPostFeedResult object:nil];
}

- (UMComFeedsTableView *)feedsTableView
{
    if (self.reloadTableView) {
        self.reloadTableView.dataSource = self;
        return self.reloadTableView;
    } else {
        return _feedsTableView;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.feedsTableView.indicatorView.center = CGPointMake(self.feedsTableView.frame.size.width/2, self.feedsTableView.indicatorView.center.y);
    self.indicatorView.center = CGPointMake(self.feedsTableView.frame.size.width/2, self.feedsTableView.frame.size.height/2);
}

- (void)viewDidLoad
{
     [super viewDidLoad];
    
    self.indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.feedsTableView addSubview:self.indicatorView];
    self.feedsTableView.dataSource = self;
    //设置commentInputView必须写在registerNib之前，否则会有问题
     [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if (![NSStringFromClass([self class]) isEqualToString:@"UMComUserCenterViewController"]) {
         [self refreshAllData];
    }
    
    [(UMComFeedsTableView *)self.feedsTableView setViewController:self];

    [[NSNotificationCenter defaultCenter] addObserver:self.feedsTableView
                                             selector:@selector(keyboardHiden:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    UITapGestureRecognizer *tapGestureReg = [[UITapGestureRecognizer alloc] initWithTarget:self.feedsTableView action:@selector(dismissAllEditView)];
    [self.feedsTableView addGestureRecognizer:tapGestureReg];
    
}

- (void)refreshAllData
{
    [self.indicatorView startAnimating];
    [self.feedsTableView.resultArray removeAllObjects];
    [self.fetchFeedsController fetchRequestFromCoreData:^(NSArray *coreData, NSError *error) {
        if (coreData.count > 0) {
            for (UMComFeed * feed in coreData) {
                if ([feed.status intValue] < FeedStatusDeleted) {
                    [self.feedsTableView.resultArray addObject:feed];
                }
            }
            [self.indicatorView stopAnimating];
            [self.feedsTableView reloadData];
        }
        [self.feedsTableView reloadData];
        [self.feedsTableView refreshFeedsData];
//        [self.fetchFeedsController fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
//            [self.indicatorView stopAnimating];
//            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//            if (error) {
//                [UMComShowToast fetchFeedFail:error];
//            } else {
//                if (data.count > 0) {
//                    [self.feedsTableView.resultArray removeAllObjects];
//                    [self.feedsTableView.resultArray addObjectsFromArray:data];
//                    if ([[[UIDevice currentDevice] systemVersion]floatValue] < 8.0) {
//                        self.feedsTableView.footView.backgroundColor = TableViewSeparatorRGBColor;
//                    }
//                }else{
//                    self.feedsTableView.footView.backgroundColor = [UIColor clearColor];
//                }
//                [self.feedsTableView reloadData];
//                if (haveNextPage) {
//                    [self.feedsTableView addFootView];
//                }
//            }
//        }];
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
    return self.feedsTableView.resultArray.count;
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
            if (indexPath.row < weakSelf.feedsTableView.resultArray.count) {
                [weakSelf.feedsTableView.resultArray removeObject:[weakSelf.feedsTableView.resultArray objectAtIndex:indexPath.row]];
            }
            [weakSelf.feedsTableView refreshFeedsData];
            if (weakSelf.feedsTableView.deletedFeedSucceedAction) {
                weakSelf.feedsTableView.deletedFeedSucceedAction();
            }
        }
    };
    if (indexPath.row < self.feedsTableView.resultArray.count) {
        [cell reload:[self.feedsTableView.resultArray objectAtIndex:indexPath.row] tableView:tableView cellForRowAtIndexPath:indexPath];
  
    }
    return cell;
}

@end
