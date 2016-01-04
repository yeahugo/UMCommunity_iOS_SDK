//
//  UMComTopicPostViewController.m
//  UMCommunity
//
//  Created by umeng on 12/2/15.
//  Copyright © 2015 Umeng. All rights reserved.
//

#import "UMComTopicPostViewController.h"
#import "UMComHorizonCollectionView.h"
#import "UMComTools.h"
#import "UMComTopic.h"
#import "UMComBarButtonItem.h"
#import "UMComPushRequest.h"
#import "UMComPostingViewController.h"
#import "UMComNavigationController.h"
#import "UMComAction.h"
#import "UMComPullRequest.h"
#import "UIViewController+UMComAddition.h"
#import "UMComTopicPostTableViewController.h"
#import "UMComHotPostViewController.h"

//颜色值
#define UMCom_Forum_TopicPost_TopMenu_NomalTextColor @"#999999"
#define UMCom_Forum_TopicPost_TopMenu_HighLightTextColor @"#008BEA"
#define UMCom_Forum_TopicPost_DropMenu_NomalTextColor @"#8F8F8F"
#define UMCom_Forum_TopicPost_DorpMenu_HighLightTextColor @"#F5F5F5"

//文字大小
#define UMCom_Forum_TopicPost_TopMenu_TextFont 18
#define UMCom_Forum_TopicPost_DropMenu_TextFont 15

#define UMCom_Forum_TopicPost_MenuHeight 40

@interface UMComTopicPostViewController ()
<UMComHorizonCollectionViewDelegate>

@property (nonatomic, strong) UMComTopic *topic;

@property (nonatomic, strong) UMComHorizonCollectionView *menuView;

@property (nonatomic, strong) UIViewController *currentController;

@property (nonatomic, assign) CGRect originFrame;

@end

@implementation UMComTopicPostViewController

