//
//  UMComForumTopicTableViewController.m
//  UMCommunity
//
//  Created by umeng on 15/11/26.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumTopicTableViewController.h"
#import "UMComTopic.h"
#import "UMComPullRequest.h"
#import "UMComForumTopicTableViewCell.h"
#import "UMComAction.h"
#import "UMComPushRequest.h"
#import "UMComShowToast.h"
#import "UMComTopicPostViewController.h"
#import "UMComForum_AllTopicTableViewCell.h"


const static CGFloat g_topiccell_height = 65.f;

@interface UMComForumTopicTableViewController ()
@end

@implementation UMComForumTopicTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tableView.rowHeight = g_topiccell_height;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    // Do any additional setup after loading the view.
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(UMCom_Forum_Topic_Edge_Left*2 + UMCom_Forum_Topic_Icon_Width, g_topiccell_height, 0, 0)];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(UMCom_Forum_Topic_Edge_Left*2 + UMCom_Forum_Topic_Icon_Width, g_topiccell_height, 0, 0)];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UMComForumTopicTableViewCell *cell = (UMComForumTopicTableViewCell *)[self cellForIndexPath:indexPath];
    return cell;
   // return [self recommendTopicCellForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"TopicCellID";
    UMComForumTopicTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UMComForumTopicTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId cellSize:CGSizeMake(self.tableView.frame.size.width, self.tableView.rowHeight)];
    }
    __weak typeof(self) weakSelf = self;
    cell.index = indexPath.row;
    [cell.button setBackgroundImage:nil forState:UIControlStateNormal];
    UMComTopic *topic = self.dataArray[indexPath.row];
    [cell reloadWithTopic:topic];
    cell.clickOnButton = ^(UMComForumTopicTableViewCell *cell){
        [weakSelf followTopicAtCell:cell index:indexPath];
    };
//    cell.button.imageView.image = nil;
    return cell;
}


- (void)followTopicAtCell:(UMComForumTopicTableViewCell *)cell index:(NSIndexPath *)indexPath
{
    id object = self.dataArray[indexPath.row];
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        UMComTopic *topic = object;
        [UMComPushRequest followerWithTopic:topic isFollower:![topic.is_focused boolValue] completion:^(NSError *error) {
            if (error) {
                [UMComShowToast showFetchResultTipWithError:error];
            }
            [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [self showTopicPostTableViewWithTopicAtIndexPath:indexPath];
}


- (void)showTopicPostTableViewWithTopicAtIndexPath:(NSIndexPath *)indexPath
{
    UMComTopic *topic = self.dataArray[indexPath.row];
    
    UMComTopicPostViewController *topicPostListController = [[UMComTopicPostViewController alloc] initWithTopic:topic];
    
    [self.navigationController pushViewController:topicPostListController animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
