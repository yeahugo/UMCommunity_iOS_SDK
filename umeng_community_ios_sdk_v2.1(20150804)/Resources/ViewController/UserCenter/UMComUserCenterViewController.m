//
//  UMComUserCenterViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 9/10/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComUserCenterViewController.h"
#import "UMComFeedsTableView.h"
#import "UMComGenderView.h"
#import "UMComTopicFeedViewController.h"
#import "UMComSession.h"
#import "UMComProfileSettingController.h"
#import "UMComShowToast.h"
#import "UMComAction.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMUtils.h"
#import "UMComUserCenterCollectionView.h"
#import "UIViewController+UMComAddition.h"
#import "UMComUser.h"
#import "UMComImageView.h"
#import "UMComTopicsTableViewController.h"
#import "UMComPhotoAlbumViewController.h"
#import "UMComActionStyleTableView.h"
#import "UMComPushRequest.h"
#import "UMComPullRequest.h"
#import "UMComUserResultController.h"
#import "UMComRefreshView.h"
#import "UMComClickActionDelegate.h"
#import "UMComScrollViewDelegate.h"

#define SuperAdmin 3 //超级管理员

typedef enum {
    FeedType = 0,
    CommentType = 1
} OperationType;

typedef enum {
    UMComUserCenterDataFeeds = 0,
    UMComUserCenterDataFollows = 1,
    UMComUserCenterDataFans = 2
}UMComUserCenterDataType;

@interface UMComUserCenterViewController ()<UMComClickActionDelegate, UMComScrollViewDelegate>


//其他
@property (nonatomic, strong) UMComUser *user;
@property (nonatomic, copy) NSString *uid;

@property (nonatomic) UMComUserCenterDataType curDataType;

@property (strong, nonatomic) UMComUserCenterCollectionView * followerTableView;
@property (strong, nonatomic) UMComUserCenterCollectionView * fansTableView;
@property (nonatomic, strong) UMComActionStyleTableView *actionTableView;
@property (nonatomic, strong) UIView *shadowBgView;
@property (nonatomic, strong) UMComUserProfileRequest *userProfileRequest;
@property (nonatomic, strong) UMComGenderView *genderView;
@end


@implementation UMComUserCenterViewController
{
    OperationType operationType;
}

- (id)initWithUid:(NSString *)uid
{
    self = [super initWithNibName:@"UMComUserCenterViewController" bundle:nil];
    if (self) {
        self.uid = uid;
    }
    return self;
}

-(id)initWithUser:(UMComUser *)user
{
    self = [super initWithNibName:@"UMComUserCenterViewController" bundle:nil];
    if (self) {
        self.user = user;
        self.uid = user.uid;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserProfile) name:UpdateUserProfileSuccess object:nil];
    if ([self.user.uid isEqualToString:[UMComSession sharedInstance].uid]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataFromServer:) name:kNotificationPostFeedResult object:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
};

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    if (UMSYSTEM_VERSION_GREATER_THAN(@"7")) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if (![[UMComSession sharedInstance].uid isEqualToString:self.uid]) {
        [self setRightButtonWithImageName:@"um_diandiandian" action:@selector(userSpam)];
           //当feed删除成功时通知主页面更新feed条数
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletedFeedSucceedAction) name:FeedDeletedFinish object:nil];
    }
    [self setTitleViewWithTitle:self.user.name];
    [self resetBaseInfoViews];
    //当用户注销时直接跳回主页面
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popOutWhenUserlogout) name:UserLogoutSucceed object:nil];
    
    if (!self.user) {
        UMComUserResultController *userResultController = [[UMComUserResultController alloc] initWithUid:self.uid];
        [userResultController fetchRequestFromCoreData:^(NSArray *data, NSError *error) {
            self.user = data.firstObject;
            [self refreshBaseInformationWithUserProfile:self.user];
        }];
    } else {
        [self refreshBaseInformationWithUserProfile:self.user];
    }

    //feed列表
    self.feedsTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self setOtherWithType:UMComUserCenterDataFeeds];
    self.feedsTableView.headView = [self createdHearderView];
    self.feedsTableView.footView = [self createdFootView];
    self.feedsTableView.scrollViewDelegate = self;
    self.fetchFeedsController = [[UMComUserFeedsRequest alloc] initWithUid:self.uid count:BatchSize type:UMComTimeLineTypeDefault];
 
    //实例化关注用户列表
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, self.headerView.frame.size.height);
    UMComUserCenterCollectionView *followersCollectionView = [[UMComUserCenterCollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:layout];
    followersCollectionView.user = self.user;
    followersCollectionView.hidden = YES;
    UMComFollowersRequest *followersController = [[UMComFollowersRequest alloc] initWithUid:self.user.uid count:BatchSize*2];
    followersCollectionView.fecthRequest = followersController;
    followersCollectionView.cellDelegate = self;
    followersCollectionView.scrollViewDelegate = self;
    followersCollectionView.headView = [self createdHearderView];
    followersCollectionView.footView = [self createdFootView];
    [self.view addSubview:followersCollectionView];
    self.followerTableView = followersCollectionView;
    
    //实例化粉丝列表
    UICollectionViewFlowLayout *fanLayout = [[UICollectionViewFlowLayout alloc]init];
    fanLayout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, self.headerView.frame.size.height);
    UMComUserCenterCollectionView *fansCollectionView = [[UMComUserCenterCollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:fanLayout];
    fansCollectionView.user = self.user;
    UMComFansRequest *fansController = [[UMComFansRequest alloc] initWithUid:self.user.uid count:BatchSize*2];
    fansCollectionView.hidden = YES;
    fansCollectionView.fecthRequest = fansController;
    fansCollectionView.cellDelegate = self;
    fansCollectionView.scrollViewDelegate = self;
    fansCollectionView.headView = [self createdHearderView];
    fansCollectionView.footView = [self createdFootView];
    [self.view addSubview:fansCollectionView];
    self.fansTableView = fansCollectionView;
    [self.view bringSubviewToFront:self.feedsTableView];
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.headerView];
}

