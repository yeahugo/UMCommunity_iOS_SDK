//
//  UMComForumUserCenterViewController.m
//  UMCommunity
//
//  Created by umeng on 15/11/27.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumUserCenterViewController.h"
#import "UMComTools.h"
#import "UMComUser.h"
#import "UMComPullRequest.h"
#import "UMComImageView.h"
#import "UMComGenderView.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComSession.h"
#import "UMComShowToast.h"
#import "UMComHorizonCollectionView.h"
#import "UMComFeed.h"
#import "UMComForumTopicTableViewController.h"
#import "UMComPhotoAlbumViewController.h"
#import "UMComAction.h"
#import "UMComPushRequest.h"
#import "UMComForumUserTableViewCell.h"
#import "UMComPostTableViewController.h"
#import "UMComForumUserTableViewController.h"
#import "UMComForumPrivateChatTableViewController.h"
#import "UIViewController+UMComAddition.h"
#import "UMComBarButtonItem.h"
#import "UMComActionStyleTableView.h"
#import "UMComMedal.h"

//detailView
#define UMCom_Forum_UserCenter_ButtonHeight 30
#define UMCom_Forum_UserCenter_ButtonWidth 70
#define UMCom_Forum_UserCenter_ButtonSpace 38
#define UMCom_Forum_UserCenter_AvatarWidth 75
#define UMCom_Forum_UserCenter_AvatarTopEdge 25
#define UMCom_Forum_UserCenter_AvatarNameSpace 8
#define UMCom_Forum_UserCenter_NameButtonSpace 0
#define UMCom_Forum_UserCenter_ProfileButtonFont 13
#define UMCom_Forum_UserCenter_NameFont 14
#define UMCom_Forum_UserCenter_ButtonTitleColor  @"#9CD0F3"
#define UMCom_Forum_UserCenter_DetailViewBgColor  @"#FAFBFD"


//menuview
#define UMCom_Forum_UserCenter_DetailMenuSpace 15

#define UMCom_Forum_UserCenter_MenuTitleFont 16
#define UMCom_Forum_UserCenter_MenuCountFont 12
#define UMCom_Forum_UserCenter_MenuViewHeight 48
#define UMCom_Forum_UserCenter_MenuEdgeLineConlor  @"#EEEFF3"
#define UMCom_Forum_UserCenter_MenuBgColor  @"#9CD0F3"
#define UMCom_Forum_UserCenter_MenuTitleColor  @"#A5A5A5"
#define UMCom_Forum_UserCenter_MenuTitleHighLightColor  @"#008BEA"



@interface UMComForumUserCenterViewController ()<UMComHorizonCollectionViewDelegate, UMComUserProfileDetaiViewDelegate>

@property (nonatomic, strong) UMComUser *user;

@property (nonatomic, strong) UMComUserProfileDetailView *detailView;

@property (nonatomic, strong) UMComHorizonCollectionView *menuView;

@property (nonatomic, strong) UMComUserProfileRequest *userProfileRequest;

@property (nonatomic, strong) UIViewController *lastViewController;

@property (nonatomic, strong) UMComActionStyleTableView *actionTableView;

@property (nonatomic, strong) NSArray *countLabelList;

@end

@implementation UMComForumUserCenterViewController


- (instancetype)initWithUser:(UMComUser *)user
{
    self = [super init];
    if (self) {
        self.user = user;
        self.userProfileRequest = [[UMComUserProfileRequest alloc]initWithUid:self.user.uid sourceUid:nil];
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setForumUITitle:self.user.name];
    
    //设置返回按钮
    [self setForumUIBackButton];
    
    //设置私信和更多按钮
    [self creatNavigationItemList];
    
    //创建详情按钮
    [self creatDetailView];
    
    //获取个人信息
    [self getCurrentUserRequest];
    
    //创建子ViewController
    [self creatChildViewControllers];
    
}


//点击私信管理
- (void)clickOnPrivateLetter
{
    UMComForumPrivateChatTableViewController *chatTableViewController = [[UMComForumPrivateChatTableViewController alloc]initWithUser:self.user];
    [self.navigationController pushViewController:chatTableViewController animated:YES];
}


