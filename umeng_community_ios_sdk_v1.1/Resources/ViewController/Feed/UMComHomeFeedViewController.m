//
//  UMComHomeFeedViewController.m
//  UMCommunity
//
//  Created by umeng on 15-4-2.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComHomeFeedViewController.h"
#import "UMComAllFeedViewController.h"
#import "UMComNavigationController.h"
#import "UMComBarButtonItem.h"
#import "UMComFeedsTableView.h"
#import "UMComAction.h"

#define kTagRecommend 100
#define kTagAll 101

@interface UMComHomeFeedViewController ()

@property (nonatomic,strong) UMComAllFeedViewController *currentViewController;

@property (nonatomic, strong) UIButton *titleButton;

@property (nonatomic, strong) UMComFeedsTableView *tempfeedTableView;

@property (nonatomic, strong) UMComAllFeedViewController *allFeedViewController;
@property (nonatomic, strong) UMComAllFeedViewController *recommendViewController;

@property (nonatomic, strong) UIButton *editButton;


@property (nonatomic, strong) UIButton *titleBt;
@property (nonatomic, strong) UIPageControl *titlePageControl;

@end

@implementation UMComHomeFeedViewController
{
    CGSize selfViewSize;
    BOOL  didTransition;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    didTransition = YES;
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    UIBarButtonItem *topicButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"topic" target:self action:@selector(onClickTopic:)];
    UIBarButtonItem *selfButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"find" target:self action:@selector(onClickFind:)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = 20;
    UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    rightSpace.width = 5;
    [self.navigationItem setRightBarButtonItems:@[rightSpace,selfButtonItem,space,topicButtonItem]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeFont:UMComFontNotoSansDemiWithSafeSize(18)}];
    
    //创建控件
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, self.navigationController.navigationBar.frame.size.height)];
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    titleButton.frame =CGRectMake(0, 5, titleView.frame.size.width, titleView.frame.size.height/2);
    [titleButton setTitle:@"全部" forState:UIControlStateNormal];
    titleButton.backgroundColor = [UIColor clearColor];
    [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [titleButton addTarget:self action:@selector(transitionViewControllers:) forControlEvents:UIControlEventTouchUpInside];
    self.titleBt = titleButton;
    
    UIPageControl *titlePageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, titleView.frame.size.height/2, titleView.frame.size.width, titleView.frame.size.height/2)];
    titlePageControl.currentPage = 1;
    titlePageControl.numberOfPages = 2;
    titlePageControl.pageIndicatorTintColor = [UMComTools colorWithHexString:FontColorGray];
    [titlePageControl addTarget:self action:@selector(transitionViewControllers:) forControlEvents:UIControlEventValueChanged];
      titlePageControl.currentPageIndicatorTintColor = [UMComTools colorWithHexString:FontColorBlue];
    [titleView addSubview:titleButton];
    [titleView addSubview:titlePageControl];
    self.titlePageControl = titlePageControl;
    [self.navigationItem setTitleView:titleView];
    
    
    UISwipeGestureRecognizer *leftWwip = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(transitionViewControllers:)];
    leftWwip.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftWwip];
    
    UISwipeGestureRecognizer *rightSwip = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(transitionViewControllers:)];
    rightSwip.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwip];
    
    
    //创建子ViewController
    self.allFeedViewController = [[UMComAllFeedViewController alloc]init];
    self.allFeedViewController.fetchFeedsController = [[UMComAllFeedsRequest alloc]initWithCount:BatchSize];
    [self.view addSubview:self.allFeedViewController.view];
    [self addChildViewController:self.allFeedViewController];
    
    self.recommendViewController = [[UMComAllFeedViewController alloc]init];
    self.recommendViewController.fetchFeedsController = [[UMComRecommendFeedsRequest alloc]initWithCount:BatchSize];
    [self.view addSubview:self.recommendViewController.view];
    [self addChildViewController:self.recommendViewController];
    
    if(self.navigationController.viewControllers.count > 1 || self.presentingViewController){
        [self.allFeedViewController.feedsTableView setViewController:self];
        [self.recommendViewController.feedsTableView setViewController:self];
        UIBarButtonItem *leftButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"Backx" target:self action:@selector(onClickClose:)];
        [self.navigationItem setLeftBarButtonItems:@[leftButtonItem]];
    }
    self.tempfeedTableView = self.allFeedViewController.feedsTableView;
    self.currentViewController = self.recommendViewController;
    
    //是否显示返回按钮
    if(self.navigationController.viewControllers.count > 1 || self.presentingViewController){
        UIBarButtonItem *leftButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"Backx" target:self action:@selector(onClickClose:)];
        [self.navigationItem setLeftBarButtonItems:@[leftButtonItem]];
    }
    
    self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.editButton.frame = CGRectMake(0, 0, 50, 50);
    [self.editButton setImage:[UIImage imageNamed:@"new"] forState:UIControlStateNormal];
    [self.editButton setImage:[UIImage imageNamed:@"new+"] forState:UIControlStateSelected];
    [self.editButton addTarget:self action:@selector(onClickEdit:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    selfViewSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    if (self.titlePageControl.currentPage == 0) {
        self.titlePageControl.currentPage = 1;
    }else{
        self.titlePageControl.currentPage = 0;
    }
    [self transitionViewControllers:nil];
    self.editButton.frame = CGRectMake(selfViewSize.width-70, selfViewSize.height-self.navigationController.navigationBar.frame.size.height, 50, 50);
    [[UIApplication sharedApplication].keyWindow addSubview:self.editButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.editButton removeFromSuperview];
}

- (void)transitionViewControllers:(id)sender
{
    if (!didTransition) {
        return;
    }
    
    UMComAllFeedViewController *tempFromViewController = nil;
    CGRect disappearFrame;
    
    if ([sender isKindOfClass:[UISwipeGestureRecognizer class]]) {
        UISwipeGestureRecognizer *swip = (UISwipeGestureRecognizer *)sender;
        if (swip.direction == UISwipeGestureRecognizerDirectionRight) {
            
            tempFromViewController = self.recommendViewController;
            self.currentViewController = self.allFeedViewController;
            
            disappearFrame = CGRectMake(selfViewSize.width, 0, selfViewSize.width, selfViewSize.height);
        }else{
            tempFromViewController = self.allFeedViewController;
            self.currentViewController = self.recommendViewController;
            disappearFrame = CGRectMake(-selfViewSize.width, 0, selfViewSize.width, selfViewSize.height);
        }
    }else{
        if (self.titlePageControl.currentPage == 0) {
            tempFromViewController = self.allFeedViewController;
            self.currentViewController = self.recommendViewController;
            disappearFrame = CGRectMake(-selfViewSize.width, 0, selfViewSize.width, selfViewSize.height);
            
        }else if (self.titlePageControl.currentPage == 1){
            
            tempFromViewController = self.recommendViewController;
            self.currentViewController = self.allFeedViewController;
            disappearFrame = CGRectMake(selfViewSize.width, 0, selfViewSize.width, selfViewSize.height);
        }else{
            return;
        }
    }
    
    [self transitionWithFromViewController:tempFromViewController disAppearViewFrame:disappearFrame];
}


- (void)transitionWithFromViewController:(UMComAllFeedViewController *)fromViewController disAppearViewFrame:(CGRect)disappearFrame
{
//    [UIView setAnimationsEnabled:YES];
    [self transitionFromViewController:fromViewController toViewController:self.currentViewController duration:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
        didTransition = NO;
        if (fromViewController == self.currentViewController) {
            return;
        }
        fromViewController.view.frame = disappearFrame;
        self.currentViewController.view.frame = CGRectMake(0, 0, selfViewSize.width, selfViewSize.height);
        if (self.currentViewController == self.allFeedViewController) {
            [self.titleBt setTitle:@"全部" forState:UIControlStateNormal];
            self.titlePageControl.currentPage = 0;
        }else if(self.currentViewController == self.recommendViewController){
            [self.titleBt setTitle:@"推荐" forState:UIControlStateNormal];
            self.titlePageControl.currentPage = 1;
        }else{
            self.titlePageControl.currentPage = 2;
        }
        self.tempfeedTableView = fromViewController.feedsTableView;
    } completion:^(BOOL finished) {
        self.currentViewController = fromViewController;
        didTransition = YES;
    }];

}

-(IBAction)onClickClose:(id)sender
{
//    [UIView setAnimationsEnabled:YES];
    if ([self.navigationController isKindOfClass:[UMComNavigationController class]]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self.tempfeedTableView dismissAllEditView];
}

-(IBAction)onClickProfile:(id)sender
{
    
    [[UMComUserCenterAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
    }];
}
- (void)onClickFind:(UIButton *)sender
{
    [[UMComFindAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
    }];
}

-(IBAction)onClickTopic:(id)sender
{
    [[UMComTopicFilterAction action] performActionAfterLogin:nil viewController:self completion:nil];
}

-(IBAction)onClickEdit:(id)sender
{
    [[UMComEditAction action] performActionAfterLogin:nil viewController:self completion:nil];
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
