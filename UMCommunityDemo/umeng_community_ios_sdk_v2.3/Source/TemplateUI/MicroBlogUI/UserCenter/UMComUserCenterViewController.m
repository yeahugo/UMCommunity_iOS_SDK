//
//  UMComUserCenterViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 9/10/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComUserCenterViewController.h"
#import "UMComGenderView.h"
#import "UMComTopicFeedViewController.h"
#import "UMComSession.h"
#import "UMComProfileSettingController.h"
#import "UMComShowToast.h"
#import "UMComAction.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMUtils.h"
#import "UMComUserCollectionViewController.h"
#import "UIViewController+UMComAddition.h"
#import "UMComUser.h"
#import "UMComImageView.h"
#import "UMComTopicsTableViewController.h"
#import "UMComPhotoAlbumViewController.h"
#import "UMComActionStyleTableView.h"
#import "UMComPushRequest.h"
#import "UMComPullRequest.h"
#import "UMComRefreshView.h"
#import "UMComClickActionDelegate.h"
#import "UMComScrollViewDelegate.h"
#import "UMComCoreData.h"
#import "UMComFeedTableViewController.h"
#import "UMComFeed.h"

#define SuperAdmin 3 //超级管理员

typedef enum {
    UMComUserCenterDataFeeds = 0,
    UMComUserCenterDataFollows = 1,
    UMComUserCenterDataFans = 2
}UMComUserCenterDataType;

@interface UMComUserCenterViewController ()<UMComClickActionDelegate, UMComScrollViewDelegate>


//其他
@property (nonatomic, strong) UMComUser *user;
@property (nonatomic) UMComUserCenterDataType curDataType;
@property (nonatomic) UMComUserCenterDataType lastDataType;


@property (nonatomic, strong) UMComActionStyleTableView *actionTableView;
@property (nonatomic, strong) UIView *shadowBgView;
@property (nonatomic, strong) UMComUserProfileRequest *userProfileRequest;
@property (nonatomic, strong) UMComGenderView *genderView;
@property (nonatomic, strong) UIViewController *lastViewController;

@end


@implementation UMComUserCenterViewController

-(id)initWithUser:(UMComUser *)user
{
    self = [super initWithNibName:@"UMComUserCenterViewController" bundle:nil];
    if (self) {
        self.user = user;
    }
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (UMSYSTEM_VERSION_GREATER_THAN(@"7")) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    //性别提示图标
    UMComGenderView *genderView = [[UMComGenderView alloc] initWithGender:UMComUserGenderFemale];
    genderView.frame = CGRectMake(genderView.frame.size.width + self.userName.frame.size.width+self.userName.frame.origin.x+6, self.userName.frame.origin.y + 4, 12, 12);
    [self.headerView addSubview:genderView];
    if ([self.user.gender integerValue] == 1) {
        [genderView setUserGender:UMComUserGenderMale];
    }
    genderView.hidden = YES;
    self.genderView = genderView;
    
    [self setTitleViewWithTitle:self.user.name];
    
    [self resetBaseInfoViews];
    

    if (self.user) {
        [self refreshBaseInformationWithUserProfile:self.user];
    }
    [self updateUserProfile];
    
    [self creatChildViewControllers];
    
    [self.view addSubview:_headerView];
    
    if (![[UMComSession sharedInstance].uid isEqualToString:self.user.uid] && [self.user.atype intValue] != 3) {
        [self setRightButtonWithImageName:@"um_diandiandian" action:@selector(userSpam)];
   
    }
    if ([self.user.uid isEqualToString:[UMComSession sharedInstance].uid]) {
         //当关注某个用户成功是同时刷新登录用户的个人中心页面
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserFollow:) name:kUMComFollowUserSucceedNotification object:nil];
        //当更新个人信息时刷新自己的个人中心页面
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserProfile) name:UpdateUserProfileSuccess object:nil];
        //当删除自己的Feed时通知当前页面刷新
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyDataWithDeletedFeed:) name:kUMComFeedDeletedFinishNotification object:nil];
        //当删除自己的Feed时通知当前页面刷新
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewFeedDataWhenFeedCreatSucceed:) name:kNotificationPostFeedResultNotification object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self resetSubViewsFrame];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
};

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)resetBaseInfoViews
{
    self.topLine.frame = CGRectMake(0, 0, self.topLine.frame.size.width, 0.3);
    self.topLine.backgroundColor = TableViewSeparatorRGBColor;
    self.bottomLine.frame = CGRectMake(0, self.bottomLine.frame.origin.y+0.7, self.bottomLine.frame.size.width, 0.3);
    self.bottomLine.backgroundColor = TableViewSeparatorRGBColor;
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
    self.profileImageView.clipsToBounds = YES;
    UIFont *menuFont = UMComFontNotoSansLightWithSafeSize(14);
    self.userName.font = menuFont;
    self.feedNumber.font = menuFont;
    self.followerNumber.font = menuFont;
    self.fanNumber.font = menuFont;
    self.albumLabel.font = menuFont;
    self.topicLabel.font = menuFont;
    self.feedButton.titleLabel.font = menuFont;
    self.focus.titleLabel.font = menuFont;
    self.followButton.titleLabel.font = menuFont;
    self.feedButton.titleLabel.font = menuFont;
    self.fanButton.titleLabel.font = menuFont;
}

