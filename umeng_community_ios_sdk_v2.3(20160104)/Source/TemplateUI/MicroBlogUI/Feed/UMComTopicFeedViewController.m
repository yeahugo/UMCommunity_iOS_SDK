//
//  UMComOneFeedViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 9/12/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComTopicFeedViewController.h"
#import "UMComTopic+UMComManagedObject.h"
#import "UMComAction.h"
#import "UMComSession.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComShowToast.h"
#import "UIViewController+UMComAddition.h"
#import "UMComEditViewController.h"
#import "UMComNavigationController.h"
#import "UMComMenuControlView.h"
#import "UMComPullRequest.h"
#import "UMComPushRequest.h"
#import "UMComUserTableViewCell.h"
#import "UMComRefreshView.h"
#import "UMComScrollViewDelegate.h"
#import "UMComClickActionDelegate.h"
#import "UMComFeed.h"
#import "UMComFeedTableViewController.h"
#import "UMComUsersTableViewController.h"

@interface UMComTopicFeedViewController ()<UMComClickActionDelegate,UMComScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *resultArray;

@property (nonatomic, assign) NSInteger prePage;

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) UMComMenuControlView *menuControlView;

@property (nonatomic, strong) UIView * followBackground;

@property (nonatomic, strong) UIViewController *lastViewController;


@end

@implementation UMComTopicFeedViewController

-(id)initWithTopic:(UMComTopic *)topic
{
    self = [super init];
    if (self) {
        self.topic = topic;
   }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitleViewWithTitle:[NSString stringWithFormat:TopicString,self.topic.name]];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    UIView *topicDescription = [self createTopicDescriptionBackgroundView];
    UMComMenuControlView *menuControlView = [[UMComMenuControlView alloc] initWithFrame:CGRectMake(0, topicDescription.frame.size.height+topicDescription.frame.origin.y, self.view.frame.size.width, 50)];
    [menuControlView.leftButton setTitle:@"话题聚合" forState:UIControlStateNormal];
    [menuControlView.rightButton setTitle:@"活跃用户" forState:UIControlStateNormal];
    menuControlView.scrollImageHeight = 7;
    menuControlView.bottomLineHeight = 1;
    __weak typeof(self) weakSelf = self;
    menuControlView.SelectedIndex = ^(NSInteger index){
        [weakSelf tranToPage:index];
    };
    self.menuControlView = menuControlView;
    
    self.followBackground = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, topicDescription.frame.size.height + self.menuControlView.frame.size.height)];
    self.followBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.followBackground addSubview:topicDescription];
    [self.followBackground addSubview:self.menuControlView];
    [self.view addSubview:self.followBackground];

    [self creatChildViewControllers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

//创建子ViewControllers
- (void)creatChildViewControllers
{
    CGRect frame = self.view.frame;
    frame.origin.y = self.followBackground.frame.size.height;
    frame.size.height = self.view.frame.size.height - frame.origin.y;
    UMComFeedTableViewController *feedTableViewController = [[UMComFeedTableViewController alloc]initWithFetchRequest:[[UMComTopicFeedsRequest alloc] initWithTopicId:self.topic.topicID count:BatchSize order:UMComFeedSortTypeDefault isReverse:NO]];
    feedTableViewController.isAutoStartLoadData = YES;
    feedTableViewController.isShowEditButton = YES;
    feedTableViewController.view.frame = frame;
    [self addChildViewController:feedTableViewController];
    [self.view addSubview:feedTableViewController.view];

    
    UMComUsersTableViewController *followersTableViewController = [[UMComUsersTableViewController alloc] initWithFetchRequest:[[UMComRecommendTopicUsersRequest alloc] initWithTopicId:self.topic.topicID count:BatchSize]];
    followersTableViewController.view.frame = frame;
    followersTableViewController.isAutoStartLoadData = YES;
    [self addChildViewController:followersTableViewController];
    [self.view addSubview:followersTableViewController.view];

    self.lastViewController = followersTableViewController;
    [self tranToPage:0];
}

- (UIView *)createTopicDescriptionBackgroundView
{
    CGFloat buttonWidth = 90;
    CGFloat rightSpace = 14;
    CGFloat followViewHeight = 50;
    NSString *topicDescriptionString = @"";
    if (self.topic.descriptor && self.topic.descriptor.length != 0) {
        topicDescriptionString = self.topic.descriptor;
    } else {
        topicDescriptionString = self.topic.name;
    }
    CGSize size = [topicDescriptionString sizeWithFont:UMComFontNotoSansLightWithSafeSize(15) constrainedToSize:CGSizeMake(self.view.frame.size.width-buttonWidth-rightSpace-10, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    if (size.height > followViewHeight) {
        followViewHeight = size.height;
    }
    followViewHeight += 16;
    UIView *followBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, followViewHeight)];
    followBgView.backgroundColor = [UMComTools colorWithHexString:@"#f1f1f1"];
    followBgView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:followBgView];
    UILabel *topicDescription = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, self.view.frame.size.width-buttonWidth-rightSpace-26, followViewHeight)];
    topicDescription.text = topicDescriptionString;
    topicDescription.font = UMComFontNotoSansLightWithSafeSize(15);
    topicDescription.numberOfLines = 0;
    topicDescription.backgroundColor = [UIColor clearColor];
    topicDescription.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [followBgView addSubview:topicDescription];
    UIButton *followButton = [UIButton buttonWithType:UIButtonTypeCustom];
    followButton.frame = CGRectMake(topicDescription.frame.size.width + 26, (followViewHeight -24)/2, buttonWidth, 24);
    followButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [followButton addTarget:self action:@selector(onClickFollow:) forControlEvents:UIControlEventTouchUpInside];
    followButton.titleLabel.font = UMComFontNotoSansLightWithSafeSize(14);
    [followBgView addSubview:followButton];
    [self setFocused:[self.topic.is_focused boolValue] button:followButton];
    UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, followBgView.frame.size.height-0.5, self.view.frame.size.width, 0.5)];
    bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    bottomLine.backgroundColor = [UMComTools colorWithHexString:TableViewSeparatorColor];
    [followBgView addSubview:bottomLine];
    return followBgView;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - privite method

