//
//  UMComTopicsTableViewController.m
//  UMCommunity
//
//  Created by umeng on 15/7/15.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComTopicsTableViewController.h"
#import "UIViewController+UMComAddition.h"
#import "UMComTools.h"
#import "UMComBarButtonItem.h"
#import "UMComFilterTopicsViewCell.h"
#import "UMComTopicFeedViewController.h"
#import "UMComPullRequest.h"
#import "UMComPushRequest.h"
#import "UMComShowToast.h"
#import "UMComAction.h"
#import "UMComTopic.h"
#import "UMComTopic+UMComManagedObject.h"
#import "UMComRefreshView.h"
#import "UMComClickActionDelegate.h"

@interface UMComTopicsTableViewController ()<UMComClickActionDelegate>

@property (nonatomic, strong) NSArray *originDataArray;

@property (nonatomic, strong) UMComSearchTopicRequest *searchTopicRequest;


@end

@implementation UMComTopicsTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self setBackButtonWithImage];
    [self setTitleViewWithTitle:self.title];

    self.tableView.rowHeight = 62.f;
    [self.tableView registerNib:[UINib nibWithNibName:@"UMComFilterTopicsViewCell" bundle:nil] forCellReuseIdentifier:@"FilterTopicsViewCell"];
    self.noDataTipLabel.text = UMComLocalizedString(@"no topics",@"暂无相关话题");
    
    if (self.isShowNextButton == YES) {
        UMComBarButtonItem *rightButtonItem = [[UMComBarButtonItem alloc] initWithTitle:UMComLocalizedString(@"NextStep",@"下一步") target:self action:@selector(onClickNext)];
        [self.navigationItem setRightBarButtonItem:rightButtonItem];
    }
}

- (void)onClickNext
{
    if (self.completion) {
        self.completion(@[self], nil);
    }
}

-(void)onClickClose
{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"FilterTopicsViewCell";
    UMComFilterTopicsViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell == nil) {
        cell = [[UMComFilterTopicsViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.delegate = self;
    
    UMComTopic *topic = [self.dataArray objectAtIndex:indexPath.row];
    [cell setWithTopic:topic];
    __weak typeof(self) weakSelf = self;
    __weak typeof(UMComFilterTopicsViewCell) *weakCell = cell;
    cell.clickOnTopic = ^(UMComTopic *topic){
        __strong typeof(weakCell) strongCell = weakCell;
        [weakSelf customObj:strongCell clickOnTopic:topic];
    };
    return cell;
}
#pragma requestDataMethod

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UMComClickActionDelegate
- (void)customObj:(UMComFilterTopicsViewCell *)cell clickOnFollowTopic:(UMComTopic *)topic
{
    __weak UMComFilterTopicsViewCell *weakCell = cell;
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        BOOL isFocus = [[topic is_focused] boolValue];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [UMComPushRequest followerWithTopic:topic isFollower:!isFocus completion:^(NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if (!error) {
                [weakCell setFocused:[[topic is_focused] boolValue]];
            } else {
                [UMComShowToast showFetchResultTipWithError:error];
            }
            [weakSelf.tableView reloadData];
        }];
    }];
}

- (void)customObj:(id)obj clickOnTopic:(UMComTopic *)topic
{
    if (!topic) {
        return;
    }
    UMComTopicFeedViewController *oneFeedViewController = nil;
    oneFeedViewController = [[UMComTopicFeedViewController alloc] initWithTopic:topic];
    [self.navigationController pushViewController:oneFeedViewController animated:YES];
}

- (void)searchTopicsFromLocalWithKeyWord:(NSString *)keyWord
{
    if ([keyWord isKindOfClass:[NSString class]] && keyWord.length > 0) {
        if (!self.originDataArray) {
            self.originDataArray = self.dataArray;
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains %@",keyWord];
        self.dataArray = [self.dataArray filteredArrayUsingPredicate:predicate];
        if (!self.searchTopicRequest) {
            self.searchTopicRequest = [[UMComSearchTopicRequest alloc]initWithKeywords:keyWord];
        }
        __weak typeof(self) weakSelf = self;
        [self.searchTopicRequest fetchRequestFromCoreData:^(NSArray *data, NSError *error) {
            if ([data isKindOfClass:[NSArray class]]) {
                weakSelf.dataArray = data;
                [weakSelf.tableView reloadData];
            }
        }];
    }else{
        self.dataArray = self.originDataArray;
        self.originDataArray = nil;
    }
    [self.tableView reloadData];
}

- (void)searchTopicsFromServerWithKeyWord:(NSString *)keyWord
{
    if ([keyWord isKindOfClass:[NSString class]] && keyWord.length > 0) {
        if (!self.originDataArray) {
            self.originDataArray = self.dataArray;
        }
        if (!self.searchTopicRequest) {
            self.searchTopicRequest = [[UMComSearchTopicRequest alloc]initWithKeywords:keyWord];
        }else{
            self.searchTopicRequest.keywords = keyWord;
        }
        __weak typeof(self) weakSelf = self;
        [self.searchTopicRequest fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            if (error) {
                [UMComShowToast showFetchResultTipWithError:error];
            }else{
                weakSelf.dataArray = data;
            }
            [weakSelf.tableView reloadData];
        }];
    }else{
        self.dataArray = self.originDataArray;
        self.originDataArray = nil;
        [self.tableView reloadData];
    }
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
