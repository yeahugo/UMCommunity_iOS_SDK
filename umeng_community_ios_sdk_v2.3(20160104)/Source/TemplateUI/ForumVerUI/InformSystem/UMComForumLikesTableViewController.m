//
//  UMComForumLikesTableViewController.m
//  UMCommunity
//
//  Created by umeng on 15/11/30.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumLikesTableViewController.h"
#import "UMComLike.h"
#import "UMComPullRequest.h"
#import "UMComForumUserCenterViewController.h"
#import "UMComPostContentViewController.h"
#import "UMComClickActionDelegate.h"
#import "UMComUnReadNoticeModel.h"
#import "UMComSession.h"
#import "UIViewController+UMComAddition.h"
#import "UMComWebViewController.h"
#import "UMComForumSysLikeTableViewCell.h"
#import "UMComFeed+UMComManagedObject.h"
#import "UMComUser.h"
#import "UMComTopic.h"
#import "UMComMutiStyleTextView.h"

@interface UMComForumLikesTableViewController ()<UITableViewDelegate, UMComClickActionDelegate>

@property (nonatomic, strong) NSMutableArray *likeDicts;

@end

@implementation UMComForumLikesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.likeDicts = [NSMutableArray array];
    [self setForumUITitle:UMComLocalizedString(@"UMCom_Forum_Like", @"收到的赞")];

    self.fetchRequest = [[UMComUserLikesReceivedRequest alloc]initWithCount:BatchSize];
    [self loadAllData:nil fromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        [UMComSession sharedInstance].unReadNoticeModel.notiByLikeCount = 0;
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.likeDicts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UMComForumSysLikeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UMComForumSysLikeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID cellSize:CGSizeMake(tableView.frame.size.width, tableView.rowHeight)];
    }
    cell.delegate = self;
    NSDictionary *likeDict = self.likeDicts[indexPath.row];
    [cell reloadCellWithObj:[likeDict valueForKey:@"like"]
                 timeString:[likeDict valueForKey:@"creat_time"]
                   mutiText:nil
               feedMutiText:[likeDict valueForKey:@"feedMutiText"]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *likeDict = self.likeDicts[indexPath.row];
    return [[likeDict valueForKey:@"totalHeight"] floatValue];
}

#pragma mark - data handler

- (void)handleCoreDataDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if ([data isKindOfClass:[NSArray class]] &&  data.count > 0) {
        [self.likeDicts removeAllObjects];
        [self.tableView reloadData];
        [self inserLikes:data];
    }
}

- (void)handleServerDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        [self.likeDicts removeAllObjects];
        [self.tableView reloadData];
        [self inserLikes:data];
    }
    
    [self.indicatorView stopAnimating];
}

- (void)handleLoadMoreDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataArray];
        [tempArray addObjectsFromArray:data];
        self.dataArray = tempArray;
        [self inserLikes:data];
    }
}

- (void)inserLikes:(NSArray *)dataArray
{
    for (UMComLike *like in dataArray) {
        NSDictionary *commentDict = [self likeDictDictionaryWithLike:like];
        [self.likeDicts addObject:commentDict];
        NSInteger index = self.likeDicts.count - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (NSDictionary *)likeDictDictionaryWithLike:(UMComLike *)like
{
    CGFloat subViewWidth = self.view.frame.size.width - UMCom_SysCommonCell_SubViews_LeftEdge - UMCom_SysCommonCell_SubViews_RightEdge;
    if ([self.fetchRequest isKindOfClass:[UMComUserCommentsSentRequest class]]) {
        subViewWidth -= 15;
    }
    CGFloat totalHeight = UMCom_SysCommonCell_NameLabel_Height + UMCom_SysCommonCell_Content_TopEdge*2;
    NSMutableDictionary *likeDict = [NSMutableDictionary dictionary];
    [likeDict setValue:like forKey:@"like"];

    NSMutableArray *feedCheckWords = nil;
    UMComFeed *feed = like.feed;
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
    NSString *timeString = createTimeString(like.create_time);
    [likeDict setValue:timeString forKey:@"creat_time"];
    [likeDict setValue:feedMutiText forKey:@"feedMutiText"];
    [likeDict setValue:@(totalHeight) forKey:@"totalHeight"];
    return likeDict;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ClickActionDelegate
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
