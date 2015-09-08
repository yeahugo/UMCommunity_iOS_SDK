//
//  UMComOneFeedViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 9/12/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComTopicFeedViewController.h"
#import "UMComTopic+UMComManagedObject.h"
#import "UMComFeedTableView.h"
#import "UMComAction.h"
#import "UMComSession.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComShowToast.h"
#import "UMComUsersTableView.h"
#import "UIViewController+UMComAddition.h"
#import "UMComEditViewController.h"
#import "UMComNavigationController.h"
#import "UMComMenuControlView.h"
#import "UMComPullRequest.h"
#import "UMComUserTableViewCell.h"
#import "UMComRefreshView.h"
#import "UMComScrollViewDelegate.h"
#import "UMComClickActionDelegate.h"

@interface UMComTopicFeedViewController ()<UMComClickActionDelegate,UMComScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *resultArray;

@property (strong, nonatomic) UIButton *editedButton;

@property (nonatomic, strong) UMComUsersTableView *hotUsersTableView;

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) UMComMenuControlView *menuControlView;

@property (nonatomic, strong) UIView * followBackground;

@end

#define DeltaBottom  45
#define DeltaRight 45

@implementation UMComTopicFeedViewController

-(id)initWithTopic:(UMComTopic *)topic
{
    self = [super initWithNibName:@"UMComTopicFeedViewController" bundle:nil];
    if (self) {
        self.topic = topic;
        UMComTopicFeedsRequest *topicFeedsController = [[UMComTopicFeedsRequest alloc] initWithTopicId:topic.topicID count:BatchSize order:UMComFeedSortTypeDefault isReverse:YES];
        self.fetchFeedsController = topicFeedsController;
   }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitleViewWithTitle:[NSString stringWithFormat:@"#%@#",self.topic.name]];
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
        if (weakSelf.currentPage == index) {
            return ;
        }
        weakSelf.currentPage = index;
        if (index == 0) {
            [weakSelf onClickTopicFeedsButton:nil];
        }else{
            [weakSelf onClickHotUserFeedsButton:nil];
        }
    };
    self.menuControlView = menuControlView;
    
    self.followBackground = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, topicDescription.frame.size.height + self.menuControlView.frame.size.height)];
    self.followBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.followBackground addSubview:topicDescription];
    [self.followBackground addSubview:self.menuControlView];
    [self.view addSubview:self.followBackground];
    
    CGRect headViewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.followBackground.frame.size.height);
    self.feedsTableView.frame = CGRectMake(0, 0, self.feedsTableView.frame.size.width, self.view.frame.size.height);
    self.feedsTableView.scrollViewDelegate = self;
    self.feedsTableView.tableHeaderView = [[UIView alloc]initWithFrame:headViewFrame];
    
    self.hotUsersTableView = [[UMComUsersTableView alloc]initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.feedsTableView.frame.size.width, self.feedsTableView.frame.size.height) style:UITableViewStylePlain];
    self.hotUsersTableView.clickActionDelegate = self;
    self.hotUsersTableView.scrollViewDelegate = self;
    self.hotUsersTableView.fetchRequest = [[UMComRecommendTopicUsersRequest alloc]initWithTopicId:self.topic.topicID count:BatchSize];
    self.hotUsersTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.hotUsersTableView.tableHeaderView = [[UIView alloc]initWithFrame:headViewFrame];
    [self.view addSubview:self.hotUsersTableView];
    [self creatEditedButton];
    self.currentPage = 0;
    [self.view bringSubviewToFront:self.feedsTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.editedButton.center = CGPointMake(self.view.frame.size.width-DeltaRight, [UIApplication sharedApplication].keyWindow.bounds.size.height-DeltaBottom);
    [[UIApplication sharedApplication].keyWindow addSubview:self.editedButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewFeedDataWhenFeedCreatSucceed:) name:kNotificationPostFeedResult object:nil];
    [self.view bringSubviewToFront:self.followBackground];
    self.feedsTableView.hidden = NO;
    self.hotUsersTableView.hidden = NO;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.editedButton removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationPostFeedResult object:nil];
    self.feedsTableView.hidden = YES;
    self.hotUsersTableView.hidden = YES;
    [self.view bringSubviewToFront:self.followBackground];
}

