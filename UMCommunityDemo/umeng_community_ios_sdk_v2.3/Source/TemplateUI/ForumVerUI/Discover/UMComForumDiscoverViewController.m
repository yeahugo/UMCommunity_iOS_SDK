//
//  UMComForumFindViewController.m
//  UMCommunity
//
//  Created by umeng on 15/11/17.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumDiscoverViewController.h"
#import "UMComFindTableViewCell.h"
#import "UMComAction.h"
#import "UMComUsersTableViewController.h"
#import "UMComSettingViewController.h"
#import "UIViewController+UMComAddition.h"
#import "UMComForumUserCenterViewController.h"
#import "UMComSession.h"
#import "UMComForumTopicTableViewController.h"
#import "UMComForumUserTableViewController.h"
#import "UMComPostTableViewController.h"
#import "UMComRemoteNoticeViewController.h"
#import "UMComPullRequest.h"
#import "UMComUnReadNoticeModel.h"
#import "UMComPostNearbyTableViewController.h"
#import "UMComForumInformCenterTableViewController.h"


@interface UMComForumDiscoverViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIButton *rightButton;

@property (nonatomic, strong) UIView *systemNotificationView;

@property (nonatomic, strong) UIView *userMessageView;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation UMComForumDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setForumUIBackButton];
    [self setForumUITitle:UMComLocalizedString(@"find", @"发现")];
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"UMComFindTableViewCell" bundle:nil] forCellReuseIdentifier:@"FindTableViewCell"];
    self.tableView.rowHeight = 55.0f;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self refreshNoticeItemViews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNoticeItemViews) name:kUMComUnreadNotificationRefreshNotification object:nil];
    [self refreshNoticeItemViews];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.rightButton removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshNoticeItemViews
{
    [self.tableView reloadData];
}

- (UIView *)creatNoticeViewWithOriginX:(CGFloat)originX
{
    CGFloat noticeViewWidth = 7;
    UIView *itemNoticeView = [[UIView alloc]initWithFrame:CGRectMake(originX,0, noticeViewWidth, noticeViewWidth)];
    itemNoticeView.backgroundColor = [UIColor redColor];
    itemNoticeView.layer.cornerRadius = noticeViewWidth/2;
    itemNoticeView.clipsToBounds = YES;
    itemNoticeView.hidden = YES;
    return itemNoticeView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 5;
    }
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"FindTableViewCell";
    UMComFindTableViewCell *cell = (UMComFindTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.titleImageView.image = UMComImageWithImageName(@"um_friend");
            cell.titleNameLabel.text = UMComLocalizedString(@"um_friend", @"好友圈");
        }else if(indexPath.row == 1){
            cell.titleImageView.image = UMComImageWithImageName(@"um_near");
            cell.titleNameLabel.text = UMComLocalizedString(@"um_near", @"附近推荐");
        }else if(indexPath.row == 2){
            cell.titleImageView.image = UMComImageWithImageName(@"um_newcontent");
            cell.titleNameLabel.text = UMComLocalizedString(@"um_newcontent", @"实时内容");
        }
        else if(indexPath.row == 3){
            cell.titleImageView.image = UMComImageWithImageName(@"user_recommend");
            cell.titleNameLabel.text = UMComLocalizedString(@"user_recommend", @"用户推荐");
        }else if(indexPath.row == 4){
            cell.titleImageView.image = UMComImageWithImageName(@"topic_recommend");
            cell.titleNameLabel.text = UMComLocalizedString(@"topic_recommend", @"话题推荐");
        }
    }else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            cell.titleImageView.image = UMComImageWithImageName(@"um_collection+");
            cell.titleNameLabel.text = UMComLocalizedString(@"um_collection", @"我的收藏");
        }else{
            cell.titleImageView.image = UMComImageWithImageName(@"um_notice_f");
            cell.titleNameLabel.text = UMComLocalizedString(@"um_news_notice", @"我的消息");
            
            UMComUnReadNoticeModel *unReadNotice = [UMComSession sharedInstance].unReadNoticeModel;
            if (unReadNotice.totalNotiCount == 0) {
                self.userMessageView.hidden = YES;
            }else{
                if (!self.userMessageView) {
                    self.userMessageView = [self creatNoticeViewWithOriginX:110];
                    self.userMessageView.center = CGPointMake(self.userMessageView.center.x, cell.titleNameLabel.frame.origin.y+11);
                    [cell.contentView addSubview:self.userMessageView];
                } else {
                    if (self.userMessageView.superview != cell.contentView) {
                        [self.userMessageView removeFromSuperview];
                        [cell addSubview:self.userMessageView];
                    }
                }
                self.userMessageView.hidden = NO;
            }
        }
    }else{
        if (indexPath.row == 0) {
            cell.titleImageView.image = UMComImageWithImageName(@"user_center");
            cell.titleNameLabel.text = UMComLocalizedString(@"user_center", @"个人中心");
        }else{
            cell.titleImageView.image = UMComImageWithImageName(@"setting");
            cell.titleNameLabel.text = UMComLocalizedString(@"setting", @"设置");
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 50.0f;
    }else{
        return 70.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return [self headViewWithTitle:UMComLocalizedString(@"recommend", @"推荐") viewHeight:50];
    }else if(section == 1){
        return [self headViewWithTitle:UMComLocalizedString(@"Mine", @"我的") viewHeight:70];
    }else{
        return [self headViewWithTitle:UMComLocalizedString(@"Other", @"其它") viewHeight:70];
    }
}

