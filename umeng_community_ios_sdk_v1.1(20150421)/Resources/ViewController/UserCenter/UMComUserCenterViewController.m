//
//  UMComUserCenterViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 9/10/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComUserCenterViewController.h"
#import "UMComFeedsTableViewCell.h"
#import "UMComUserCenterViewModel.h"
#import "UMComUserCenterTableDelegate.h"
#import "UMComFeedsTableView.h"
#import "UMComLabel.h"
//#import "UMComUserProfile.h"
#import "UMComGenderView.h"
#import "UMComTopicFeedViewController.h"
#import "UMComSession.h"
#import "UMComUsersTableCell.h"
#import "UMComUsersTableCellOne.h"
#import "UMComBarButtonItem.h"
#import "UMComProfileSettingController.h"
#import "UMComSettingViewController.h"
#import "UMComShowToast.h"

#import "UMComAction.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMUtils.h"
#import "UMComFetchedResultsController+UMCom.h"

@interface UMComUserCenterViewController ()

//其他
@property (nonatomic, strong) UMComUser *user;
@property (nonatomic, copy) NSString *uid;
//@property (nonatomic, strong) UMComUserProfile profile;
@property (nonatomic, strong) UMComUserCenterTableDelegate *tableDelegate;

@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic) UMComUserCenterDataType curDataType;

@property (nonatomic, strong) NSArray * followersArray;

@property (nonatomic, strong) NSArray * fansArray;

@property (nonatomic, strong) UIImageView *headerViewImage;
@property (nonatomic, strong) UIImageView *footerViewImage;

@end

static int HeaderOffSet = -65;
static float FLIP_ANIMATION_DURATION = 0.5;


@implementation UMComUserCenterViewController

- (id)initWithUid:(NSString *)uid
{
    self = [super initWithNibName:@"UMComUserCenterViewController" bundle:nil];
    if (self) {
        self.uid = uid;
        self.navigationItem.title = self.user.name;
        
        self.tableDelegate = [[UMComUserCenterTableDelegate alloc] initWithViewController:self];
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
        self.navigationItem.title = self.user.name;

        self.tableDelegate = [[UMComUserCenterTableDelegate alloc] initWithViewController:self];
        
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
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UserLogoutSucceed object:nil];
}

- (void)updateUserInfo
{
    //    //请求头像
    NSString *iconURL = ![[self.user.icon_url valueForKey:@"240"] isKindOfClass:[NSNull class]] ? [self.user.icon_url valueForKey:@"240"]:nil;
    
    [self.profileImageView setImageURL:[NSURL URLWithString:iconURL]];
    if ([self.user.gender intValue] == 0) {
        [self.profileImageView setPlaceholderImage:[UIImage imageNamed:@"female"]];
    } else{
        [self.profileImageView setPlaceholderImage:[UIImage imageNamed:@"male"]];
    }
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
    self.profileImageView.clipsToBounds = YES;
    [self.profileImageView startImageLoad];
    
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

- (void)viewDidLoad {

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self.feedsTableView action:@selector(dismissAllEditView)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    
    [self.feedsTableView setFeedTableViewController:self];

//    if ([self.user.uid isEqualToString:[UMComSession sharedInstance].uid] || [self.uid isEqualToString:[UMComSession sharedInstance].uid]) {
//        UMComBarButtonItem * settingButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"settingx" target:self action:@selector(onClickSetting)];
//        self.navigationItem.rightBarButtonItem = settingButtonItem;
//        self.focus.hidden = YES;
//    }
//    
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
    

//    //请求详细信息
    [self updateUserProfile];
    
    //请求已关注话题
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
    
    [self.topicsView setTopicTapHandle:^(UMComTopic *topic) {
        UMComTopicFeedViewController *topicFeedViewController = [[UMComTopicFeedViewController alloc] initWithTopic:topic];
//        [UIView setAnimationsEnabled:YES]; 
        [self.navigationController  pushViewController:topicFeedViewController animated:YES];
    }];
    
    self.tipLabel = [[UMComLabel alloc] initWithFont:UMComFontNotoSansDemiWithSafeSize(15)];
    self.tipLabel.frame = CGRectMake(0, 0, 300, 30);
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    //如果为空，删除线
    self.feedsTableView.tag = UMComUserCenterDataFeeds;
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
    
    self.followerTableView.tag = UMComUserCenterDataFollow;
    self.fansTableView.tag = UMComUserCenterDataFans;
    self.followerTableView.dataSource = self;
    self.followerTableView.delegate = self;
    [self.followerTableView registerClass:[UMComUsersTableCell class] forCellReuseIdentifier:@"UsersTableViewCell"];
//    self.tipLabel.center =  CGPointMake(self.followerTableView.frame.size.width/2, self.followerTableView.frame.size.height/2);
    
    self.fansTableView.dataSource = self;
    self.fansTableView.delegate = self;
    [self.fansTableView registerClass:[UMComUsersTableCell class] forCellReuseIdentifier:@"UsersTableViewCell"];
//    self.tipLabel.center =  CGPointMake(self.fansTableView.frame.size.width/2, self.fansTableView.frame.size.height/2);
    
    self.followersArray = [NSArray array];
    self.fansArray = [NSArray array];
    
    UIImageView *headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blueArrow"]];
    self.headerViewImage = headerImageView;
    self.headerViewImage.center = CGPointMake(self.view.frame.size.width/2, - 30);
    [self.fansTableView addSubview:self.headerViewImage];
    UIImageView *footerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"footerArrow"]];
    self.footerViewImage = footerImageView;
    self.footerViewImage.hidden = YES;
    [self setOtherWithType:UMComUserCenterDataFeeds];
}