- (void)creatEditedButton
{
    self.editedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.editedButton.frame = CGRectMake(0, 0, 50, 50);
    [self.editedButton setImage:[UIImage imageNamed:@"new"] forState:UIControlStateNormal];
    [self.editedButton setImage:[UIImage imageNamed:@"new+"] forState:UIControlStateSelected];
    [self.editedButton addTarget:self action:@selector(onClickEdit:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)addNewFeedDataWhenFeedCreatSucceed:(NSNotification *)notification
{
    UMComFeed *newFeed = (UMComFeed *)notification.object;
    if (newFeed) {
        for (UMComTopic *topic in newFeed.topics) {
            if ([self.topic.topicID isEqualToString:topic.topicID]) {
                [self.feedsTableView insertFeedStyleToDataArrayWithFeed:newFeed];    
                break;
            }
        }
    }
}

-(void)onClickFollow:(id)sender
{
    __weak UMComTopicFeedViewController *weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        [self.topic setFocused:![self.topic.is_focused boolValue] block:^(NSError * error) {
            if (!error) {
                [weakSelf setFocused:[weakSelf.topic.is_focused boolValue] button:sender];
            }else{
                if (error.code == 30001) {
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


- (void)onClickEdit:(id)sender
{
    __weak typeof(self) weakSelf = self;
   [[UMComAction action] performActionAfterLogin:self.topic viewController:self completion:^(NSArray *data, NSError *error) {
       UMComEditViewController *editViewController = nil;
       editViewController = [[UMComEditViewController alloc] initWithTopic:self.topic];
       UMComNavigationController *editNaviController = [[UMComNavigationController alloc] initWithRootViewController:editViewController];
       [weakSelf presentViewController:editNaviController animated:YES completion:nil];
   }];
}

- (void)onClickTopicFeedsButton:(id)sender {
    self.hotUsersTableView.scrollViewDelegate = nil;
    self.feedsTableView.scrollViewDelegate = self;
//    self.editedButton.frame = CGRectMake(self.view.frame.size.width-70, self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height, 50, 50);
    self.editedButton.hidden = NO;
    [self resetContentOffsetOfScrollView:self.feedsTableView];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [weakSelf.view bringSubviewToFront:weakSelf.followBackground];
        weakSelf.feedsTableView.frame = CGRectMake(0, weakSelf.feedsTableView.frame.origin.y, weakSelf.feedsTableView.frame.size.width, weakSelf.feedsTableView.frame.size.height);
        weakSelf.hotUsersTableView.frame = CGRectMake(weakSelf.feedsTableView.frame.size.width, weakSelf.hotUsersTableView.frame.origin.y, weakSelf.feedsTableView.frame.size.width, weakSelf.feedsTableView.frame.size.height);
    } completion:nil];
}

- (void)onClickHotUserFeedsButton:(id)sender {
    self.feedsTableView.scrollViewDelegate = nil;
    self.hotUsersTableView.scrollViewDelegate = self;
    if (self.hotUsersTableView.dataArray.count == 0) {
        [self.hotUsersTableView loadAllData:nil fromServer:nil];
    }
    [self resetContentOffsetOfScrollView:self.hotUsersTableView];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [weakSelf.view bringSubviewToFront:weakSelf.followBackground];
        weakSelf.feedsTableView.frame = CGRectMake(-weakSelf.feedsTableView.frame.size.width, weakSelf.feedsTableView.frame.origin.y, weakSelf.feedsTableView.frame.size.width, weakSelf.feedsTableView.frame.size.height);
        weakSelf.hotUsersTableView.frame = CGRectMake(0, weakSelf.hotUsersTableView.frame.origin.y, weakSelf.feedsTableView.frame.size.width, weakSelf.feedsTableView.frame.size.height);
    } completion:nil];
    [self.view bringSubviewToFront:self.followBackground];
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
    if (scrollView == self.feedsTableView) {
        if (scrollView.contentOffset.y >0 && scrollView.contentOffset.y > lastPosition.y+15) {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.editedButton.center = CGPointMake(self.editedButton.center.x, [UIApplication sharedApplication].keyWindow.bounds.size.height+DeltaBottom);
            } completion:nil];
        }  else{
            if (scrollView.contentOffset.y < lastPosition.y-15) {
                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    self.editedButton.center = CGPointMake(self.editedButton.center.x, [UIApplication sharedApplication].keyWindow.bounds.size.height-DeltaBottom);
                } completion:nil];
            }
        }
    }
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
    if (user) {
        [self.hotUsersTableView.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([[obj uid] isEqualToString:user.uid]) {
                [self.hotUsersTableView.dataArray removeObject:obj];
                *stop = YES;
                [_hotUsersTableView reloadData];
            }
        }];
    }
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
