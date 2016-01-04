//
//  UMComNoticeSystemViewController.m
//  UMCommunity
//
//  Created by umeng on 15/7/9.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComNoticeSystemViewController.h"
#import "UMComPageControlView.h"
#import "UMComTools.h"
#import "UMComBarButtonItem.h"
#import "UIViewController+UMComAddition.h"
#import "UMComFeedTableViewController.h"
#import "UMComPullRequest.h"
#import "UMComSession.h"
#import "UMComTopicFeedViewController.h"
#import "UMComUserCenterViewController.h"
#import "UMComCommentEditView.h"
#import "UMComPushRequest.h"
#import "UMComShowToast.h"
#import "UMComMenuControlView.h"
#import "UMComRefreshView.h"
#import "UMComClickActionDelegate.h"
#import "UMComUser.h"
#import "UMComComment.h"
#import "UMComUnReadNoticeModel.h"
#import "UMComFeedsTableViewCell.h"
#import "UMComAction.h"
#import "UMComFeedDetailViewController.h"
#import "UMComCommentEditView.h"
#import "UMComPullRequest.h"
#import "UMComLikeTableViewController.h"
#import "UMComFeedTableViewController.h"
#import "UMComCommentMenuViewController.h"

@interface UMComNoticeSystemViewController ()<UMComClickActionDelegate>

@property (nonatomic, strong) UMComPageControlView *titlePageControl;

@property (nonatomic, strong) UMComCommentEditView *commentEditView;


@end

@implementation UMComNoticeSystemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self creatNigationItemView];
    
    [self createSubControllers];
    
    UISwipeGestureRecognizer *leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipToLeftDirection:)];
    leftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftGestureRecognizer];
    
    UISwipeGestureRecognizer *rightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipToRightDirection:)];
    rightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightGestureRecognizer];
    // Do any additional setup after loading the view.
}
- (void)swipToLeftDirection:(UISwipeGestureRecognizer *)swip
{
    if (self.titlePageControl.currentPage < 2) {
        self.titlePageControl.currentPage += 1;
        [self transitionViews];
    }
}

- (void)swipToRightDirection:(UISwipeGestureRecognizer *)swip
{
    if (self.titlePageControl.currentPage > 0) {
        self.titlePageControl.currentPage -= 1;
        [self transitionViews];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNoticeItemViews) name:kUMComUnreadNotificationRefreshNotification object:nil];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)creatNigationItemView
{
     //创建菜单栏
    UMComPageControlView *titlePageControl = [[UMComPageControlView alloc]initWithFrame:CGRectMake(0, 0, 200, 28) itemTitles:[NSArray arrayWithObjects:UMComLocalizedString(@"@Me", @"@我"),UMComLocalizedString(@"comment",@"评论"),UMComLocalizedString(@"like",@"点赞"), nil] currentPage:0];
    titlePageControl.currentPage = 0;
    titlePageControl.selectedColor = [UIColor whiteColor];
    titlePageControl.unselectedColor = [UIColor blackColor];
    [titlePageControl setItemImages:[NSArray arrayWithObjects:UMComImageWithImageName(@"left_frame"),UMComImageWithImageName(@"midle_frame"),UMComImageWithImageName(@"right_item"), nil]];
    __weak typeof(self) wealSelf = self;
    titlePageControl.didSelectedAtIndexBlock = ^(NSInteger index){
        [wealSelf transitionViews];
    };
    [titlePageControl reloadPages];
    [self.navigationItem setTitleView:titlePageControl];
    self.titlePageControl = titlePageControl;
    [self refreshNoticeItemViews];
    
}

- (void)refreshNoticeItemViews
{
    CGFloat rightDal = 0;
    if (self.view.frame.size.width > 320) {
        rightDal = 8.6*3/2;
    }
    NSMutableArray *tempArray = [NSMutableArray array];
    
    UMComUnReadNoticeModel *unReadNotice = [UMComSession sharedInstance].unReadNoticeModel;
    
    if (unReadNotice.notiByAtCount > 0) {
        [tempArray addObject:@0];
    }
    if (unReadNotice.notiByCommentCount > 0) {
        [tempArray addObject:@1];
    }
    if (unReadNotice.notiByLikeCount > 0) {
        [tempArray addObject:@2];
    }
    self.titlePageControl.indexesOfNotices = tempArray;
    [self.titlePageControl reloadPages];
}

- (void)createSubControllers
{
    CGRect commonFrame = self.view.frame;
    commonFrame.origin.y = 0;
    commonFrame.size.height = commonFrame.size.height - commonFrame.origin.y;
    CGFloat centerY = commonFrame.size.height/2+commonFrame.origin.y;
    UMComFeedTableViewController *hotPostListController = [[UMComFeedTableViewController alloc] initWithFetchRequest:[[UMComUserFeedBeAtRequest alloc] initWithCount:BatchSize]];
    [hotPostListController loadAllData:nil fromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        if (!error) {
            [UMComSession sharedInstance].unReadNoticeModel.notiByAtCount = NO;
        }
    }];
    [self addChildViewController:hotPostListController];
    [self.view addSubview:hotPostListController.view];
    hotPostListController.view.frame = commonFrame;
    
    UMComCommentMenuViewController *recommendListController = [[UMComCommentMenuViewController alloc] init];
    [self addChildViewController:recommendListController];
    recommendListController.view.frame = commonFrame;
    recommendListController.view.center = CGPointMake(commonFrame.size.width * 3 / 2, centerY);
    
    UMComLikeTableViewController *likeListController = [[UMComLikeTableViewController alloc] initWithFetchRequest:[[UMComUserLikesReceivedRequest alloc]initWithCount:BatchSize]];
    [self addChildViewController:likeListController];
    likeListController.view.frame = commonFrame;
    likeListController.view.center = CGPointMake(commonFrame.size.width * 3 / 2, centerY);
    self.titlePageControl.currentPage = 0;
    self.titlePageControl.lastPage = 2;
    [self transitionViews];
}

- (void)transitionViews
{
    [self transitionFromViewControllerAtIndex:self.titlePageControl.lastPage toViewControllerAtIndex:self.titlePageControl.currentPage animations:nil completion:nil];
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
