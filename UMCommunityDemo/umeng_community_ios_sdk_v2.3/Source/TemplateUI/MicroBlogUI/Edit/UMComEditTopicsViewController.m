//
//  UMComEditTopicsViewController.m
//  UMCommunity
//
//  Created by luyiyuan on 14/9/22.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComEditTopicsViewController.h"
#import "UMComSession.h"
#import "UMComTopic.h"
#import "UMComEditTopicsTableViewCell.h"
#import "UMComPullRequest.h"
#import "UMComShowToast.h"
#import "UMComRefreshView.h"


@interface UMComEditTopicsViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) void (^complectionBlock)(UMComTopic *topic);
@end

@implementation UMComEditTopicsViewController


- (instancetype)initWithTopicSelectedComplectionBlock:(void (^)(UMComTopic *))block
{
    self = [super init];
    if (self) {
        self.complectionBlock = block;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self.tableView registerNib:[UINib nibWithNibName:@"UMComEditTopicsTableViewCell" bundle:nil] forCellReuseIdentifier:@"EditTopicsCell"];
    self.tableView.rowHeight = 45;
    self.tableView.tableHeaderView = nil;
    self.tableView.tableFooterView = nil;
    self.loadMoreStatusView = nil;
    self.fetchRequest = [[UMComAllTopicsRequest alloc] initWithCount:TotalTopicSize];
    [self loadAllData:nil fromServer:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"EditTopicsCell";
    UMComEditTopicsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UMComEditTopicsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = @"";
    [cell setWithTopic:self.dataArray[indexPath.row]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UMComTopic *topic = self.dataArray[indexPath.row];
    
    if (self.complectionBlock) {
        self.complectionBlock(topic);
    }
}

@end