- (void)resetSubViewsFrame
{
    for (UIViewController *viewController in self.childViewControllers) {
        CGRect frame = viewController.view.frame;
        frame.size.width = self.view.frame.size.width;
        frame.size.height = self.view.frame.size.height;
        viewController.view.frame = frame;
    }
}

//创建子ViewControllers
- (void)creatChildViewControllers
{
    CGRect frame = self.view.frame;
    UMComFeedTableViewController *feedTableViewController = [[UMComFeedTableViewController alloc]initWithFetchRequest:[[UMComUserFeedsRequest alloc] initWithUid:self.user.uid count:BatchSize type:UMComTimeLineTypeDefault]];
    feedTableViewController.view.frame = frame;
    feedTableViewController.tableView.tableHeaderView = [[UIView alloc]initWithFrame:self.headerView.frame];
    [self.view addSubview:feedTableViewController.view];
    [self addChildViewController:feedTableViewController];
    feedTableViewController.scrollViewDelegate = self;
    
    frame.origin.x = self.view.frame.size.width *3/2;
    UMComUserCollectionViewController *followersTableViewController = [[UMComUserCollectionViewController alloc] initWithFetchRequest:[[UMComFollowersRequest alloc] initWithUid:self.user.uid count:BatchSize]];
    followersTableViewController.headerViewHeight = self.headerView.frame.size.height;
    followersTableViewController.scrollViewDelegate = self;
    followersTableViewController.view.frame = frame;
    [self addChildViewController:followersTableViewController];
    
    UMComUserCollectionViewController *fanTableViewController = [[UMComUserCollectionViewController alloc]initWithFetchRequest:[[UMComFansRequest alloc] initWithUid:self.user.uid count:BatchSize]];
    fanTableViewController.scrollViewDelegate = self;
    fanTableViewController.headerViewHeight = self.headerView.frame.size.height;
    fanTableViewController.view.frame = frame;
    [self addChildViewController:fanTableViewController];
    
    [self changeDataType:UMComUserCenterDataFeeds];
    
}

- (void)changeDataType:(UMComUserCenterDataType)dataType
{
    [self setOtherWithType:dataType];
    UIViewController *viewController = self.childViewControllers[dataType];
    if (dataType == 0) {
        UMComRequestTableViewController *requestTableViewController = (UMComRequestTableViewController *)viewController;
        if (requestTableViewController.isLoadFinish && requestTableViewController.dataArray.count == 0) {
            [requestTableViewController loadAllData:nil fromServer:nil];
        }
    }else{
        UMComUserCollectionViewController *collectionViewController = (UMComUserCollectionViewController *)viewController;
        if (collectionViewController.userList.count == 0) {
            [collectionViewController refreshDataFromServer:nil];
        }
    }
    __weak typeof(self) weakSelf = self;
    [self transitionFromViewControllerAtIndex:_lastDataType toViewControllerAtIndex:_curDataType animations:^{
        [weakSelf.view bringSubviewToFront:weakSelf.headerView];
    } completion:nil];
}



- (void)showActionTableViewWithImageNameList:(NSArray *)imageNameList titles:(NSArray *)titles
{
    if (!self.actionTableView) {
        self.actionTableView = [[UMComActionStyleTableView alloc]initWithFrame:CGRectMake(15, self.view.frame.size.height, self.view.frame.size.width-30, 90) style:UITableViewStylePlain];
    }
    __weak UMComUserCenterViewController *weakSelf = self;
    self.actionTableView.didSelectedAtIndexPath = ^(NSString *title, NSIndexPath *indexPath){
        [UMComPushRequest spamWithUser:weakSelf.user completion:^(NSError *error) {
            [UMComShowToast spamUser:error];
        }];
    };
    [self.actionTableView setImageNameList:imageNameList titles:titles];
    [self.actionTableView showActionSheet];
}

