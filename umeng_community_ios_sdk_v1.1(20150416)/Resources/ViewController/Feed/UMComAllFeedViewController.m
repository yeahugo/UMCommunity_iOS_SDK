//
//  UMComAllFeedViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 10/22/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComAllFeedViewController.h"
#import "UMComBarButtonItem.h"
#import "UMComSession.h"
#import "UMComFeedsTableView.h"
#import "UMComAction.h"
#import "UMComNavigationController.h"
#import "UMComLoginManager.h"

#define kTagRecommend 100
#define kTagAll 101

@interface UMComAllFeedViewController ()

@property (nonatomic, strong) UIButton *titleButton;


@end

@implementation UMComAllFeedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.editButton.hidden = YES;
    if (self.feedsTableView.resultArray.count == 0) {
        [self refreshAllData];
    }else{
        [self.feedsTableView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UserLogoutSucceed object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UserLoginSecceed object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clearAndRefreshAllData) name:UserLoginSecceed object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clearAndRefreshAllData) name:UserLogoutSucceed object:nil];
    
//    if(self.navigationController.viewControllers.count > 1 || self.presentingViewController){
//        [self.feedsTableView setFeedTableViewController:self];
//        UIBarButtonItem *leftButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"Backx" target:self action:@selector(onClickClose:)];
//        [self.navigationItem setLeftBarButtonItems:@[leftButtonItem]];    
//    }
}

- (void)getFetchedResultsController
{
    self.fetchFeedsController =  [[[self.fetchFeedsController class] alloc] initWithCount:BatchSize];
}

- (void)clearAndRefreshAllData
{
    [self getFetchedResultsController];
    [self refreshAllData];
}
//
//-(IBAction)onClickClose:(id)sender
//{
////    [UIView setAnimationsEnabled:YES]; 
//    if ([self.navigationController isKindOfClass:[UMComNavigationController class]]) {
//        [self dismissViewControllerAnimated:YES completion:nil];
//    } else {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//    [(UMComFeedsTableView *)self.feedsTableView dismissAllEditView];
//}
//
//-(IBAction)onClickProfile:(id)sender
//{
//    [[UMComUserCenterAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
//    }];
//}
//
//- (void)onClickFind:(UIButton *)sender
//{
//    [[UMComFindAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
//    }];
//}
//
//-(IBAction)onClickTopic:(id)sender
//{
//    [[UMComTopicFilterAction action] performActionAfterLogin:nil viewController:self completion:nil];
//}
//
//-(IBAction)onClickEdit:(id)sender
//{
//    [[UMComEditAction action] performActionAfterLogin:nil viewController:self completion:nil];
//}


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
