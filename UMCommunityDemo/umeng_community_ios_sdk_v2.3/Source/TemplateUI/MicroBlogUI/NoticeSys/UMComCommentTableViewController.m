//
//  UMComCommentTableViewController.m
//  UMCommunity
//
//  Created by umeng on 15/12/22.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComCommentTableViewController.h"
#import "UMComComment.h"
#import "UMComTools.h"
#import "UMComPullRequest.h"
#import "UMComSysCommentCell.h"
#import "UMComClickActionDelegate.h"
#import "UMComUser.h"
#import "UMComSession.h"
#import "UMComCommentEditView.h"
#import "UMComPushRequest.h"
#import "UMComShowToast.h"
#import "UMComUserCenterViewController.h"
#import "UMComTopicFeedViewController.h"
#import "UMComFeedDetailViewController.h"
#import "UMComUnReadNoticeModel.h"
#import "UIViewController+UMComAddition.h"
#import "UMComWebViewController.h"


@interface UMComCommentTableViewController ()<UMComClickActionDelegate>

@property (nonatomic, strong) UMComCommentEditView *commentEditView;


@end

@implementation UMComCommentTableViewController



- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setForumUITitle:UMComLocalizedString(@"UMCom_Forum_Comment", @"评论")];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - UITabelViewDeleagte
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    
    UMComSysCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UMComSysCommentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.delegate = self;
    UMComCommentModel *commentModel = self.dataArray[indexPath.row];
    [cell reloadCellWithLikeModel:commentModel];
    if ([self.fetchRequest isKindOfClass:[UMComUserCommentsSentRequest class]]) {
        cell.replyButton.hidden = YES;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UMComCommentModel *commentModel = self.dataArray[indexPath.row];
    return commentModel.totalHeight;
}

#pragma mark - data handel

- (void)handleCoreDataDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if ([data isKindOfClass:[NSArray class]] &&  data.count > 0) {
        self.dataArray = [self commentModlesWithCommentData:data];
    }
    if (finishHandler) {
        finishHandler();
    }
}

- (void)handleServerDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error) {
        if ([self.fetchRequest isKindOfClass:[UMComUserCommentsSentRequest class]]) {
            [UMComSession sharedInstance].unReadNoticeModel.notiByCommentCount = 0;
        }
        self.dataArray = [self commentModlesWithCommentData:data];
    }
    if (finishHandler) {
        finishHandler();
    }
}

- (void)handleLoadMoreDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        self.dataArray = [self commentModlesWithCommentData:data];
    }
    if (finishHandler) {
        finishHandler();
    }
}

- (NSArray *)commentModlesWithCommentData:(NSArray *)dataArray
{
    if ([dataArray isKindOfClass:[NSArray class]] && dataArray.count >0) {
        NSMutableArray *commentModels = [NSMutableArray arrayWithCapacity:dataArray.count];
        for (UMComComment *comment in dataArray) {
            UMComCommentModel *commentModle = [UMComCommentModel commentModelWithComment:comment viewWidth:self.view.frame.size.width commentTextViewDelta:15];
            if (commentModle) {
                [commentModels addObject:commentModle];
            }
        }
        return commentModels;
    }
    return nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UMComClickActionDelegate
- (void) customObj:(id)obj clickOnComment:(UMComComment *)comment feed:(UMComFeed *)feed
{
    if (!self.commentEditView) {
        self.commentEditView = [[UMComCommentEditView alloc]initWithSuperView:[UIApplication sharedApplication].keyWindow];
    }
    __weak typeof(self) weakSelf = self;
    self.commentEditView.SendCommentHandler = ^(NSString *commentText){
        [weakSelf postComment:commentText comment:comment feed:feed];
    };
    [self.commentEditView presentEditView];
    self.commentEditView.commentTextField.placeholder = [NSString stringWithFormat:@"回复%@",[[comment creator] name]];
}

- (void)postComment:(NSString *)content comment:(UMComComment *)comment feed:(UMComFeed *)feed
{
    __weak typeof (self) weakSelf = self;
    [UMComPushRequest commentFeedWithFeed:feed
                           commentContent:content
                             replyComment:comment
                     commentCustomContent:nil
                                   images:nil
                               completion:^(id responseObject,NSError *error) {
                                   if (error) {
                                       [UMComShowToast showFetchResultTipWithError:error];
                                   }else{
                                       NSMutableArray *commentModels = [NSMutableArray arrayWithCapacity:1];
                                       UMComCommentModel *commentModle = [UMComCommentModel commentModelWithComment:comment viewWidth:weakSelf.view.frame.size.width commentTextViewDelta:15];
                                       if (commentModle) {
                                           [commentModels addObject:commentModle];
                                       }
                                       [weakSelf.tableView reloadData];
                                       [[NSNotificationCenter defaultCenter] postNotificationName:kUMComCommentOperationFinishNotification object:feed];
                                   }
                               }];
}


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