- (void)userSpam
{
    [self showActionTableViewWithImageNameList:[NSArray arrayWithObjects:@"um_spam", nil] titles:[NSArray arrayWithObjects:UMComLocalizedString(@"spam", @"举报"), nil]];
}

#pragma mark - data update

- (void)addNewFeedDataWhenFeedCreatSucceed:(NSNotification *)notification
{
    UMComFeed *newFeed = (UMComFeed *)notification.object;
    UMComFeedTableViewController *feedViewController = self.childViewControllers[0];
    [feedViewController insertFeedStyleToDataArrayWithFeed:newFeed];
}

- (void)refreshUserFollow:(NSNotification *)notification
{
    UMComUser *followUser = notification.object;
    if (![followUser isKindOfClass:[UMComUser class]]) {
        return;
    }
    if (![self.user.uid isEqualToString:[UMComSession sharedInstance].uid]) {
        return;
    }
    UMComUserCollectionViewController *userColloection = self.childViewControllers[1];
    if ([followUser.has_followed boolValue]) {
        [userColloection inserUser:followUser atIndex:0];
    }else
    {
        [userColloection deleteUser:followUser];
    }
    [self refreshBaseInformationWithUserProfile:[UMComSession sharedInstance].loginUser];
}

- (void)updateMyDataWithDeletedFeed:(NSNotification *)notification
{
    if ([self.user.uid isEqualToString:[UMComSession sharedInstance].uid]) {
        UMComFeed *deleteFeed = notification.object;
        UMComFeedTableViewController *feedTableVc = self.childViewControllers[0];
        [feedTableVc deleteFeed:deleteFeed];
        [self refreshBaseInformationWithUserProfile:[UMComSession sharedInstance].loginUser];
    }
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - get user info data methods

-(IBAction)onClickAlbum:(id)sender
{
    UMComPhotoAlbumViewController *photoAlbumVc = [[UMComPhotoAlbumViewController alloc]init];
    photoAlbumVc.user = self.user;
    [self.navigationController pushViewController:photoAlbumVc animated:YES];
}

-(IBAction)onClickTopic:(id)sender
{
    UMComTopicsTableViewController *topicsViewController = [[UMComTopicsTableViewController alloc] init];
    topicsViewController.title = UMComLocalizedString(@"follow_topics", @"关注话题");
    topicsViewController.isAutoStartLoadData = YES;
    topicsViewController.fetchRequest = [[UMComUserTopicsRequest alloc]initWithUid:self.user.uid count:FocusTopicNum];
    [self.navigationController pushViewController:topicsViewController animated:YES];
}

#pragma mark - 
//请求详细信息
- (void)updateUserProfile
{
    NSString *uid = self.user.uid;
    if(!uid){
        uid = [UMComSession sharedInstance].uid;
    }
    if (!self.userProfileRequest) {
        UMComUserProfileRequest *userProfileRequest = [[UMComUserProfileRequest alloc] initWithUid:uid sourceUid:nil];
        self.userProfileRequest = userProfileRequest;
    }
    __weak typeof(self) weakSelf = self;
    [self.userProfileRequest fetchRequestFromCoreData:^(NSArray *data, NSError *error) {
        UMComUser *userProfile = data.firstObject;
        if (userProfile) {
            [weakSelf refreshBaseInformationWithUserProfile:userProfile];
        }
        [weakSelf.userProfileRequest fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            if (data.count > 0) {
                UMComUser *profile = data.firstObject;
                if (profile) {
                    [weakSelf refreshBaseInformationWithUserProfile:profile];
                }
            }else{
                [UMComShowToast fetchFailWithNoticeMessage:  UMComLocalizedString(@"user info load fail",@"个人信息加载失败")];
            }
        }];
    }];
}