- (instancetype)initWithTopic:(UMComTopic *)topic
{
     // TODO:check topic 
    if (self = [super init]) {
        self.topic = topic;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    self.originFrame = self.view.bounds;
    [self setForumUITitle:_topic.name];
    
    [self setForumUIBackButton];
    
    [self createSubControllers];
    
    [self transitionChildViewControllers];
    
    [self creatNavigationItemList];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    // in viewDidLoad UICollectionViewCell 不会创建
    if (!_menuView) {
        UMComHorizonCollectionView *collectionMenuView = [[UMComHorizonCollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, UMCom_Forum_TopicPost_MenuHeight) itemCount:4];
        collectionMenuView.dropMenuSuperView = self.view;
        collectionMenuView.dropMenuTopMargin = 5 + collectionMenuView.frame.size.height;
        collectionMenuView.indicatorLineHeight = 2;
        collectionMenuView.dropMenuLeftMargin = -5;
        collectionMenuView.indicatorLineWidth = UMComWidthScaleBetweenCurentScreenAndiPhone6Screen(70.f);
        collectionMenuView.indicatorLineLeftEdge = UMComWidthScaleBetweenCurentScreenAndiPhone6Screen(11);
        collectionMenuView.cellDelegate = self;
        collectionMenuView.scrollIndicatorView.backgroundColor = UMComColorWithColorValueString(UMCom_Forum_TopicPost_TopMenu_HighLightTextColor);;
        self.menuView = collectionMenuView;
    }
    
    if (![_menuView superview]) {
        [self.view addSubview:_menuView];
//        [self resetFrame];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.menuView hiddenDropMenuView];
}

- (void)createSubControllers
{
    CGRect frame = self.originFrame;
    frame.origin.y = UMCom_Forum_TopicPost_MenuHeight;
    frame.size.height = self.originFrame.size.height - UMCom_Forum_TopicPost_MenuHeight;
    frame.origin.x = 0;
    for (int index = 0; index < 3; index ++) {
        UMComTopicPostTableViewController *topicTableViewController = [[UMComTopicPostTableViewController alloc]initWithTopic:self.topic];
        if (index != 0) {
           frame.origin.x = self.view.frame.size.width;
        }
        if (index == 0) {
            topicTableViewController.isAutoStartLoadData = YES;
            topicTableViewController.showTopMark = YES;
            UMComTopicFeedsRequest *topicFeedsRequest = [[UMComTopicFeedsRequest alloc]initWithTopicId:self.topic.topicID count:BatchSize order:UMComFeedSortTypeDefault isReverse:YES];
            topicTableViewController.fetchRequest = topicFeedsRequest;
            topicFeedsRequest.isShowGlobalTopItems = NO;//不显示全局置顶
            [self.view addSubview:topicTableViewController.view];
        }else if(index == 1){
            UMComTopicFeedsRequest *topicFeedsRequest = [[UMComTopicFeedsRequest alloc]initWithTopicId:self.topic.topicID count:BatchSize order:UMComFeedSortTypeComment isReverse:YES];
            topicFeedsRequest.isShowGlobalTopItems = NO;//不显示全局置顶
            topicTableViewController.showTopMark = YES;
            topicTableViewController.fetchRequest = topicFeedsRequest;
        }else if(index == 2){
            topicTableViewController.fetchRequest = [[UMComTopicRecommendFeedsRequest alloc]initWithTopicId:self.topic.topicID count:BatchSize];            
        }
        topicTableViewController.view.frame = frame;
        [self addChildViewController:topicTableViewController];
    }
    
    UMComHotPostViewController *hostViewController = [[UMComHotPostViewController alloc]initWithTopic:self.topic];
    hostViewController.view.frame = frame;
    [self addChildViewController:hostViewController];
}


- (void)creatNavigationItemList
{
    UMComBarButtonItem *editButton = [[UMComBarButtonItem alloc] initWithNormalImageName:@"um_forum_post_edit_highlight" target:self action:@selector(showPostEditViewController:)];
    editButton.customButtonView.frame = CGRectMake(0, 0, 20, 20);
    editButton.customButtonView.titleLabel.font = UMComFontNotoSansLightWithSafeSize(17);
    UMComBarButtonItem *topicFocusedButton = nil;
    if ([[self.topic is_focused] boolValue]) {
        topicFocusedButton = [[UMComBarButtonItem alloc] initWithNormalImageName:@"um_forum_topic_focused" target:self action:@selector(followTopic:)];;
    }else{
       topicFocusedButton = [[UMComBarButtonItem alloc] initWithNormalImageName:@"um_forum_topic_nofocused" target:self action:@selector(followTopic:)];
    }
    topicFocusedButton.customButtonView.frame = CGRectMake(0, 0, 20, 20);
    topicFocusedButton.customButtonView.titleLabel.font = UMComFontNotoSansLightWithSafeSize(17);
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]init];
    UIView *spaceView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 20)];
    spaceView.backgroundColor = [UIColor clearColor];
    [spaceItem setCustomView:spaceView];
    
    UMComBarButtonItem *rightSpaceItem = [[UMComBarButtonItem alloc] init];
    rightSpaceItem.customButtonView.frame = CGRectMake(0, 12, 20, 4);
    rightSpaceItem.customButtonView.titleLabel.font = UMComFontNotoSansLightWithSafeSize(17);
    [self.navigationItem setRightBarButtonItems:@[rightSpaceItem,topicFocusedButton,spaceItem,editButton,]];
}

- (void)showPostEditViewController:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            UMComPostingViewController *editViewController = [[UMComPostingViewController alloc]initWithTopic:weakSelf.topic];
            editViewController.postCreatedFinish = ^(UMComFeed *feed){
                UMComPostTableViewController *topicPostVc = self.childViewControllers[0];
                [topicPostVc inserNewFeedInTabelView:feed];
            };
            UMComNavigationController *navigationController = [[UMComNavigationController alloc]initWithRootViewController:editViewController];
            [weakSelf presentViewController:navigationController animated:YES completion:nil];
        }
    }];
}

- (void)followTopic:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            [UMComPushRequest followerWithTopic:weakSelf.topic isFollower:![weakSelf.topic.is_focused boolValue] completion:^(NSError *error) {
                if ([weakSelf.topic.is_focused boolValue]) {
                    [sender setBackgroundImage:UMComImageWithImageName(@"um_forum_topic_focused") forState:UIControlStateNormal];
                }else{
                    [sender setBackgroundImage:UMComImageWithImageName(@"um_forum_topic_nofocused") forState:UIControlStateNormal];
                }
            }];
        }
    }];
}




