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

@interface UMComAllFeedViewController ()

@end

@implementation UMComAllFeedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self getFetchedResultsController];

    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clearAndRefreshAllData) name:UserLoginSecceed object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clearAndRefreshAllData) name:UserLogoutSucceed object:nil];
    
    [self.feedsTableView setFeedTableViewController:self];
    UIBarButtonItem *leftButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"Backx" target:self action:@selector(onClickClose:)];

    [self.navigationItem setLeftBarButtonItems:@[leftButtonItem]];
    UIBarButtonItem *topicButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"topic" target:self action:@selector(onClickTopic:)];
    UIBarButtonItem *selfButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"profile" target:self action:@selector(onClickProfile:)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = 20;
    [self.navigationItem setRightBarButtonItems:@[selfButtonItem,space,topicButtonItem]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeFont:UMComFontNotoSansDemiWithSafeSize(18)}];
    [self.navigationItem setTitle:UMComLocalizedString(@"Community", @"社区")];

    [self.editButton addTarget:self action:@selector(onClickEdit:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)getFetchedResultsController
{
    UMComAllFeedsRequest *fetchedResultsController = [[UMComAllFeedsRequest alloc] initWithCount:BatchSize];
    self.fetchFeedsController = fetchedResultsController;
}

- (void)clearAndRefreshAllData
{
    [self getFetchedResultsController];
    [self refreshAllData];
}

-(IBAction)onClickClose:(id)sender
{
    [UIView setAnimationsEnabled:YES]; 
    if ([self.navigationController isKindOfClass:[UMComNavigationController class]]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [(UMComFeedsTableView *)self.feedsTableView dismissAllEditView];
}

-(IBAction)onClickProfile:(id)sender
{
    [[UMComUserCenterAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
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