- (void)refreshBaseInformationWithUserProfile:(UMComUser *)user
{
    self.user = user;
    //请求头像
    NSString *iconURL = [user iconUrlStrWithType:UMComIconSmallType];
    [self.profileImageView setImageURL:iconURL placeHolderImage:[UMComImageView placeHolderImageGender:user.gender.integerValue]];
    if (user.feed_count) {
        [self.feedNumber setText:[user.feed_count description]];
    }else{
        [self.feedNumber setText:@"0"];
    }
    if (user.following_count) {
        [self.followerNumber setText:[user.following_count description]];
    }else{
        [self.followerNumber setText:@"0"];
    }
    if (user.fans_count) {
        [self.fanNumber setText:[user.fans_count description]];
    }else{
        [self.fanNumber setText:@"0"];
    }
    BOOL isFollow = [user.has_followed boolValue];
    if (isFollow) {
        [self.focus setTitle:UMComLocalizedString(@"Has_Focused",@"取消关注") forState:UIControlStateNormal];
        [self.focus setTitleColor:[UMComTools colorWithHexString:FontColorBlue] forState:UIControlStateNormal];
        self.focus.backgroundColor = [UMComTools colorWithHexString:ViewGrayColor];
    }else{
        [self.focus setTitle:UMComLocalizedString(@"No_Focused",@"关注") forState:UIControlStateNormal];
        [self.focus setTitleColor:[UMComTools colorWithHexString:FontColorGray] forState:UIControlStateNormal];
        self.focus.backgroundColor = [UMComTools colorWithHexString:ViewGreenBgColor];
    }
    if ([self.user.uid isEqualToString:[UMComSession sharedInstance].uid] || [self.user.atype integerValue] == SuperAdmin) {
        self.focus.hidden = YES;
    }else{
        self.focus.hidden = NO;
    }
    CGSize textSize = CGSizeMake(self.userName.frame.size.width, self.userName.frame.size.height);
    if (user.name && user.name.length > 0) {
        textSize = [user.name sizeWithFont:UMComFontNotoSansLightWithSafeSize(14) constrainedToSize:CGSizeMake(self.view.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        [self.userName setText:user.name];
        self.userName.frame = CGRectMake(0, self.userName.frame.origin.y, textSize.width, self.userName.frame.size.height);
        self.userName.center = CGPointMake(self.view.frame.size.width/2, self.userName.center.y);
        self.genderView.hidden = NO;
    }
    self.genderView.center = CGPointMake(self.genderView.frame.size.width + textSize.width+self.userName.frame.origin.x, self.genderView.center.y);
    if ([user.gender integerValue] == 1) {
        [self.genderView setUserGender:UMComUserGenderMale];
    }else{
        [self.genderView setUserGender:UMComUserGenderFemale];
    }
}



#pragma mark - get user fans followers and feeds methods

- (void)setOtherWithType:(UMComUserCenterDataType)dataType
{
    _lastDataType = _curDataType;
    _curDataType = dataType;
    self.feedNumber.textColor = [UMComTools colorWithHexString:FontColorGray];
    [self.feedButton setTitleColor:[UMComTools colorWithHexString:FontColorGray] forState:UIControlStateNormal];
    
    self.followerNumber.textColor = [UMComTools colorWithHexString:FontColorGray];
    [self.followButton setTitleColor:[UMComTools colorWithHexString:FontColorGray] forState:UIControlStateNormal];
    
    self.fanNumber.textColor = [UMComTools colorWithHexString:FontColorGray];
    [self.fanButton setTitleColor:[UMComTools colorWithHexString:FontColorGray] forState:UIControlStateNormal];
    
    if(dataType==UMComUserCenterDataFeeds)
    {
        self.feedNumber.textColor = [UMComTools colorWithHexString:FontColorBlue];
        [self.feedButton setTitleColor:[UMComTools colorWithHexString:FontColorBlue] forState:UIControlStateNormal];
    }
    else if(dataType==UMComUserCenterDataFollows)
    {
        self.followerNumber.textColor = [UMComTools colorWithHexString:FontColorBlue];
        [self.followButton setTitleColor:[UMComTools colorWithHexString:FontColorBlue] forState:UIControlStateNormal];
    }
    else if(dataType==UMComUserCenterDataFans)
    {
        self.fanNumber.textColor = [UMComTools colorWithHexString:FontColorBlue];
        [self.fanButton setTitleColor:[UMComTools colorWithHexString:FontColorBlue] forState:UIControlStateNormal];
    }
    else
    {
        UMLog(@"error,dataType[%d]",dataType);
        return;
    }
}


-(IBAction)onClickFoucus:(id)sender
{
    self.focus.titleLabel.textAlignment = NSTextAlignmentCenter;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    __weak typeof(self) weakSelf = self;

    BOOL isFollow = ![self.user.has_followed boolValue];
    [UMComPushRequest followerWithUser:self.user isFollow:isFollow completion:^(NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSInteger index = 2;
        if (![self.user.uid isEqualToString:[UMComSession sharedInstance].uid]) {
            index = 2;
        }
        UMComUserCollectionViewController *collectionView = weakSelf.childViewControllers[index];
        if (error) {
            [UMComShowToast showFetchResultTipWithError:error];
        }else{
            UMComUser *loginUser = [UMComSession sharedInstance].loginUser;
            if ([self.user.has_followed boolValue]) {
                if (index == 2){
                    [collectionView inserUser:loginUser atIndex:0];
                }
            }else{
                if (index == 2){
                    [collectionView deleteUser:loginUser];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kUMComFollowUserSucceedNotification object:self.user userInfo:nil];
        }
        [self refreshBaseInformationWithUserProfile:weakSelf.user];
    }];
}


-(IBAction)onClickFeeds:(id)sender
{
    [self changeDataType:0];
    UMComFeedTableViewController *feedTableViewVc = (UMComFeedTableViewController *)self.childViewControllers[0];
    [self resetContentOffsetOfScrollView:feedTableViewVc.tableView];

}


-(IBAction)onClickFollowers:(id)sender
{
    
    [self changeDataType:1];
    UMComUserCollectionViewController *userCenterVc = self.childViewControllers[1];
    [self resetContentOffsetOfScrollView:userCenterVc.collectionView];

}


-(IBAction)onClickFans:(id)sender
{
    [self changeDataType:2];
    UMComUserCollectionViewController *userCenterVc = self.childViewControllers[2];
    [self resetContentOffsetOfScrollView:userCenterVc.collectionView];
}

#pragma mark - scrollView animations

- (void)resetContentOffsetOfScrollView:(UIScrollView *)scrollView
{
    if (!(scrollView.contentOffset.y >= -self.headerView.frame.origin.y && self.headerView.frame.size.height-self.menuView.frame.size.height == -self.headerView.frame.origin.y)) {
        [scrollView setContentOffset:CGPointMake(self.headerView.frame.origin.x, -self.headerView.frame.origin.y)];
    }
}

- (void)refreshScrollViewWithView:(UIScrollView *)scrollView
{
    CGFloat contenSizeH = self.view.frame.size.height + self.headerView.frame.size.height;
    if (contenSizeH < self.headerView.frame.size.height + scrollView.contentSize.height) {
        contenSizeH = self.headerView.frame.size.height + scrollView.contentSize.height;
    }
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, contenSizeH);
    [scrollView setContentOffset:CGPointMake(self.headerView.frame.origin.x, -self.headerView.frame.origin.y)];
}

- (void)scrollViewDidScrollWithScrollView:(UIScrollView *)scrollView lastPosition:(CGPoint)lastPosition
{
    CGRect headerFrame = self.headerView.frame;
    CGFloat height = headerFrame.size.height - self.menuView.frame.size.height;
    if (scrollView.contentOffset.y < height && scrollView.contentOffset.y >= 0) {
        headerFrame.origin.y = -scrollView.contentOffset.y;
    }else if (scrollView.contentOffset.y >= height && scrollView.contentOffset.y >= 0) {
        headerFrame.origin.y = -headerFrame.size.height+self.menuView.frame.size.height;
    }else if(scrollView.contentOffset.y == 0){
        headerFrame.origin.y = 0;
    }
    self.headerView.frame = headerFrame;
}
#pragma mark - UMComScrollViewDelegate
- (void)customScrollViewDidScroll:(UIScrollView *)scrollView lastPosition:(CGPoint)lastPosition
{
    [self scrollViewDidScrollWithScrollView:scrollView lastPosition:lastPosition];
}

- (void)customScrollViewDidEnd:(UIScrollView *)scrollView lastPosition:(CGPoint)lastPosition
{
    [self scrollViewDidScrollWithScrollView:scrollView lastPosition:lastPosition];
    if (scrollView.contentOffset.y == 0) {
        self.headerView.frame = CGRectMake(self.headerView.frame.origin.x, 0, self.headerView.frame.size.width, self.headerView.frame.size.height);
    }
}


@end