#pragma mark - HorizionMenuViewDelegate
- (void)horizonCollectionView:(UMComHorizonCollectionView *)collectionView reloadCell:(UMComHorizonCollectionCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.label.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height-self.menuView.indicatorLineHeight);
    if (indexPath.row == 0) {
        cell.label.text = UMComLocalizedString(@"um_com_forum_topic_latest_post", @"最新发布");
        cell.imageView.hidden = YES;
    }else if (indexPath.row == 1){
        cell.label.text = UMComLocalizedString(@"um_com_forum_topic_latest_reply", @"最后回复");
        cell.imageView.hidden = YES;
    }else if (indexPath.row == 2){
        cell.label.text = UMComLocalizedString(@"um_com_forum_topic_recommend", @"推荐");
        cell.imageView.hidden = YES;
    }else if (indexPath.row == 3){
        cell.imageView.hidden = NO;
        CGRect imageFrame = cell.imageView.frame;
        imageFrame.origin.x = UMComWidthScaleBetweenCurentScreenAndiPhone6Screen(cell.frame.size.width/2 + 12);
        imageFrame.origin.y = UMComWidthScaleBetweenCurentScreenAndiPhone6Screen(18.f);
        imageFrame.size.height = UMComWidthScaleBetweenCurentScreenAndiPhone6Screen(8.f);
        imageFrame.size.width = UMComWidthScaleBetweenCurentScreenAndiPhone6Screen(16.f);
        cell.imageView.frame = imageFrame;
        CGRect labelFrame = cell.label.frame;
        labelFrame.size.width = cell.frame.size.width/2;
        labelFrame.origin.x = 10;
        cell.label.frame = labelFrame;
        cell.label.text = UMComLocalizedString(@"um_com_forum_topic_hot", @"最热");
    }
    if (indexPath.row == collectionView.currentIndex) {
        cell.imageView.image = UMComImageWithImageName(@"um_dropdownblue_forum");
        cell.label.textColor = UMComColorWithColorValueString(UMCom_Forum_TopicPost_TopMenu_HighLightTextColor);
    }else{
        cell.imageView.image = UMComImageWithImageName(@"um_dropdowngray_forum");
        cell.label.textColor = UMComColorWithColorValueString(UMCom_Forum_TopicPost_TopMenu_NomalTextColor);
    }
    cell.label.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_TopicPost_TopMenu_TextFont);

}


- (BOOL)horizonCollectionView:(UMComHorizonCollectionView *)collectionView showDropDownMenuAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.row == 3) {
        return YES;
    }else{
        return NO;
    }
}


- (NSInteger)horizonCollectionView:(UMComHorizonCollectionView *)collectionView numbersOfDropdownMenuRowsAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3) {
        return 4;
    }else{
        return 0;
    }
}

- (void)horizonCollectionView:(UMComHorizonCollectionView *)collectionView didSelectedColumn:(NSInteger)column
{
    if (column == 3) {
        return;
    }
    UMComPostTableViewController *postViewController = self.childViewControllers[column];
    if (postViewController.dataArray.count == 0 && postViewController.isLoadFinish) {
        [postViewController loadAllData:nil fromServer:nil];
    }
    [self transitionChildViewControllers];
}

- (void)horizonCollectionView:(UMComHorizonCollectionView *)collectionView
       reloadDropdownMuneCell:(UMComDropdownColumnCell *)cell
                       column:(NSInteger)column
                          row:(NSInteger)row
{
    if (column == 3) {
        if (row == 0) {
            cell.label.text = @"1天";
        }else if (row == 1){
            cell.label.text = @"3天";
        }else if (row == 2){
            cell.label.text = @"7天";
        }else if (row == 3){
            cell.label.text = @"30天";
        }
    }
    cell.label.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_TopicPost_DropMenu_TextFont);
}

- (void)horizonCollectionView:(UMComHorizonCollectionView *)collectionView
            didSelectedColumn:(NSInteger)column
                          row:(NSInteger)row
{

    if (column == 3) {
        UMComHotPostViewController *postTableViewController = self.childViewControllers[column];
        [postTableViewController setPage:row];
    }
    [self transitionChildViewControllers];
}



- (void)transitionChildViewControllers
{
    [self transitionFromViewControllerAtIndex:self.menuView.previewsIndex toViewControllerAtIndex:self.menuView.currentIndex animations:^{
        
    } completion:^(BOOL finished) {
        
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
