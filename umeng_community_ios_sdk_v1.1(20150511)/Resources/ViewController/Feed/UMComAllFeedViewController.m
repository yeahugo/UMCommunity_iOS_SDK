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
}


- (void)getFetchedResultsController
{
    if (![self.fetchFeedsController isKindOfClass:[UMComSearchFeedRequest class]]) {
        self.fetchFeedsController =  [[[self.fetchFeedsController class] alloc] initWithCount:BatchSize];
    }
}

- (void)clearAndRefreshAllData
{
    [self getFetchedResultsController];
    [self refreshAllData];
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