-(void)onClickFollow:(id)sender
{
    __weak UMComTopicFeedViewController *weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [UMComPushRequest followerWithTopic:self.topic isFollower:![self.topic.is_focused boolValue] completion:^(NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if (!error) {
                [weakSelf setFocused:[weakSelf.topic.is_focused boolValue] button:sender];
            } else {
                if (error.code == ERR_CODE_HAVE_FOCUSED) {
                    [weakSelf setFocused:YES button:sender];
                }
                [UMComShowToast showFetchResultTipWithError:error];
            }
        }];
    }];
}


- (void)setFocused:(BOOL)focused button:(UIButton *)button
{
    [button setBackgroundColor:[UIColor whiteColor]];
    CALayer * downButtonLayer = [button layer];
    UIColor *bcolor = [UMComTools colorWithHexString:TableViewSeparatorColor];//;
    [downButtonLayer setBorderColor:[bcolor CGColor]];
    [downButtonLayer setBorderWidth:0.5];
    if([self.topic.is_focused boolValue]){
        [button setTitle:UMComLocalizedString(@"Has_Focused",@"取消关注") forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:15.0/255.0 green:121.0/255.0 blue:254.0/255.0 alpha:1] forState:UIControlStateNormal];
    }else{
        [button setTitle:UMComLocalizedString(@"No_Focused",@"关注") forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

//- (void)onClickTopicFeedsButton:(id)sender {

////    [self resetContentOffsetOfScrollView:self.feedsTableView];

//}
//
//- (void)onClickHotUserFeedsButton:(id)sender {
//
////    [self resetContentOffsetOfScrollView:self.hotUsersTableView];

//}

- (void)tranToPage:(NSInteger)page
{
    self.prePage = self.currentPage;
    self.currentPage = page;
    UMComRequestTableViewController *requestTableViewController = self.childViewControllers[page];
    if (requestTableViewController.dataArray.count == 0) {
        [requestTableViewController loadAllData:nil fromServer:nil];
    }
    [self transitionFromViewController:self.lastViewController toViewController:requestTableViewController];
}


- (void)transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
    if (fromViewController == toViewController) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self transitionFromViewController:fromViewController toViewController:toViewController duration:0.25 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGPoint toCenter = fromViewController.view.center;
//        toCenter.x = weakSelf.view.frame.size.width/2;
//        toCenter.y = toViewController.view.center.y;
        toViewController.view.center = toCenter;
        
        CGPoint fromeCenter = toCenter;
        if (weakSelf.currentPage > weakSelf.prePage) {
            fromeCenter.x = -weakSelf.view.frame.size.width*3/2;
        }else if(weakSelf.currentPage < weakSelf.prePage){
            fromeCenter.x = weakSelf.view.frame.size.width*3/2;
        }
    } completion:^(BOOL finished) {
        weakSelf.lastViewController = toViewController;
    }];
}