- (void)showActionTableViewWithImageNameList:(NSArray *)imageNameList titles:(NSArray *)titles
{
    if (!self.actionTableView) {
        self.actionTableView = [[UMComActionStyleTableView alloc]initWithFrame:CGRectMake(15, self.view.frame.size.height, self.view.frame.size.width-30, 90) style:UITableViewStylePlain];
    }
    __weak typeof(self) weakSelf = self;
    self.actionTableView.didSelectedAtIndexPath = ^(NSString *title, NSIndexPath *indexPath){
        [UMComPushRequest spamWithUser:weakSelf.user completion:^(NSError *error) {
            [UMComShowToast spamUser:error];
        }];
    };
    [self.actionTableView setImageNameList:imageNameList titles:titles];
    [self.actionTableView showActionSheet];
}

- (void)showMoreOperationMenuView
{
    [self showActionTableViewWithImageNameList:[NSArray arrayWithObjects:@"um_spam", nil] titles:[NSArray arrayWithObjects:UMComLocalizedString(@"spam", @"举报"), nil]];
}

#pragma mark - created subviews method
- (void)creatNavigationItemList
{
    if (![self.user.uid isEqualToString:[UMComSession sharedInstance].uid]) {
        UMComBarButtonItem *privateLetterItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"um_forum_user_privateletter" target:self action:@selector(clickOnPrivateLetter)];
        privateLetterItem.customButtonView.frame = CGRectMake(0, 0, 20, 20);
        privateLetterItem.customButtonView.titleLabel.font = UMComFontNotoSansLightWithSafeSize(17);
        UMComBarButtonItem *rightButtonItem = nil;
        if ([self.user.uid isEqualToString:[UMComSession sharedInstance].uid]|| [self.user.atype intValue] == 3) {
            rightButtonItem = [[UMComBarButtonItem alloc] init];
            rightButtonItem.customButtonView.frame = CGRectMake(0, 12, 10, 4);
        }else{
            rightButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"um_forum_more_gray" target:self action:@selector(showMoreOperationMenuView)];
            rightButtonItem.customButtonView.frame = CGRectMake(0, 12, 20, 4);
        }
        rightButtonItem.customButtonView.titleLabel.font = UMComFontNotoSansLightWithSafeSize(17);
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]init];
        UIView *spaceView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 20)];
        spaceView.backgroundColor = [UIColor clearColor];
        [spaceItem setCustomView:spaceView];
        UMComBarButtonItem *rightSpaceItem = [[UMComBarButtonItem alloc] init];
        rightSpaceItem.customButtonView.frame = CGRectMake(0, 12, 20, 4);
        rightSpaceItem.customButtonView.titleLabel.font = UMComFontNotoSansLightWithSafeSize(17);
        [self.navigationItem setRightBarButtonItems:@[rightButtonItem,spaceItem,privateLetterItem]];
    }

}
//创建个人信息详情页
- (void)creatDetailView
{
    self.detailView = [[UMComUserProfileDetailView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 220) user:self.user];
    self.detailView.deleagte = self;
    self.detailView.backgroundColor = UMComColorWithColorValueString(UMCom_Forum_UserCenter_DetailViewBgColor);
    [self.view addSubview:self.detailView];
    
    self.countLabelList = [self createLabelList];

    UMComHorizonCollectionView *collectionView = [[UMComHorizonCollectionView alloc]initWithFrame:CGRectMake(0, self.detailView.frame.size.height-UMCom_Forum_UserCenter_MenuViewHeight, self.view.frame.size.width, UMCom_Forum_UserCenter_MenuViewHeight) itemCount:3];
    collectionView.cellDelegate = self;
    collectionView.itemSpace = 0;
    collectionView.layer.borderWidth = 0.3;
    collectionView.layer.borderColor = UMComColorWithColorValueString(UMCom_Forum_UserCenter_MenuEdgeLineConlor).CGColor;
    [self.detailView addSubview:collectionView];
    self.menuView = collectionView;
    
}