- (UMComRefreshView *)createdHearderView
{
    UMComRefreshView *headerView = [[UMComRefreshView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.headerView.frame.size.height)];
    return headerView;
}

- (UMComRefreshView *)createdFootView
{
    UMComRefreshView *footView = [[UMComRefreshView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kUMComRefreshOffsetHeight)];
    footView.isPull = NO;
    return footView;
}

- (void)tableView:(UMComActionStyleTableView *)actionStyleView didSelectRowAtIndexPath:(NSIndexPath *)indexPath type:(OperationType)type
{
    operationType = type;
    if (indexPath.row == 1) {
        [UMComSpamUserRequest spamWithUserId:self.user.uid completion:nil];
    }
    [self hidenaActionTableView];
}

- (void)hidenaActionTableView
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.actionTableView.frame = CGRectMake(self.actionTableView.frame.origin.x, self.view.window.frame.size.height+64, self.actionTableView.frame.size.width, self.actionTableView.frame.size.height);
        [self.shadowBgView removeFromSuperview];
    } completion:^(BOOL finished) {
        [self.actionTableView removeFromSuperview];
    }];
}

- (void)showActionTableViewWithImageNameList:(NSArray *)imageNameList titles:(NSArray *)titles type:(OperationType)type
{
    if (!self.actionTableView) {
        self.actionTableView = [[UMComActionStyleTableView alloc]initWithFrame:CGRectMake(15, self.view.frame.size.height, self.view.frame.size.width-30, 90) style:UITableViewStylePlain];
    }
    __weak UMComUserCenterViewController *weakSelf = self;
    self.actionTableView.didSelectedAtIndexPath = ^(UMComActionStyleTableView *actionStyleView, NSIndexPath *indexPath){
        [weakSelf tableView:actionStyleView didSelectRowAtIndexPath:indexPath type:type];
    };
    [self.actionTableView setImageNameList:imageNameList titles:titles];
    if (!self.shadowBgView) {
        self.shadowBgView = [self createdShadowBgView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidenaActionTableView)];
        [self.shadowBgView addGestureRecognizer:tap];
    }
    [self.view.window addSubview:self.shadowBgView];
    [self.view.window addSubview:self.actionTableView];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.actionTableView.frame = CGRectMake(self.actionTableView.frame.origin.x, self.view.window.frame.size.height-self.actionTableView.frame.size.height, self.actionTableView.frame.size.width, self.actionTableView.frame.size.height);
    } completion:nil];
}

- (void)userSpam
{
    [self showActionTableViewWithImageNameList:[NSArray arrayWithObjects:@"um_spam", nil] titles:[NSArray arrayWithObjects:UMComLocalizedString(@"spam", @"举报"), nil] type:FeedType];
}