- (void)resetContentOffsetOfScrollView:(UIScrollView *)scrollView
{
    if (!(scrollView.contentOffset.y >= -self.followBackground.frame.origin.y && self.followBackground.frame.size.height-self.menuControlView.frame.size.height == -self.followBackground.frame.origin.y)) {
        [scrollView setContentOffset:CGPointMake(self.followBackground.frame.origin.x, -self.followBackground.frame.origin.y)];
    }
}


- (void)refreshScrollViewWithView:(UIScrollView *)scrollView
{
    CGFloat contenSizeH = self.view.frame.size.height + self.followBackground.frame.size.height;
    if (contenSizeH < self.followBackground.frame.size.height + scrollView.contentSize.height) {
        contenSizeH = self.followBackground.frame.size.height + scrollView.contentSize.height;
    }
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, contenSizeH);
    [scrollView setContentOffset:CGPointMake(self.followBackground.frame.origin.x, -self.followBackground.frame.origin.y)];
}


- (void)scrollEditButtonWithScrollView:(UIScrollView *)scrollView lastPosition:(CGPoint)lastPosition
{
    CGFloat height = self.followBackground.frame.size.height - self.menuControlView.frame.size.height;
    if (scrollView.contentOffset.y < height && scrollView.contentOffset.y >= 0) {
        self.followBackground.frame = CGRectMake(self.followBackground.frame.origin.x,-scrollView.contentOffset.y, self.followBackground.frame.size.width, self.followBackground.frame.size.height);
    }else if (scrollView.contentOffset.y >= height && scrollView.contentOffset.y >= 0) {
        self.followBackground.frame = CGRectMake(self.followBackground.frame.origin.x, -self.followBackground.frame.size.height+self.menuControlView.frame.size.height, self.followBackground.frame.size.width, self.followBackground.frame.size.height);
    }else if (scrollView.contentOffset.y == 0){
          self.followBackground.frame = CGRectMake(self.followBackground.frame.origin.x,0, self.followBackground.frame.size.width, self.followBackground.frame.size.height);
    }
//    if (scrollView == self.feedsTableView) {
//        if (scrollView.contentOffset.y >0 && scrollView.contentOffset.y > lastPosition.y+15) {
//            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
//                self.editButton.center = CGPointMake(self.editButton.center.x, [UIApplication sharedApplication].keyWindow.bounds.size.height+DeltaBottom);
//            } completion:nil];
//        }  else{
//            if (scrollView.contentOffset.y < lastPosition.y-15) {
//                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
//                    self.editButton.center = CGPointMake(self.editButton.center.x, [UIApplication sharedApplication].keyWindow.bounds.size.height-DeltaBottom);
//                } completion:nil];
//            }
//        }
//    }
}

#pragma mark - UMComScrollViewDelegate
- (void)customScrollViewDidScroll:(UIScrollView *)scrollView lastPosition:(CGPoint)lastPosition
{
    [self scrollEditButtonWithScrollView:scrollView lastPosition:lastPosition];
}

- (void)customScrollViewDidEnd:(UIScrollView *)scrollView lastPosition:(CGPoint)lastPosition
{
    [self scrollEditButtonWithScrollView:scrollView lastPosition:lastPosition];
}

#pragma mark - UMComClickActionDelegate
- (void)customObj:(id)obj clickOnTopic:(UMComTopic *)topic
{
    if (!topic) {
        return;
    }
    NSString *topicName = @"";
    if (topic.name) {
        topicName = topic.name;
    }
    if ([topicName isEqualToString:self.topic.name]) {
        return;
    }
    UMComTopicFeedViewController *oneFeedViewController = [[UMComTopicFeedViewController alloc] initWithTopic:topic];
    [self.navigationController  pushViewController:oneFeedViewController animated:YES];
}

- (void)removeUserFromUsers:(UMComUser *)user
{
//    if (user) {
//        [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            if ([[obj uid] isEqualToString:user.uid]) {
//                [self.hotUsersTableView.dataArray removeObject:obj];
//                *stop = YES;
//                [_hotUsersTableView reloadData];
//            }
//        }];
//    }
}

- (void)customObj:(id)obj clickOnFollowUser:(UMComUser *)user
{
    __weak UMComUserTableViewCell *weakCell = (UMComUserTableViewCell *)obj;;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if ([weakCell isKindOfClass:[UMComUserTableViewCell class]]) {
            [weakCell focusUserAfterLoginSucceedWithResponse:^(NSError *error) {
                if (!error) {
                    if ([user.atype intValue] == 3) {
                        [self removeUserFromUsers:user];
                    }
                }
            }];
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