//创建子ViewControllers
- (void)creatChildViewControllers
{
    CGRect frame = self.view.frame;
    frame.origin.y = self.detailView.frame.size.height;
    frame.size.height = self.view.frame.size.height - frame.origin.y;
    UMComPostTableViewController *postTableViewController = [[UMComPostTableViewController alloc]initWithFetchRequest:[[UMComUserFeedsRequest alloc] initWithUid:self.user.uid count:BatchSize type:UMComTimeLineTypeDefault]];
    postTableViewController.view.frame = frame;
    [self addChildViewController:postTableViewController];
    
    __weak typeof(self) weakSelf = self;
    UMComForumUserTableViewController *followersTableViewController = [[UMComForumUserTableViewController alloc] initWithFetchRequest:[[UMComFollowersRequest alloc] initWithUid:self.user.uid count:BatchSize]];
    followersTableViewController.focusedUserFinish = ^(){
        [weakSelf.menuView reloadData];
    };
    followersTableViewController.view.frame = frame;
    [self addChildViewController:followersTableViewController];
    
    UMComForumUserTableViewController *fanTableViewController = [[UMComForumUserTableViewController alloc]initWithFetchRequest:[[UMComFansRequest alloc] initWithUid:self.user.uid count:BatchSize]];
    fanTableViewController.view.frame = frame;
    [self.view addSubview:fanTableViewController.view];
    [self addChildViewController:fanTableViewController];
    self.lastViewController = fanTableViewController;
    fanTableViewController.focusedUserFinish = ^(){
        [weakSelf.menuView reloadData];
    };
    
    [self getDataArrayWithPageIndex:0];
}

//视图切换
- (void)transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
    if (fromViewController == toViewController) {
        toViewController.view.center = CGPointMake(self.view.frame.size.width/2, toViewController.view.center.y);
        [self.view bringSubviewToFront:self.detailView];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self transitionFromViewController:fromViewController toViewController:toViewController duration:0.25 options:UIViewAnimationOptionCurveEaseIn animations:^{
        toViewController.view.center = CGPointMake(weakSelf.view.frame.size.width/2, toViewController.view.center.y);
        CGPoint fromViewCenter = fromViewController.view.center;
        if (weakSelf.menuView.currentIndex > weakSelf.menuView.previewsIndex) {
            fromViewCenter.x = -weakSelf.view.frame.size.width*3/2;
        }else if(weakSelf.menuView.currentIndex < weakSelf.menuView.previewsIndex){
            fromViewCenter.x = weakSelf.view.frame.size.width*3/2;
        }else{
            toViewController.view.center = fromViewController.view.center;
        }
        [weakSelf.view bringSubviewToFront:weakSelf.detailView];
    } completion:^(BOOL finished) {
        weakSelf.lastViewController = toViewController;
    }];
}


#pragma mark - UserDetailViewDelgate

//点击关注按钮
- (void)userProfileDetailView:(UMComUserProfileDetailView *)userProfileDetailView clickOnfocuse:(UIButton *)focuseButton
{
    __weak typeof(self) weakSelf = self;
    [UMComPushRequest followerWithUser:weakSelf.user isFollow:![weakSelf.user.has_followed boolValue] completion:^(NSError *error) {
         UMComForumUserTableViewController *userTableViewController = nil;
        if ([weakSelf.user.uid isEqualToString:[UMComSession sharedInstance].uid]) {
             userTableViewController = self.childViewControllers[1];
        }else{
             userTableViewController = self.childViewControllers[2];
        }
        UMComUser *user = [UMComSession sharedInstance].loginUser;
        if (error) {
            if (error.code == ERR_CODE_USER_HAVE_FOLLOWED) {
                [userTableViewController insertUserToTableView:user];
            }
            [UMComShowToast showFetchResultTipWithError:error];
        }else{
            if ([weakSelf.user.has_followed boolValue]) {
                [userTableViewController insertUserToTableView:user];
            }else{
                [userTableViewController deleteUserFromTableView:user];
            }
        }
        [weakSelf.detailView reloadSubViewsWithUser:weakSelf.user];
        [weakSelf.menuView reloadData];
    }];
}



