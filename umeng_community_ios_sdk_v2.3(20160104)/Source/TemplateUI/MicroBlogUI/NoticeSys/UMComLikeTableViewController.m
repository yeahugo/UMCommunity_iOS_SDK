//
//  UMComLikeTableViewController.m
//  UMCommunity
//
//  Created by umeng on 15/12/22.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComLikeTableViewController.h"
#import "UMComLike.h"
#import "UMComSysLikeCell.h"
#import "UMComPullRequest.h"
#import "UMComClickActionDelegate.h"
#import "UMComUnReadNoticeModel.h"
#import "UMComSession.h"
#import "UIViewController+UMComAddition.h"
#import "UMComWebViewController.h"
#import "UMComUserCenterViewController.h"
#import "UMComTopicFeedViewController.h"
#import "UMComFeedDetailViewController.h"


@interface UMComLikeTableViewController ()<UITableViewDelegate, UMComClickActionDelegate>

@end

@implementation UMComLikeTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setForumUITitle:UMComLocalizedString(@"UMCom_Forum_Like", @"收到的赞")];
    
    self.fetchRequest = [[UMComUserLikesReceivedRequest alloc]initWithCount:BatchSize];
    [self loadAllData:nil fromServer:nil];
    // Do any additional setup after loading the view.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UMComSysLikeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UMComSysLikeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.delegate = self;
    [cell reloadCellWithLikeModel:self.dataArray[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UMComLikeModel *likeModle = self.dataArray[indexPath.row];
    return likeModle.totalHeight;
}

#pragma mark - data handler

- (void)handleCoreDataDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if ([data isKindOfClass:[NSArray class]] &&  data.count > 0) {
        self.dataArray = [self likeModelListWithLikes:data];
    }
    if (finishHandler) {
        finishHandler();
    }
}

- (void)handleServerDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error) {
        [UMComSession sharedInstance].unReadNoticeModel.notiByLikeCount = 0;
        self.dataArray = [self likeModelListWithLikes:data];
    }
    if (finishHandler) {
        finishHandler();
    }
}

- (void)handleLoadMoreDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataArray];
        [tempArray addObjectsFromArray:[self likeModelListWithLikes:data]];
        self.dataArray = tempArray;
    }
    if (finishHandler) {
        finishHandler();
    }
}

- (NSArray *)likeModelListWithLikes:(NSArray *)likes
{
    if ([likes isKindOfClass:[NSArray class]] && likes.count > 0) {
        NSMutableArray *likeModels = [NSMutableArray arrayWithCapacity:likes.count];
        for (UMComLike *like in likes) {
            UMComLikeModel *likeModel = [UMComLikeModel likeModelWithLike:like viewWidth:self.view.frame.size.width];
            [likeModels addObject:likeModel];
        }
        return likeModels;
    }
    return nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ClickActionDelegate
- (void)customObj:(id)obj clickOnFeedText:(UMComFeed *)feed
{
    UMComFeedDetailViewController *postContent = [[UMComFeedDetailViewController alloc]initWithFeed:feed];
    [self.navigationController pushViewController:postContent animated:YES];
}

- (void)customObj:(id)obj clickOnUser:(UMComUser *)user
{
    UMComUserCenterViewController *userCenter = [[UMComUserCenterViewController alloc]initWithUser:user];
    [self.navigationController pushViewController:userCenter animated:YES];
}

- (void)customObj:(id)obj clickOnTopic:(UMComTopic *)topic
{
    UMComTopicFeedViewController *topicFeedVc = [[UMComTopicFeedViewController alloc]initWithTopic:topic];
    [self.navigationController pushViewController:topicFeedVc animated:YES];
}

- (void)customObj:(id)obj clickOnURL:(NSString *)url
{
    UMComWebViewController * webViewController = [[UMComWebViewController alloc] initWithUrl:url];
    [self.navigationController pushViewController:webViewController animated:YES];
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