- (void)deletedFeedSucceedAction
{
    if ([self.user.uid  isEqualToString:[UMComSession sharedInstance].uid]) {
        UMComUser *loginUser = [UMComSession sharedInstance].loginUser;
        if ([UMComSession sharedInstance].loginUser) {
            int feed_count = [loginUser.feed_count intValue];
            if (feed_count > 0) {
                feed_count -- ;
            }
            loginUser.feed_count = [NSNumber numberWithInteger:feed_count];
            self.feedNumber.text = [loginUser.feed_count description];
        }
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
    topicsViewController.topicFecthRequest = [[UMComUserTopicsRequest alloc]initWithUid:self.user.uid count:FocusTopicNum];
    [self.navigationController pushViewController:topicsViewController animated:YES];
}

#pragma mark - 
- (void)refreshAllData
{
    [self updateUserProfile];
}

//请求详细信息
- (void)updateUserProfile
{
    NSString *uid = self.uid ? self.uid : self.user.uid;
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
            [weakSelf.feedsTableView refreshAllFeedsData:nil fromServer:nil];
        }];
    }];
}

- (void)refreshBaseInformationWithUserProfile:(UMComUser *)user
{
    self.user = user;
    //请求头像
    NSString *iconURL = ![[user.icon_url valueForKey:@"240"] isKindOfClass:[NSNull class]] ? [user.icon_url valueForKey:@"240"]:nil;
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
    UMComGenderView *genderView = (UMComGenderView *)[self.view viewWithTag:10000];
    CGSize textSize = CGSizeMake(self.userName.frame.size.width, self.userName.frame.size.height);
    if (user.name && user.name.length > 0) {
        textSize = [user.name sizeWithFont:UMComFontNotoSansLightWithSafeSize(14) constrainedToSize:CGSizeMake(self.view.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        [self.userName setText:user.name];
        self.userName.frame = CGRectMake(0, self.userName.frame.origin.y, textSize.width, self.userName.frame.size.height);
        self.userName.center = CGPointMake(self.view.frame.size.width/2, self.userName.center.y);
    }
    if (!genderView) {
        genderView = [[UMComGenderView alloc] initWithGender:UMComUserGenderFemale];
        genderView.frame = CGRectMake(genderView.frame.size.width + textSize.width+self.userName.frame.origin.x+6, self.userName.frame.origin.y + 4, 12, 12);
        [self.headerView addSubview:genderView];
        if ([self.user.gender integerValue] == 1) {
            [genderView setUserGender:UMComUserGenderMale];
        }
        genderView.tag = 10000;
    }
    genderView.center = CGPointMake(genderView.frame.size.width + textSize.width+self.userName.frame.origin.x, genderView.center.y);
    if ([user.gender integerValue] == 1) {
        [genderView setUserGender:UMComUserGenderMale];
    }else{
        [genderView setUserGender:UMComUserGenderFemale];
    }
}


- (void)popOutWhenUserlogout
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UserLogoutSucceed object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - get user fans followers and feeds methods

- (void)setOtherWithType:(UMComUserCenterDataType)dataType
{
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
    
    BOOL isDelete = [self.user.has_followed boolValue];
    if (isDelete) {
        [UMComFollowUserRequest postDisFollowerWithUserId:self.user.uid completion:^(NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if (error) {
                [UMComShowToast focusUserFail:error];
            }else{
                UMComUser *loginUser = [UMComSession sharedInstance].loginUser;
                weakSelf.user.fans_count = [NSNumber numberWithInteger:([weakSelf.user.fans_count intValue] - 1)];
                NSInteger followersCount = [loginUser.following_count integerValue] -1;
                loginUser.following_count = [NSNumber numberWithInteger:followersCount];
                [weakSelf.user setHas_followed:@0];
                [self refreshBaseInformationWithUserProfile:weakSelf.user];
            }
        }];
    }else{
        [UMComFollowUserRequest postFollowerWithUserId:self.user.uid completion:^(NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if (error) {
                [UMComShowToast focusUserFail:error];
                if (error.code == 10007) {
                    [weakSelf.user setHas_followed:@1];
                }else{
                    [weakSelf.user setHas_followed:@0];
                }
                [self refreshBaseInformationWithUserProfile:weakSelf.user];
            }else{
                UMComUser *loginUser = [UMComSession sharedInstance].loginUser;
                weakSelf.user.fans_count = [NSNumber numberWithInteger:([weakSelf.user.fans_count intValue] + 1)];
                NSInteger followersCount = [loginUser.following_count integerValue] +1;
                loginUser.following_count = [NSNumber numberWithInteger:followersCount];
                [weakSelf.user setHas_followed:@1];
                [self refreshBaseInformationWithUserProfile:weakSelf.user];
            }
        }];
    }
}

- (void)refreshScrollViewWithView:(UIScrollView *)scrollView
{
    CGFloat contenSizeH = self.view.frame.size.height + self.headerView.frame.size.height;
    if (contenSizeH < self.headerView.frame.size.height + scrollView.contentSize.height) {
        contenSizeH = self.headerView.frame.size.height + scrollView.contentSize.height;
    }
//    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, contenSizeH);
//    [scrollView setContentOffset:CGPointMake(self.headerView.frame.origin.x, -self.headerView.frame.origin.y)];
}

-(IBAction)onClickFeeds:(id)sender
{
    if (self.feedsTableView.hidden == NO) {
        return;
    }
    self.fansTableView.scrollViewDelegate = nil;
    self.followerTableView.scrollViewDelegate = nil;
    self.feedsTableView.scrollViewDelegate = self;
    self.curDataType = UMComUserCenterDataFeeds;
    self.fansTableView.hidden = YES;
    self.followerTableView.hidden = YES;
    self.feedsTableView.hidden = NO;
    [self resetContentOffsetOfScrollView:self.feedsTableView];
    [self setOtherWithType:UMComUserCenterDataFeeds];
    [self.view bringSubviewToFront:self.feedsTableView];
    [self.view bringSubviewToFront:self.headerView];
}


-(IBAction)onClickFollowers:(id)sender
{
    if (self.followerTableView.hidden == NO) {
        return;
    }
    self.fansTableView.scrollViewDelegate = nil;
    self.feedsTableView.scrollViewDelegate = nil;
    self.followerTableView.scrollViewDelegate = self;
    self.fansTableView.hidden = YES;
    self.followerTableView.hidden = NO;
    self.feedsTableView.hidden = YES;
    [self resetContentOffsetOfScrollView:self.followerTableView];
    if (self.followerTableView.userList.count == 0) {
        [self.followerTableView refreshUsersList];
    }
    [self setOtherWithType:UMComUserCenterDataFollows];
    [self.view bringSubviewToFront:self.followerTableView];
    [self.view bringSubviewToFront:self.headerView];
}

-(IBAction)onClickFans:(id)sender
{
    if (self.fansTableView.hidden == NO) {
        return;
    }
    self.feedsTableView.scrollViewDelegate = nil;
    self.followerTableView.scrollViewDelegate = nil;
    self.fansTableView.scrollViewDelegate = self;
    self.fansTableView.hidden = NO;
    self.followerTableView.hidden = YES;
    self.feedsTableView.hidden = YES;
    [self resetContentOffsetOfScrollView:self.fansTableView];
    if (self.fansTableView.userList.count == 0) {
        [self.fansTableView refreshUsersList];
    }
    [self setOtherWithType:UMComUserCenterDataFans];
    [self.view bringSubviewToFront:self.fansTableView];
    [self.view bringSubviewToFront:self.headerView];
}

- (void)resetContentOffsetOfScrollView:(UIScrollView *)scrollView
{
    if (!(scrollView.contentOffset.y >= -self.headerView.frame.origin.y && self.headerView.frame.size.height-self.menuView.frame.size.height == -self.headerView.frame.origin.y)) {
        [scrollView setContentOffset:CGPointMake(self.headerView.frame.origin.x, -self.headerView.frame.origin.y)];
    }
}


- (void)scrollViewDidScrollWithScrollView:(UIScrollView *)scrollView lastPosition:(CGPoint)lastPosition
{
    CGFloat height = self.headerView.frame.size.height - self.menuView.frame.size.height;
    if (scrollView.contentOffset.y < height && scrollView.contentOffset.y >= 0) {
        self.headerView.frame = CGRectMake(self.headerView.frame.origin.x,-scrollView.contentOffset.y, self.headerView.frame.size.width, self.headerView.frame.size.height);
    }else if (scrollView.contentOffset.y >= height && scrollView.contentOffset.y >= 0) {
        self.headerView.frame = CGRectMake(self.headerView.frame.origin.x, -self.headerView.frame.size.height+self.menuView.frame.size.height, self.headerView.frame.size.width, self.headerView.frame.size.height);
    }else if(scrollView.contentOffset.y == 0){
        self.headerView.frame =  CGRectMake(self.headerView.frame.origin.x,0, self.headerView.frame.size.width, self.headerView.frame.size.height);
    }
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


#pragma mark - UMComClickActionDelegate
- (void)customObj:(id)obj clickOnUser:(UMComUser *)user
{
    NSString *uid = @"";
    if (user.uid) {
        uid = user.uid;
    }
    if ([uid isEqualToString:self.user.uid]) {
        return;
    }
    [[UMComAction action] performActionAfterLogin:user viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            UMComUserCenterViewController *userCenterVc = [[UMComUserCenterViewController alloc]initWithUser:user];
            [self.navigationController pushViewController:userCenterVc animated:YES];
        }
    }];
}


@end