//点击相册按钮
- (void)userProfileDetailView:(UMComUserProfileDetailView *)userProfileDetailView clickOnAlbum:(UIButton *)albumButton
{
    UMComPhotoAlbumViewController *photoAlbumVc = [[UMComPhotoAlbumViewController alloc]init];
    photoAlbumVc.user = self.user;
    [self.navigationController pushViewController:photoAlbumVc animated:YES];
}

//点击关注的话题的按钮
- (void)userProfileDetailView:(UMComUserProfileDetailView *)userProfileDetailView clickOnFollowTopic:(UIButton *)topicButton
{
    UMComForumTopicTableViewController *topicViewController = [[UMComForumTopicTableViewController alloc]init];
    topicViewController.isAutoStartLoadData = YES;
    topicViewController.fetchRequest = [[UMComUserTopicsRequest alloc]initWithUid:self.user.uid count:BatchSize];
    [self.navigationController pushViewController:topicViewController animated:YES];
}


#pragma mark - UMComHorizonCollectionViewDelegate
- (void)horizonCollectionView:(UMComHorizonCollectionView *)collectionView
                   reloadCell:(UMComHorizonCollectionCell *)cell
                  atIndexPath:(NSIndexPath *)indexPath
{
    UILabel *countLabel = self.countLabelList[indexPath.row];
    CGRect countLabelFrame = countLabel.frame;
    countLabelFrame.origin.x = cell.label.frame.origin.x;
    countLabelFrame.origin.y = 2;
    countLabel.frame = countLabelFrame;
    if (countLabel.superview != cell.contentView) {
        [cell.contentView addSubview:countLabel];
    }
    
    CGRect titleLabelFrame = cell.label.frame;
    titleLabelFrame.origin.y = countLabel.frame.origin.y + countLabel.frame.size.height;
    titleLabelFrame.size.height = cell.frame.size.height - titleLabelFrame.origin.y-4;
    cell.label.frame = titleLabelFrame;
    if (indexPath.row == 0) {
        countLabel.text = [NSString stringWithFormat:@"%@",self.user.feed_count];
        cell.label.text = [NSString stringWithFormat:@"%@",UMComLocalizedString(@"User_Feed", @"消息")];
//        cell.label.text = [NSString stringWithFormat:@"%@\n%@",self.user.feed_count,UMComLocalizedString(@"User_Feed", @"消息")];
    }else if (indexPath.row == 1){
        countLabel.text = [NSString stringWithFormat:@"%@",self.user.following_count];
        cell.label.text = [NSString stringWithFormat:@"%@",UMComLocalizedString(@"User_Followers", @"关注")];
//        cell.label.text = [NSString stringWithFormat:@"%@\n%@",self.user.following_count,UMComLocalizedString(@"User_Followers", @"关注")];
    }else if (indexPath.row == 2){
        countLabel.text = [NSString stringWithFormat:@"%@",self.user.fans_count];
        cell.label.text = [NSString stringWithFormat:@"%@",UMComLocalizedString(@"User_Fans", @"粉丝")];
    }
    if (indexPath.row == collectionView.currentIndex) {
        cell.label.textColor = UMComColorWithColorValueString(UMCom_Forum_UserCenter_MenuTitleHighLightColor);
    }else{
        cell.label.textColor = UMComColorWithColorValueString(UMCom_Forum_UserCenter_MenuTitleColor);
    }
    countLabel.textColor = cell.label.textColor;
    cell.label.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_UserCenter_MenuTitleFont);
    cell.label.backgroundColor = [UIColor whiteColor];
    cell.label.textAlignment = NSTextAlignmentCenter;
}

