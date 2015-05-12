//
//  UMComUserCenterViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 9/10/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComUserCenterViewController.h"
#import "UMComUserCenterViewModel.h"
#import "UMComFeedsTableView.h"
#import "UMComGenderView.h"
#import "UMComTopicFeedViewController.h"
#import "UMComSession.h"
#import "UMComProfileSettingController.h"
#import "UMComShowToast.h"
#import "UMComAction.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMUtils.h"
#import "UMComFetchedResultsController+UMCom.h"
#import "UMComUserCenterCollectionView.h"
#import "UIViewController+UMComAddition.h"

@interface UMComUserCenterViewController ()

//其他
@property (nonatomic, strong) UMComUser *user;
@property (nonatomic, copy) NSString *uid;

@property (nonatomic) UMComUserCenterDataType curDataType;

@property (strong, nonatomic) UMComUserCenterCollectionView * followerTableView;
@property (strong, nonatomic) UMComUserCenterCollectionView * fansTableView;

@end


@implementation UMComUserCenterViewController

- (id)initWithUid:(NSString *)uid
{
    self = [super initWithNibName:@"UMComUserCenterViewController" bundle:nil];
    if (self) {
        self.uid = uid;
        UMComUserCenterViewModel *ucViewModel = [[UMComUserCenterViewModel alloc] initWithUid:uid];
        self.feedViewModel = ucViewModel;
    }
    return self;
}

-(id)initWithUser:(UMComUser *)user
{
    self = [super initWithNibName:@"UMComUserCenterViewController" bundle:nil];
    if (self) {
        self.user = user;
        UMComUserCenterViewModel *ucViewModel = [[UMComUserCenterViewModel alloc] initWithUser:user];
        self.feedViewModel = ucViewModel;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserProfile) name:UpdateUserProfileSuccess object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.uid) {
        [UMComSession sharedInstance].currentUid = self.uid;
    } else {
        [UMComSession sharedInstance].currentUid = self.user.uid;
    }
    [super viewDidAppear:animated];
    [self refreshAllData];
};
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.feedsTableView dismissAllEditView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UpdateUserProfileSuccess object:nil];
}


- (void)viewDidLoad {

    [self setBackButtonWithTitle:UMComLocalizedString(@"Back", @"返回")];
    [self setTitleViewWithTitle:self.user.name];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self.feedsTableView action:@selector(dismissAllEditView)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    
    [self.feedsTableView setViewController:self];
   
    UMComUserFeedsRequest *userFeedsController = [[UMComUserFeedsRequest alloc] initWithUid:self.user.uid count:BatchSize];
    self.fetchFeedsController = userFeedsController;
    
    [super viewDidLoad];
    if (UMSYSTEM_VERSION_GREATER_THAN(@"7")) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
//当用户注销时直接跳回主页面
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popOutWhenUserlogout) name:UserLogoutSucceed object:nil];
    
    if (!self.user) {
        UMComUserResultController *userResultController = [[UMComUserResultController alloc] initWithUid:self.uid];
        [userResultController fetchRequestFromCoreData:^(NSArray *data, NSError *error) {
            self.user = data.firstObject;
            [self updateUserInfo];
        }];
    } else {
        [self updateUserInfo];
    }

    if ([self.user.uid isEqualToString:[UMComSession sharedInstance].uid]) {
        self.focus.hidden = YES;
    }
    
//    //请求详细信息
    [self updateUserProfile];
    
    //请求已关注话题
    [self requestUserTopics];
    
    [self.topicsView setTopicTapHandle:^(UMComTopic *topic) {
        UMComTopicFeedViewController *topicFeedViewController = [[UMComTopicFeedViewController alloc] initWithTopic:topic];
        [self.navigationController  pushViewController:topicFeedViewController animated:YES];
    }];
    
    //如果为空，删除线
    __weak UMComUserCenterViewController *weakSelf = self;
    self.feedsTableView.deletedFeedSucceedAction = ^(){
        if ([weakSelf.user.uid  isEqualToString:[UMComSession sharedInstance].uid]) {
            if ([UMComSession sharedInstance].loginUser) {
                int feed_count = [[UMComSession sharedInstance].loginUser.feed_count intValue];
                if (feed_count > 0) {
                    feed_count -- ;
                }
                [UMComSession sharedInstance].loginUser.feed_count = [NSNumber numberWithInteger:feed_count];
                weakSelf.feedNumber.text = [[UMComSession sharedInstance].loginUser.feed_count description];
            }
        }
    };
    [self setOtherWithType:UMComUserCenterDataFeeds];

}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - get user info data methods

