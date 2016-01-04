
//
//  UMComTopicTypeViewController.m
//  UMCommunity
//
//  Created by umeng on 15/12/8.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumTopicTypeTableViewController.h"
#import "UMComPullRequest.h"
#import "UMComTopic.h"
#import "UMComForumTopicTableViewController.h"
#import "UMComSession.h"
#import "UMComTopicType.h"
#import "UMComForum_AllTopicTableViewCell.h"
#import "UMComPushRequest.h"

#define UMCom_Forum_TopicType_Cell_Height 70

@interface UMComForumTopicTypeTableViewController ()

@end

@implementation UMComForumTopicTypeTableViewController



- (void)viewDidLoad {
    self.fetchRequest = [[UMComTopicTypesRequest alloc]initWithCount:BatchSize];
   
    [super viewDidLoad];
    
    self.tableView.rowHeight = UMCom_Forum_TopicType_Cell_Height;
}

#pragma mark - tableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(UMCom_Forum_Topic_Edge_Left*2 + UMCom_Forum_Topic_Icon_Width, UMCom_Forum_TopicType_Cell_Height, 0, 0)];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(UMCom_Forum_Topic_Edge_Left*2 + UMCom_Forum_Topic_Icon_Width, UMCom_Forum_TopicType_Cell_Height, 0, 0)];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"TopicTypeCellID";
    UMComForum_AllTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UMComForum_AllTopicTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId cellSize:CGSizeMake(self.view.frame.size.width, UMCom_Forum_TopicType_Cell_Height)];
    }
    cell.index = indexPath.row;
    cell.button.center = CGPointMake(cell.button.center.x, cell.frame.size.height/2);
    UMComTopicType *topicType = self.dataArray[indexPath.row];
    [cell reloadWithIconUrl:topicType.icon_url topicName:topicType.name topicDetail:topicType.type_description];
    cell.button.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UMComForumTopicTableViewController *topicViewController = [[UMComForumTopicTableViewController alloc]init];
    UMComTopicType *topicType = self.dataArray[indexPath.row];
    topicViewController.fetchRequest = [[UMComTopicTypeTopicsRequest alloc] initWithCount:BatchSize categoryId:topicType.category_id];
    topicViewController.isAutoStartLoadData = YES;
    [self.navigationController pushViewController:topicViewController animated:YES];
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