- (NSMutableArray *)createLabelList
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
    CGFloat labelWidth = self.view.frame.size.width/3;
    CGFloat labelHeight = 20;
    for (int index =0; index < 3; index++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, labelHeight)];
        label.backgroundColor = [UIColor whiteColor];
        label.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_UserCenter_MenuCountFont);
        label.textColor = UMComColorWithColorValueString(UMCom_Forum_UserCenter_MenuTitleColor);
        label.textAlignment = NSTextAlignmentCenter;
        [array addObject:label];
    }
    return array;
}

- (void)horizonCollectionView:(UMComHorizonCollectionView *)collectionView didSelectedColumn:(NSInteger)column row:(NSInteger)row
{
    [self getDataArrayWithPageIndex:column];
    [collectionView reloadData];
}

- (void)getDataArrayWithPageIndex:(NSInteger)index
{
    UMComRequestTableViewController *requestTableViewController = self.childViewControllers[self.menuView.currentIndex];
    if (requestTableViewController.isLoadFinish && requestTableViewController.dataArray.count == 0) {
        [requestTableViewController loadAllData:^(NSArray *data, NSError *error) {
            
        } fromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            
        }];
    }
    [self transitionFromViewController:self.lastViewController toViewController:requestTableViewController];
}


#pragma mark - getData

- (void)getCurrentUserRequest
{
    __weak typeof(self) weakSelf = self;
    [self.userProfileRequest fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        if ([data isKindOfClass:[NSArray class]] && data.count > 0) {
            UMComUser *user = data.firstObject;
            weakSelf.user = user;
            [weakSelf.detailView reloadSubViewsWithUser:user];
            [weakSelf.menuView reloadData];
        }else if(error){
            [UMComShowToast showFetchResultTipWithError:error];
        }
    }];
}


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


#pragma mark - DetailView Class

@interface UMComUserProfileDetailView ()

@property (nonatomic, strong) UIButton *focuseButton;

@property (nonatomic, strong) UIButton *scoreButton;

@property (nonatomic, strong) UIImageView *genderView;

@property (nonatomic, strong) UMComImageView *medal_icon;


@end

@implementation UMComUserProfileDetailView