- (UIView *)headViewWithTitle:(NSString *)title viewHeight:(CGFloat)viewHeight
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, viewHeight)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(13, viewHeight-30-5, 50, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.text = title;
    label.textColor = [UMComTools colorWithHexString:FontColorGray];
    [view addSubview:label];
    UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0,viewHeight-0.5,view.frame.size.width,0.5)];
    bottomLine.backgroundColor = TableViewSeparatorRGBColor;
    [view addSubview:bottomLine];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        UIView *topLine = [[UIView alloc]initWithFrame:CGRectMake(0,0,view.frame.size.width,0.5)];
        topLine.backgroundColor = TableViewSeparatorRGBColor;
        [view addSubview:topLine];
    }
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self tranToCircleFriends];
        }else if (indexPath.row == 1) {
            [self tranToNearby];
        }else if (indexPath.row == 2) {
            [self tranToRealTimeFeeds];
        }else if (indexPath.row == 3){
            [self tranToRecommendUsers];
        }else if (indexPath.row == 4) {
            [self tranToRecommendTopics];
        }
    }else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            [self tranToUsersFavourites];
        }else{
            [self tranToUsersNotice];
        }
    }else{
        if (indexPath.row == 0) {
            [self tranToUserCenter];
        }else{
            [self tranToSetting];
        }
    }
}

- (void)tranToCircleFriends
{
    UMComPostTableViewController *friendViewController = [[UMComPostTableViewController alloc]init];
    friendViewController.fetchRequest = [[UMComFriendFeedsRequest alloc]initWithCount:BatchSize];
    friendViewController.isAutoStartLoadData = YES;
    friendViewController.isLoadLoacalData = NO;
    friendViewController.title = UMComLocalizedString(@"circle_friends", @"好友圈");
    [self.navigationController pushViewController:friendViewController animated:YES];
}

- (void)tranToNearby
{
    UMComPostNearbyTableViewController *nearbyFeedController = [[UMComPostNearbyTableViewController alloc]init];
    nearbyFeedController.title = UMComLocalizedString(@"nearby_recommend", @"附近推荐");
    [self.navigationController pushViewController:nearbyFeedController animated:YES];
}

- (void)tranToRealTimeFeeds
{
    UMComPostTableViewController *realTimeFeedsViewController = [[UMComPostTableViewController alloc] initWithFetchRequest:[[UMComAllNewFeedsRequest alloc]initWithCount:BatchSize]];
    realTimeFeedsViewController.isAutoStartLoadData = YES;
    realTimeFeedsViewController.isLoadLoacalData = NO;
    realTimeFeedsViewController.title = UMComLocalizedString(@"um_newcontent", @"实时内容");
    [self.navigationController  pushViewController:realTimeFeedsViewController animated:YES];
}


- (void)tranToRecommendUsers
{
    UMComForumUserTableViewController *userRecommendViewController = [[UMComForumUserTableViewController alloc] init];
    userRecommendViewController.fetchRequest = [[UMComRecommendUsersRequest alloc]initWithCount:BatchSize];
    userRecommendViewController.isAutoStartLoadData = YES;
    userRecommendViewController.title = UMComLocalizedString(@"user_recommend", @"用户推荐");
    [self.navigationController  pushViewController:userRecommendViewController animated:YES];
}


- (void)tranToRecommendTopics
{
    UMComForumTopicTableViewController *topicsRecommendViewController = [[UMComForumTopicTableViewController alloc] init];
    topicsRecommendViewController.title = UMComLocalizedString(@"user_topic_recommend", @"推荐话题");
    topicsRecommendViewController.fetchRequest = [[UMComRecommendTopicsRequest alloc]initWithCount:BatchSize];
    topicsRecommendViewController.isAutoStartLoadData = YES;
    [self.navigationController  pushViewController:topicsRecommendViewController animated:YES];
}

- (void)tranToUsersFavourites
{
    UMComPostTableViewController *favouratesViewController = [[UMComPostTableViewController alloc] init];
    favouratesViewController.fetchRequest = [[UMComUserFavouritesRequest alloc] init];
    favouratesViewController.title = UMComLocalizedString(@"user_collection", @"我的收藏");
    favouratesViewController.isAutoStartLoadData = YES;
    [self.navigationController  pushViewController:favouratesViewController animated:YES];
}

- (void)tranToUsersNotice
{
    self.userMessageView.hidden = YES;
    UMComForumInformCenterTableViewController *userNewaNoticeViewController = [[UMComForumInformCenterTableViewController alloc] init];
    [self.navigationController  pushViewController:userNewaNoticeViewController animated:YES];
}

- (void)tranToUserCenter
{
    
    UMComForumUserCenterViewController *userCenterViewController = [[UMComForumUserCenterViewController alloc] initWithUser:[UMComSession sharedInstance].loginUser];
    [self.navigationController pushViewController:userCenterViewController animated:YES];
}

- (void)tranToSetting
{
    UMComSettingViewController *settingVc = [[UMComSettingViewController alloc]initWithNibName:@"UMComSettingViewController" bundle:nil];
    [self.navigationController pushViewController:settingVc animated:YES];
}
//
//
//- (void)noticeVc
//{
//    UMComRemoteNoticeViewController *remoteNoticeVc = [[UMComRemoteNoticeViewController alloc]init];
//    self.systemNotificationView.hidden = YES;
//    [self.navigationController pushViewController:remoteNoticeVc animated:YES];
//}

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
