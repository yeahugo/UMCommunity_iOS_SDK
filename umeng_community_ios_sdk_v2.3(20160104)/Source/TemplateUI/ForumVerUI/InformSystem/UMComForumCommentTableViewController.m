//
//  UMComForumCommentTableViewController.m
//  UMCommunity
//
//  Created by umeng on 15/11/30.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumCommentTableViewController.h"
#import "UMComComment.h"
#import "UMComTools.h"
#import "UMComPullRequest.h"
#import "UMComClickActionDelegate.h"
#import "UMComUser.h"
#import "UMComSession.h"
#import "UMComCommentEditView.h"
#import "UMComPushRequest.h"
#import "UMComShowToast.h"
#import "UMComForumUserCenterViewController.h"
#import "UMComPostContentViewController.h"
#import "UMComUnReadNoticeModel.h"
#import "UIViewController+UMComAddition.h"
#import "UMComWebViewController.h"
#import "UMComTopicPostViewController.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComMutiStyleTextView.h"
#import "UMComImageView.h"
#import "UMComForumSysCommentCell.h"
#import "UMComFeed.h"
#import "UMComTopic.h"

#define kUMComCommentFinishNotification @"kUMComCommentFinishNotification"


@interface UMComForumCommentTableViewController ()<UMComClickActionDelegate>

@property (nonatomic, strong) UMComCommentEditView *commentEditView;

@property (nonatomic, strong) NSMutableArray *commentDics;


@end

@implementation UMComForumCommentTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self setForumUITitle:UMComLocalizedString(@"UMCom_Forum_Comment", @"评论")];
   
    self.commentDics = [NSMutableArray array];
    
    if ([self.fetchRequest isKindOfClass:[UMComUserCommentsSentRequest class]]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewCommentFromNotice:) name:kUMComCommentFinishNotification object:nil];
    }
}

- (void)addNewCommentFromNotice:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[UMComComment class]]) {
        [self commentModlesWithCommentData:@[notification.object]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITabelViewDeleagte

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commentDics.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    
    UMComForumSysCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UMComForumSysCommentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId cellSize:CGSizeMake(tableView.frame.size.width, tableView.rowHeight)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.delegate = self;
    if ([self.fetchRequest isKindOfClass:[UMComUserCommentsSentRequest class]]) {
        cell.replyButton.hidden = YES;
    }
    NSDictionary *commentDict = self.commentDics[indexPath.row];
    [cell reloadCellWithObj:[commentDict valueForKey:@"comment"]
                 timeString:[commentDict valueForKey:@"creat_time"]
                   mutiText:[commentDict valueForKey:@"commentMutiText"]
               feedMutiText:[commentDict valueForKey:@"feedMutiText"]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *commentModel = self.commentDics[indexPath.row];
    return [[commentModel valueForKey:@"totalHeight"] floatValue];
}

#pragma mark - data handel

- (void)handleCoreDataDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if ([self.fetchRequest isKindOfClass:[UMComUserCommentsSentRequest class]]) {
        [UMComSession sharedInstance].unReadNoticeModel.notiByCommentCount = 0;
    }
    if ([data isKindOfClass:[NSArray class]] &&  data.count > 0) {
        [self.commentDics removeAllObjects];
        [self.tableView reloadData];
        self.dataArray = data;
        [self commentModlesWithCommentData:data];
    }
}

- (void)handleServerDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        [self.commentDics removeAllObjects];
        [self.tableView reloadData];
        self.dataArray = data;
        [self commentModlesWithCommentData:data];
    }
    [self.indicatorView stopAnimating];
}

- (void)handleLoadMoreDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        NSMutableArray *tempData = [NSMutableArray arrayWithArray:self.dataArray];
        [tempData addObject:data];
        self.dataArray = tempData;
        [self commentModlesWithCommentData:data];
    }
}