- (instancetype)initWithFrame:(CGRect)frame user:(UMComUser *)user
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat avatarWidth = UMCom_Forum_UserCenter_AvatarWidth;
        CGFloat image_top_edge = UMCom_Forum_UserCenter_AvatarTopEdge;
        UMComImageView *avatar = [[[UMComImageView imageViewClassName] alloc]initWithFrame:CGRectMake(frame.size.width/2-avatarWidth/2, image_top_edge, avatarWidth, avatarWidth)];
        [self addSubview:avatar];
        avatar.clipsToBounds = YES;
        avatar.userInteractionEnabled = YES;
        avatar.layer.cornerRadius = avatarWidth/2;
        self.avatarImageView = avatar;
        
        self.medal_icon = [[[UMComImageView imageViewClassName] alloc] init];
        CGFloat medel_icon_width = 16;
        self.medal_icon.backgroundColor = [UIColor redColor];
        CGRect imageFrame = CGRectMake(0, 0, medel_icon_width, medel_icon_width);
        imageFrame.origin.x = avatarWidth - medel_icon_width-2 + avatar.frame.origin.x;
        imageFrame.origin.y = avatarWidth - medel_icon_width-2 + avatar.frame.origin.y;
        self.medal_icon.frame = imageFrame;
        [self addSubview:_medal_icon];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnAvatar:)];
        [self.avatarImageView addGestureRecognizer:tap];
        
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.avatarImageView.frame.size.height + self.avatarImageView.frame.origin.y + UMCom_Forum_UserCenter_AvatarNameSpace, 80, 30)];
        self.nameLabel.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_UserCenter_NameFont);
        self.nameLabel.center = CGPointMake(self.frame.size.width/2, self.nameLabel.center.y);
        [self addSubview:self.nameLabel];
        
        self.genderView = [[UIImageView alloc]initWithFrame:CGRectMake(self.nameLabel.frame.origin.x + self.nameLabel.frame.size.width + 10, self.nameLabel.frame.origin.y, 20, 20)];
        [self addSubview:self.genderView];
        
        CGFloat buttonWidth = UMCom_Forum_UserCenter_ButtonWidth;
        CGRect buttonFrame;
        CGFloat buttonSpace = UMCom_Forum_UserCenter_ButtonSpace;
        buttonFrame.origin.x = self.frame.size.width/2 - buttonWidth - buttonSpace - buttonWidth/2;
        buttonFrame.origin.y = self.nameLabel.frame.size.height + self.nameLabel.frame.origin.y + UMCom_Forum_UserCenter_NameButtonSpace;
        buttonFrame.size.width = buttonWidth;
        buttonFrame.size.height = UMCom_Forum_UserCenter_ButtonHeight;
        UIButton *album =  [self createNewButtonWithImageName:@"um_forum_user_album" title:UMComLocalizedString(@"um_forum_user_album", @"相册") action:@selector(clickOnAlbumButton:) frame:buttonFrame];
        [self addSubview:album];
        
        buttonFrame.origin.x = buttonFrame.origin.x + buttonWidth + buttonSpace;
       UIButton *topic = [self createNewButtonWithImageName:@"um_forum_user_topic" title:UMComLocalizedString(@"um_forum_user_topic", @"话题") action:@selector(clickOnTopicButton:) frame:buttonFrame];
        [self addSubview:topic];
        
        buttonFrame.origin.x = buttonFrame.origin.x + buttonWidth + buttonSpace;
        buttonFrame.size.width = buttonFrame.size.width;
        
        NSString *pointStr = [NSString stringWithFormat:@"%ld",[user.point integerValue]];
        CGSize textSize = [pointStr sizeWithFont:UMComFontNotoSansLightWithSafeSize(UMCom_Forum_UserCenter_ProfileButtonFont) forWidth:100 lineBreakMode:NSLineBreakByTruncatingTail];
        buttonFrame.size.width = UMCom_Forum_UserCenter_ButtonWidth + textSize.width;
        UIButton *point = [self createNewButtonWithImageName:@"um_forum_user_score" title:[NSString stringWithFormat:@"积分%@",pointStr] action:@selector(clickOnScoreButton:) frame:buttonFrame];
        [self addSubview:point];
        point.enabled = NO;
        _scoreButton = point;
        
        buttonFrame.size.width = buttonFrame.size.width;
        buttonFrame.origin.x = self.avatarImageView.frame.origin.x + avatarWidth + 26;
        buttonFrame.origin.y = self.avatarImageView.frame.origin.y + self.avatarImageView.frame.size.height/2 - buttonFrame.size.height/2;
        buttonFrame.size.width = 80;
        UIButton * focuseButton = [self createNewButtonWithImageName:nil title:nil action:@selector(clickOnFocuseButton:) frame:buttonFrame];
        [focuseButton setBackgroundImage:UMComImageWithImageName(@"um_forum_user_focuse") forState:UIControlStateNormal];
        [self addSubview:focuseButton];
        _focuseButton = focuseButton;
        [self reloadSubViewsWithUser:user];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


- (UIButton *)createNewButtonWithImageName:(NSString *)imageName
                                     title:(NSString *)title
                                    action:(SEL)action
                                     frame:(CGRect)frame;
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_UserCenter_ProfileButtonFont);
    [button setTitleColor:UMComColorWithColorValueString(UMCom_Forum_UserCenter_ButtonTitleColor) forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:UMComImageWithImageName(imageName) forState:UIControlStateNormal];
    CGFloat imageWidth = 20;
    CGFloat imageEdge = 5;
    [button setImageEdgeInsets:UIEdgeInsetsMake(imageEdge, imageEdge, imageEdge, frame.size.width - imageWidth*2)];
    return button;
}


- (void)clickOnAlbumButton:(UIButton *)sender
{
    if (self.deleagte && [self.deleagte respondsToSelector:@selector(userProfileDetailView:clickOnAlbum:)]) {
        [self.deleagte userProfileDetailView:self clickOnAlbum:sender];
    }
}

