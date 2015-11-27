//
//  UMComTableViewController.m
//  UMCommunity
//
//  Created by umeng on 15-3-11.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComTableViewController.h"
#import "UMComTools.h"
#import "UMComRefreshView.h"
#import "UMComPullRequest.h"
#import "UMComTableView.h"

@interface UMComTableViewController ()<UITableViewDelegate, UITableViewDataSource, UMComTableViewHandleDataDelegate>
@end

@implementation UMComTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.tableView = [[UMComTableView alloc]initWithFrame:CGRectMake(0, -kUMComRefreshOffsetHeight, self.view.frame.size.width, self.view.frame.size.height+kUMComRefreshOffsetHeight) style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.handleDataDelegate = self;
    [self.view addSubview:self.tableView];
    self.tableView.fetchRequest = self.fetchRequest;
    [self.tableView setContentOffset:CGPointMake(0, -20) animated:YES];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)setFetchRequest:(UMComPullRequest *)fetchRequest
{
    _fetchRequest = fetchRequest;
    self.tableView.fetchRequest = fetchRequest;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}
//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    return cell;
}
//

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.tableView.refreshController refreshScrollViewDidScroll:scrollView haveNextPage:self.tableView.haveNextPage];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.tableView.refreshController refreshScrollViewDidEndDragging:scrollView haveNextPage:self.tableView.haveNextPage];
}

#pragma mark - data handle

- (void)handleCoreDataDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        self.dataArray = [NSMutableArray arrayWithArray:data];;
    }
    if (finishHandler) {
        finishHandler();
    }else{
        [self.tableView reloadData];
    }
}

- (void)handleServerDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        self.dataArray = [NSMutableArray arrayWithArray:data];;
    }
    if (finishHandler) {
        finishHandler();
    }else{
        [self.tableView reloadData];
    }
}

- (void)handleLoadMoreDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isMemberOfClass:[NSArray class]]) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataArray];
        if ([data isKindOfClass:[NSArray class]]) {
            [tempArray addObjectsFromArray:data];
        }
        self.dataArray = tempArray;
    }
    if (finishHandler) {
        finishHandler();
    }else{
        [self.tableView reloadData];
    }
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