- (void)commentModlesWithCommentData:(NSArray *)dataArray
{
    for (UMComComment *comment in dataArray) {
        NSDictionary *commentDict = [self commentDictionaryWithComment:comment];
        [self.commentDics addObject:commentDict];
        NSInteger index = self.commentDics.count - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (NSDictionary *)commentDictionaryWithComment:(UMComComment *)comment
{
    CGFloat subViewWidth = self.view.frame.size.width - UMCom_SysCommonCell_SubViews_LeftEdge - UMCom_SysCommonCell_SubViews_RightEdge;
    if ([self.fetchRequest isKindOfClass:[UMComUserCommentsSentRequest class]]) {
        subViewWidth -= 15;
    }
    CGFloat totalHeight = UMCom_SysCommonCell_NameLabel_Height + UMCom_SysCommonCell_Content_TopEdge*2;
    NSMutableDictionary *commentDict = [NSMutableDictionary dictionary];
    [commentDict setValue:comment forKey:@"comment"];
    if (comment.content) {
        NSMutableString * replayStr = [NSMutableString stringWithString:@""];
        NSMutableArray *checkWords = nil;
        if (comment.reply_user) {
            [replayStr appendString:@"回复"];
            checkWords = [NSMutableArray arrayWithObject:[NSString stringWithFormat:UserNameString,comment.reply_user.name]];;
            //            [replayStr appendFormat:@"@%@：",comment.reply_user.name];
            [replayStr appendFormat:UserNameString,comment.reply_user.name];
            [replayStr appendFormat:@"："];
        }
        if (comment.content) {
            [replayStr appendFormat:@"%@",comment.content];
        }
        UMComMutiText *mutiText = [UMComMutiText mutiTextWithSize:CGSizeMake(subViewWidth, MAXFLOAT) font:UMComFontNotoSansLightWithSafeSize(14) string:replayStr lineSpace:2 checkWords:checkWords];
        totalHeight += mutiText.textSize.height;
        [commentDict setValue:mutiText forKey:@"commentMutiText"];
    }
    NSMutableArray *feedCheckWords = nil;
    UMComFeed *feed = comment.feed;
    NSString *feedString = feed.title;
    if (![feedString isKindOfClass:[NSString class]] || feedString.length == 0) {
        feedString = feed.text;
    }
    if ([feed.status integerValue] < FeedStatusDeleted) {
        if (feedString.length > kFeedContentLength) {
            feedString = [feedString substringWithRange:NSMakeRange(0, kFeedContentLength)];
        }
        feedCheckWords = [NSMutableArray array];
        for (UMComTopic *topic in feed.topics) {
            NSString *topicName = [NSString stringWithFormat:TopicString,topic.name];
            [feedCheckWords addObject:topicName];
        }
        for (UMComUser *user in feed.related_user) {
            NSString *userName = [NSString stringWithFormat:UserNameString,user.name];
            [feedCheckWords addObject:userName];
        }
    }else{
        feedString = UMComLocalizedString(@"Delete Content", @"该内容已被删除");
    }
    UMComMutiText *feedMutiText = [UMComMutiText mutiTextWithSize:CGSizeMake(subViewWidth-UMCom_SysCommonCell_FeedText_HorizonEdge*2, MAXFLOAT) font:UMComFontNotoSansLightWithSafeSize(14) string:feedString lineSpace:3 checkWords:feedCheckWords];
    totalHeight += feedMutiText.textSize.height;
    totalHeight += UMCom_SysCommonCell_Cell_BottomEdge;
    NSString *timeString = createTimeString(comment.create_time);
    [commentDict setValue:timeString forKey:@"creat_time"];
    [commentDict setValue:feedMutiText forKey:@"feedMutiText"];
    [commentDict setValue:@(totalHeight) forKey:@"totalHeight"];
    return commentDict;
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
                                        [[NSNotificationCenter defaultCenter] postNotificationName:kUMComCommentFinishNotification object:responseObject];
                                       [[NSNotificationCenter defaultCenter] postNotificationName:kUMComCommentOperationFinishNotification object:feed];
                                   }
                               }];
}


- (void)customObj:(id)obj clickOnFeedText:(UMComFeed *)feed
{
    UMComPostContentViewController *postContent = [[UMComPostContentViewController alloc]initWithFeed:feed];
    [self.navigationController pushViewController:postContent animated:YES];
}

- (void)customObj:(id)obj clickOnUser:(UMComUser *)user
{
    UMComForumUserCenterViewController *userCenter = [[UMComForumUserCenterViewController alloc]initWithUser:user];
    [self.navigationController pushViewController:userCenter animated:YES];
}

- (void)customObj:(id)obj clickOnTopic:(UMComTopic *)topic
{
    UMComTopicPostViewController *topicTableVc = [[UMComTopicPostViewController alloc] initWithTopic:topic];
    [self.navigationController pushViewController:topicTableVc animated:YES];
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