- (void)clickOnTopicButton:(UIButton *)sender
{
    if (self.deleagte && [self.deleagte respondsToSelector:@selector(userProfileDetailView:clickOnFollowTopic:)]) {
        [self.deleagte userProfileDetailView:self clickOnFollowTopic:sender];
    }
}

- (void)clickOnScoreButton:(UIButton *)sender
{
    if (self.deleagte && [self.deleagte respondsToSelector:@selector(userProfileDetailView:clickOnScore:)]) {
        [self.deleagte userProfileDetailView:self clickOnScore:sender];
    }
}

- (void)clickOnFocuseButton:(UIButton *)sender
{
    if (self.deleagte && [self.deleagte respondsToSelector:@selector(userProfileDetailView:clickOnfocuse:)]) {
        [self.deleagte userProfileDetailView:self clickOnfocuse:sender];
    }
}



- (void)tapOnAvatar:(id)sender
{
    if (self.deleagte && [self.deleagte respondsToSelector:@selector(userProfileDetailView:clickOnAvatar:)]) {
        [self.deleagte userProfileDetailView:self clickOnAvatar:self.avatarImageView];
    }
}

- (void)reloadSubViewsWithUser:(UMComUser *)user
{
    NSString *scoreStr = [NSString stringWithFormat:@"%@",user.score];
    CGSize titleSize = [scoreStr sizeWithFont:UMComFontNotoSansLightWithSafeSize(UMCom_Forum_UserCenter_ProfileButtonFont) forWidth:100 lineBreakMode:NSLineBreakByTruncatingTail];
    CGRect buttonFrame = self.scoreButton.frame;
    buttonFrame.size.width = UMCom_Forum_UserCenter_ButtonWidth + titleSize.width;
    self.scoreButton.frame = buttonFrame;
    self.user = user;
    [self.avatarImageView setImageURL:[self.user iconUrlStrWithType:UMComIconSmallType]
                     placeHolderImage:UMComImageWithImageName(@"male")];
    if (self.user.medal_list.count > 0) {
        UMComMedal *medal = self.user.medal_list.firstObject;
        [self.medal_icon setImageURL:medal.icon_url placeHolderImage:nil];
    }
    if ([self.user.uid isEqualToString:[UMComSession sharedInstance].uid]|| [self.user.atype intValue] == 3) {
        _focuseButton.hidden = YES;
    }else{
        _focuseButton.hidden = NO;
        if ([self.user.has_followed boolValue] && [self.user.be_followed boolValue]) {
            [self.focuseButton setBackgroundImage:UMComImageWithImageName(@"um_forum_user_interfocuse") forState:UIControlStateNormal];
        }else if ([self.user.has_followed boolValue]){
             [self.focuseButton setBackgroundImage:UMComImageWithImageName(@"um_forum_user_hasfocused") forState:UIControlStateNormal];
        }else{
            [self.focuseButton setBackgroundImage:UMComImageWithImageName(@"um_forum_user_focuse") forState:UIControlStateNormal];
        }
    }
    self.nameLabel.text = self.user.name;
    CGSize textSize = CGSizeMake(self.nameLabel.frame.size.width, self.nameLabel.frame.size.height);
    if (self.user.name && self.user.name.length > 0) {
        textSize = [self.user.name sizeWithFont:self.nameLabel.font constrainedToSize:CGSizeMake(self.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        self.nameLabel.frame = CGRectMake(0, self.nameLabel.frame.origin.y, textSize.width, self.nameLabel.frame.size.height);
        self.nameLabel.center = CGPointMake(self.frame.size.width/2, self.nameLabel.center.y);
        self.genderView.hidden = NO;
    }
    self.genderView.center = CGPointMake(self.genderView.frame.size.width + textSize.width+self.nameLabel.frame.origin.x, self.nameLabel.center.y);
    if ([self.user.gender integerValue] == 0) {
        self.genderView.image = UMComImageWithImageName(@"um_forum_user_ladygender");
    }else{
        self.genderView.image = UMComImageWithImageName(@"um_forum_user_mangender");
    }
}

@end