- (void)updateUserInfo
{
    if (!self.profileImageView) {
        self.profileImageView = [[[UMComImageView imageViewClassName] alloc]initWithFrame:CGRectMake(21, 11, 60, 60)];
        [self.view addSubview:self.profileImageView];
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
        self.profileImageView.clipsToBounds = YES;
    }

    //    //请求头像
    NSString *iconURL = ![[self.user.icon_url valueForKey:@"240"] isKindOfClass:[NSNull class]] ? [self.user.icon_url valueForKey:@"240"]:nil;
    [self.profileImageView setImageURL:iconURL placeHolderImage:[UMComImageView placeHolderImageGender:self.user.gender.integerValue]];
    //用户名
    if([self.user.name length]){
        [self.userName setText:self.user.name];
    }else{
        [self.userName setText:UMComLocalizedString(@"No_Name", @"用户名为空")];
    }
    
    UMComGenderView *gender = [[UMComGenderView alloc] initWithGender:UMComUserGenderFemale];
    gender.frame = CGRectMake(self.userName.frame.origin.x+self.userName.frame.size.width, self.userName.frame.origin.y + 2, gender.frame.size.width, gender.frame.size.height);
    [self.view addSubview:gender];
    if ([self.user.gender integerValue] == 1) {
        [gender setUserGender:UMComUserGenderMale];
    }
    gender.tag = 10000;
}

- (void)requestUserTopics
{
    [(UMComUserCenterViewModel *)self.feedViewModel loadDataWithType:UMComUserCenterDataTopics completion:^(NSArray *data,BOOL haveNextPage, NSError *error) {
        //处理数据
        if(!data&&error){
            
        }else if([data count]){
            //防止view显示重叠
            for (UIView *view in self.topicsView.subviews) {
                [view removeFromSuperview];
            }
            [self.topicsView setTopicsData:data];
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if ([self.user.uid isEqualToString:[UMComSession sharedInstance].uid]) {
                    for (UMComTopic *topic in data) {
                        BOOL isInclude = NO;
                        for (UMComTopic *topicItem in [UMComSession sharedInstance].focus_topics) {
                            if ([topic.name  isEqualToString:topicItem.name]) {
                                isInclude = YES;
                                break;
                            }
                        }
                        if (isInclude == NO) {
                            [[UMComSession sharedInstance].focus_topics addObject:topic];
                        }
                    }
                    
                }
            });
        }else if([data count]==0){
            //防止在没有话题的时候缓存的话题View没有移除
            for (UIView *view in self.topicsView.subviews) {
                [view removeFromSuperview];
            }
            [self.topicsView setTipText:UMComLocalizedString(@"No_Subscribers", @"该用户还没有关注话题")];
        }
    }];
}

//请求详细信息
- (void)updateUserProfile
{
    NSString *uid = self.uid ? self.uid : self.user.uid;
    if(!uid){
        uid = [UMComSession sharedInstance].uid;
    }
    UMComUserProfileRequest *userProfile = [[UMComUserProfileRequest alloc] initWithUid:uid];
    [userProfile fetchRequestFromCoreData:^(NSArray *data, NSError *error) {
        UMComUser *userProfile = data.firstObject;
        if (userProfile) {
            [self refreshBaseInformationWithUserProfile:userProfile];
        }
    }];
    [(UMComUserCenterViewModel *)self.feedViewModel loadProfile:^(NSArray *data, NSError *error) {
        //处理数据
        @try {
            if (data.count > 0) {
                UMComUser *profile = data.firstObject;
                if (profile) {
                    [self refreshBaseInformationWithUserProfile:profile];
                }
            }else{
                [UMComShowToast fetchFailWithNoticeMessage:  UMComLocalizedString(@"user info load fail",@"个人信息加载失败")];
            }
        }
        @catch (NSException *exception) {
            UMLog(@"load profile error!");
        }
    }];
}