- (void)onClickSetting
{
    [[UMComSettingAction action] performActionAfterLogin:nil viewController:self completion:nil];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    [(UMComUserCenterViewModel *)self.feedViewModel requestFollowUser:self.focus completion:^(NSError *error) {
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
                [self.user setValue:@1 forKey:@"is_follow"];
            } else {
                [self.user setValue:@0 forKey:@"is_follow"];
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
    [self.view bringSubviewToFront:self.followerTableView];
    [self.followerTableView addSubview:self.tipLabel];    
    [self setOtherWithType:UMComUserCenterDataFollow];
    [(UMComUserCenterViewModel *)self.feedViewModel loadDataWithType:UMComUserCenterDataFollow completion:^(NSArray *data,BOOL haveNextPage, NSError *error) {
        if ([data isKindOfClass:[NSArray class]]) {
            self.curDataType = UMComUserCenterDataFollow;
            self.followersArray = data;
            [self.followerTableView reloadData];
            if (data.count > 0) {
                self.tipLabel.hidden = YES;
                if ([self.user.following_count integerValue] <= 0) {
                    self.followerNumber.text = [NSString stringWithFormat:@"%ld",data.count];
                }
            } else {
                self.tipLabel.text = UMComLocalizedString(@"No_FocusPeople", @"内容为空");
                self.tipLabel.hidden = NO;
            }
        }
        self.tipLabel.center = CGPointMake(self.followerTableView.frame.size.width/2, self.followerTableView.frame.size.height/2);
    }];
}

-(IBAction)onClickFans:(id)sender
{
    [self.view bringSubviewToFront:self.fansTableView];
    [self.fansTableView addSubview:self.tipLabel];
    [self setOtherWithType:UMComUserCenterDataFans];
    [(UMComUserCenterViewModel *)self.feedViewModel loadDataWithType:UMComUserCenterDataFans completion:^(NSArray *data,BOOL haveNextPage, NSError *error) {
        self.curDataType = UMComUserCenterDataFans;
        self.fansArray = data;
        [self.fansTableView reloadData];
        if (data.count > 0) {
            self.tipLabel.hidden = YES;
            if ([self.user.fans_count integerValue] <= 0) {
                self.fanNumber.text = [NSString stringWithFormat:@"%ld",data.count];
            }
        } else {
            self.tipLabel.text = UMComLocalizedString(@"No_Followers", @"内容为空");
            self.tipLabel.hidden = NO;
        }
        self.tipLabel.center = CGPointMake(self.fansTableView.frame.size.width/2, self.fansTableView.frame.size.height/2);
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
        [self.focus setTitle:@"取消关注" forState:UIControlStateNormal];
        self.feedViewModel.isFocus = YES;
    }else{
        [self.focus setTitle:@"关注" forState:UIControlStateNormal];
        self.feedViewModel.isFocus = NO;
    }
    if (user.name && user.name.length > 0) {
        [self.userName setText:user.name];
    }
//    if ([self.uid isEqualToString:[UMComSession sharedInstance].uid]) {
//        [UMComSession sharedInstance].loginUser = user;
//    }
    if (self.user.managedObjectContext == user.managedObjectContext) {
//        self.user.user_profile = profile;
    }
    UMComGenderView *genderView = (UMComGenderView *)[self.view viewWithTag:10000];
    if ([user.gender integerValue] == 1) {
        [genderView setUserGender:UMComUserGenderMale];
    }else{
        [genderView setUserGender:UMComUserGenderFemale];

    }
//       [(UMComUserCenterViewModel *)self.feedViewModel setFocusButtonFromFollowers:self.focus];
}

#pragma mark UITableViewCell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (tableView.tag == UMComUserCenterDataFeeds) {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    } else if (tableView.tag == UMComUserCenterDataFollow) {
        static NSString * cellIdentifier = @"UsersTableViewCell";
        cell  = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        ((UMComUsersTableCell *)cell).viewController = self;
        NSRange range = [UMComUsersTableCell getGridTableRangeForIndex:indexPath.row allCount:[self.followersArray count]countOfOneLine:[UMComUsersTableCell countOfOneLine]];
        [(UMComUsersTableCell *)cell reloadWithDataArray:[self.followersArray subarrayWithRange:range]];
    } else if (tableView.tag == UMComUserCenterDataFans){
        static NSString * cellIdentifier = @"UsersTableViewCell";
        cell  = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        ((UMComUsersTableCell *)cell).viewController = self;
        NSRange range = [UMComUsersTableCell getGridTableRangeForIndex:indexPath.row allCount:[self.fansArray count]countOfOneLine:[UMComUsersTableCell countOfOneLine]];
        [(UMComUsersTableCell *)cell reloadWithDataArray:[self.fansArray subarrayWithRange:range]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UMComUsersTableCell staticHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowNum = 0;
    if (tableView.tag == UMComUserCenterDataFeeds) {
        rowNum = [super tableView:tableView numberOfRowsInSection:section];
    } else if (tableView.tag == UMComUserCenterDataFollow) {
        rowNum = [UMComUsersTableCell getGridTableLineNumber:self.followersArray.count countOfOneLine:[UMComUsersTableCell countOfOneLine]];
    } else if (tableView.tag == UMComUserCenterDataFans) {
        rowNum = [UMComUsersTableCell getGridTableLineNumber:self.fansArray.count countOfOneLine:[UMComUsersTableCell countOfOneLine]];
    }
    return rowNum;
}

//数据为空时，分割线为空
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    // This will create a "invisible" footer
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    [self.fansTableView addSubview:self.headerViewImage];
    float offset = scrollView.contentOffset.y;
    if (offset < HeaderOffSet) {
        [NSClassFromString(@"CATransaction") begin];
        [NSClassFromString(@"CATransaction") setAnimationDuration:FLIP_ANIMATION_DURATION];
        self.headerViewImage.transform = CGAffineTransformMakeRotation(M_PI);
        [NSClassFromString(@"CATransaction") commit];
    }
    else if (scrollView == (UIScrollView *)self.fansTableView){
        if(self.fansArray.count >= kFetchLimit && offset + self.fansTableView.superview.frame.size.height > self.fansTableView.contentSize.height){
            self.footerViewImage.hidden = NO;
            [NSClassFromString(@"CATransaction") begin];
            [NSClassFromString(@"CATransaction") setAnimationDuration:FLIP_ANIMATION_DURATION];
            self.footerViewImage.transform = CGAffineTransformMakeRotation(M_PI);
            [NSClassFromString(@"CATransaction") commit];
             
        }else if(self.followersArray.count >= kFetchLimit && offset + self.followerTableView.superview.frame.size.height > self.followerTableView.contentSize.height){
            self.footerViewImage.hidden = NO;
            [NSClassFromString(@"CATransaction") begin];
            [NSClassFromString(@"CATransaction") setAnimationDuration:FLIP_ANIMATION_DURATION];
            self.footerViewImage.transform = CGAffineTransformMakeRotation(M_PI);
            [NSClassFromString(@"CATransaction") commit];
        }
    }
    else{
        self.headerViewImage.transform = CGAffineTransformIdentity;
    }

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    float offset = scrollView.contentOffset.y;
    //下拉刷新
    if (offset < -65.0) {
        if ((UIScrollView *)self.fansTableView == scrollView) {
            [self onClickFans:nil];
  
        }else if(scrollView == (UIScrollView *)self.followerTableView){
            [self onClickFollowers:nil];
        }
    }
    //上拉加载更多
    else if (offset > 0 && scrollView.contentOffset.y > scrollView.contentSize.height - (scrollView.superview.frame.size.height - 65)) {
        if (YES) {
            if ((UIScrollView *)self.followerTableView == scrollView) {
                  [self setOtherWithType:UMComUserCenterDataFollow];
                [(UMComUserCenterViewModel *)self.feedViewModel loadMoreDataWithType:UMComUserCenterDataFollow completion:^(NSArray *data, BOOL haveChanged, NSError *error) {
                    if (data && [data isKindOfClass:[NSArray class]]) {
                        NSMutableArray *temArr = [NSMutableArray array];
                        [temArr addObjectsFromArray:self.followersArray];
                        [temArr addObjectsFromArray:data];
                        self.followersArray = temArr;
                        [self.followerTableView reloadData];
                    }
                }];

            }else if(scrollView == (UIScrollView *)self.fansTableView){
                [self setOtherWithType:UMComUserCenterDataFans];
                [(UMComUserCenterViewModel *)self.feedViewModel loadMoreDataWithType:UMComUserCenterDataFans completion:^(NSArray *data, BOOL haveChanged, NSError *error) {
                    if (data && [data isKindOfClass:[NSArray class]]) {
                        NSMutableArray *temArr = [NSMutableArray array];
                        [temArr addObjectsFromArray:self.fansArray];
                        [temArr addObjectsFromArray:data];
                        self.fansArray = temArr;
                        [self.fansTableView reloadData];
                    }
                }];
            }
        }
    }
}

- (void)popOutWhenUserlogout
{
//    [UIView setAnimationsEnabled:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UserLogoutSucceed object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