- (void)refreshBaseInformationWithUserProfile:(UMComUser *)user
{
    
    [self.feedNumber setText:[user.feed_count description]];
    [self.followerNumber setText:[user.following_count description]];
    [self.fanNumber setText:[user.fans_count description]];
    BOOL isFollow = [user.is_follow boolValue];
    if (isFollow) {
        [self.focus setTitle:UMComLocalizedString(@"Has_Focused",@"取消关注") forState:UIControlStateNormal];
        self.feedViewModel.isFocus = YES;
    }else{
        [self.focus setTitle:UMComLocalizedString(@"No_Focused",@"关注") forState:UIControlStateNormal];
        self.feedViewModel.isFocus = NO;
    }
    if (user.name && user.name.length > 0) {
        [self.userName setText:user.name];
    }
    UMComGenderView *genderView = (UMComGenderView *)[self.view viewWithTag:10000];
    if ([user.gender integerValue] == 1) {
        [genderView setUserGender:UMComUserGenderMale];
    }else{
        [genderView setUserGender:UMComUserGenderFemale];
        
    }
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
    else if(dataType==UMComUserCenterDataFollow)
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

- (void)reloadFeedsData
{
    [self setOtherWithType:UMComUserCenterDataFeeds];
    [self.view bringSubviewToFront:self.feedsTableView];
}

-(IBAction)onClickFoucus:(id)sender
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [(UMComUserCenterViewModel *)self.feedViewModel requestFollowUser:self.focus completion:^(NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (error) {
            [UMComShowToast focusUserFail:error];
        }else{
            if (self.feedViewModel.isFocus) {
                self.user.fans_count = [NSNumber numberWithInteger:([self.user.fans_count intValue] + 1)];
                NSInteger followersCount = [[UMComSession sharedInstance].loginUser.following_count integerValue] +1;
                [UMComSession sharedInstance].loginUser.following_count = [NSNumber numberWithInteger:followersCount];
            } else {
                self.user.fans_count = [NSNumber numberWithInteger:([self.user.fans_count intValue] - 1)];
                NSInteger followersCount = [[UMComSession sharedInstance].loginUser.following_count integerValue] -1;
                [UMComSession sharedInstance].loginUser.following_count = [NSNumber numberWithInteger:followersCount];
            }
            if (self.feedViewModel.isFocus) {
                [self.user setHaveFollow];
            } else {
                [self.user setDisFollow];
            }
           
            [self setFocus:self.focus];
            [self.fanNumber setText:[self.user.fans_count description]];
        }
        
    }];
}

-(IBAction)onClickFeeds:(id)sender
{
    self.curDataType = UMComUserCenterDataFeeds;
    [self reloadFeedsData];
}

-(IBAction)onClickFollowers:(id)sender
{
    if (!self.followerTableView) {
        UMComUserCenterCollectionView *followersCollectionView = [[UMComUserCenterCollectionView alloc]initWithFrame:self.feedsTableView.frame collectionViewLayout:nil];
        followersCollectionView.user = self.user;
        UMComFollowersRequest *followersController = [[UMComFollowersRequest alloc] initWithUid:self.user.uid count:BatchSize*2];
        followersCollectionView.fecthRequest = followersController;
        followersCollectionView.viewController = self;
        [self.view addSubview:followersCollectionView];
        self.followerTableView = followersCollectionView;
    }
    if (self.followerTableView.userList.count == 0) {
        [self.followerTableView refreshUsersList];
    }
    [self.view bringSubviewToFront:self.followerTableView];
    [self setOtherWithType:UMComUserCenterDataFollow];
}

-(IBAction)onClickFans:(id)sender
{
    if (!self.fansTableView) {
        UMComUserCenterCollectionView *fansCollectionView = [[UMComUserCenterCollectionView alloc]initWithFrame:self.feedsTableView.frame collectionViewLayout:nil];
        fansCollectionView.user = self.user;
        UMComFansRequest *fansController = [[UMComFansRequest alloc] initWithUid:self.user.uid count:BatchSize*2];
        fansCollectionView.fecthRequest = fansController;
        fansCollectionView.viewController = self;
        [self.view addSubview:fansCollectionView];
        self.fansTableView = fansCollectionView;
    }
    if (self.fansTableView.userList.count == 0) {
        [self.fansTableView refreshUsersList];
    }
    [self.view bringSubviewToFront:self.fansTableView];
    [self setOtherWithType:UMComUserCenterDataFans];
}


- (void)popOutWhenUserlogout
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UserLogoutSucceed object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
