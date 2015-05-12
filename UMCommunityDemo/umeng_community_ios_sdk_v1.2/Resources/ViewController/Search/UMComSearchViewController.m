//
//  UMComSearchViewController.m
//  UMCommunity
//
//  Created by umeng on 15-4-22.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComSearchViewController.h"
#import "UMComHorizontalTableView.h"
#import "UMComAllFeedViewController.h"
#import "UMComUserRecommendViewController.h"
#import "UMComUserCenterViewController.h"
#import "UMComBarButtonItem.h"


@interface UMComSearchViewController ()<UISearchBarDelegate>

@property (nonatomic, strong) UMComAllFeedViewController *allSearchFeedViewController;
@property (nonatomic, strong) UMComHorizontalTableView *userTableView;
@property (nonatomic, strong) UMComPullRequest *userFetchRequest;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UMComBarButtonItem *rightButtonItem;

@property (nonatomic, strong) UIView *spaceLine;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation UMComSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-160, 30)];
    searchBar.placeholder = UMComLocalizedString(@"Enter user or content key words", @"请输入用户或内容关键字");
    searchBar.backgroundImage = [[UIImage alloc] init];
    searchBar.delegate = self;
    [self.navigationItem setTitleView:searchBar];
    [searchBar becomeFirstResponder];
    self.searchBar = searchBar;
    
    UMComBarButtonItem *rightButtonItem = [[UMComBarButtonItem alloc] initWithTitle:@"取消" target:self action:@selector(goBack:)];
    rightButtonItem.customButtonView.frame = CGRectMake(10, 0, 40, 30);
    rightButtonItem.customButtonView.titleLabel.font = UMComFontNotoSansLightWithSafeSize(17);
    self.rightButtonItem = rightButtonItem;
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]init];
    spaceItem.width = 5;
    [self.navigationItem setRightBarButtonItems:@[spaceItem,rightButtonItem,spaceItem]];

    
    self.allSearchFeedViewController = [[UMComAllFeedViewController alloc]init];
    [self.view addSubview:self.allSearchFeedViewController.view];
    [self.allSearchFeedViewController.indicatorView stopAnimating];
    [self addChildViewController:self.allSearchFeedViewController];
    [self.allSearchFeedViewController.feedsTableView.indicatorView removeFromSuperview];
    self.allSearchFeedViewController.feedsTableView.scrollViewDidScroll = ^(UIScrollView *scrollView, CGFloat lastPosition){
        [searchBar resignFirstResponder];
    };

    UISwipeGestureRecognizer *leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(noAction)];
    leftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftGestureRecognizer];
    
    UISwipeGestureRecognizer *rightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(noAction)];
    rightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightGestureRecognizer];
}

- (void)noAction
{
}




- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.allSearchFeedViewController.view sizeToFit];
    self.allSearchFeedViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, [UIApplication sharedApplication].keyWindow.bounds.size.height-self.navigationController.navigationBar.frame.size.height-20);
    if (!self.userTableView) {
        self.allSearchFeedViewController.feedsTableView.tableHeaderView = [self creatHorizonTbaleView];
    }
    
}
- (UIView *)creatHorizonTbaleView
{
    self.userTableView = [[UMComHorizontalTableView alloc]initWithFrame:CGRectMake(0, 0, 100, self.view.frame.size.width) style:UITableViewStylePlain];
    self.userTableView.rowHeight = self.userTableView.frame.size.width/4;
    __weak UMComSearchViewController *weakSelf = self;
    self.userTableView.didSelectedUser = ^(UMComUser *user){
        UIViewController *tempViewController = nil;
        if (user) {
            tempViewController = [[UMComUserCenterViewController alloc] initWithUser:user];
        }else{
            UMComUserRecommendViewController *temSearchAllUserVc = [[UMComUserRecommendViewController alloc]init];
            tempViewController.title = UMComLocalizedString(@"related_user", @"相关用户");
            temSearchAllUserVc.userDataSourceType = UMComSearchUser;
            temSearchAllUserVc.recommendUserList = weakSelf.userTableView.userList;
            tempViewController = temSearchAllUserVc;
        }
        [weakSelf.navigationController pushViewController:tempViewController animated:YES];
    };
    UIView *tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    tableHeaderView.backgroundColor = [UIColor clearColor];
    [tableHeaderView addSubview:self.userTableView];
    self.userTableView.center = CGPointMake(tableHeaderView.frame.size.width/2, tableHeaderView.frame.size.height/2);

    UIView *spaceView = [[UIView alloc]initWithFrame:CGRectMake(0, 100-10, self.view.frame.size.width, 0.3)];
    spaceView.backgroundColor = TableViewSeparatorRGBColor;
    spaceView.hidden = YES;
    self.spaceLine = spaceView;
    [tableHeaderView addSubview:spaceView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, 95, 60, 12)];
    label.backgroundColor = [UIColor clearColor];
    label.text = UMComLocalizedString(@"related_feed", @"相关消息");
    label.textColor = [UMComTools colorWithHexString:FontColorGray];
    label.font = UMComFontNotoSansLightWithSafeSize(12);
    [tableHeaderView addSubview:label];
    label.hidden = YES;
    self.titleLabel = label;
    return tableHeaderView;
}


- (void)goBack:(id)sender
{
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}

#pragma mark - searchBarDelelagte
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
{
    [searchBar resignFirstResponder];
    self.titleLabel.hidden = YES;
    [self.userTableView searchUsersWithKeyWord:searchBar.text];
    [self searchFeedsWithKeyWord:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.titleLabel.hidden = YES;
    if (searchBar.text.length == 0) {
        self.allSearchFeedViewController.indicatorView.hidden = YES;
        [self.searchBar resignFirstResponder];
        self.allSearchFeedViewController.fetchFeedsController = nil;
    }
}




- (void)searchFeedsWithKeyWord:(NSString *)keyWord
{
    self.titleLabel.hidden = YES;
    self.allSearchFeedViewController.fetchFeedsController = [[UMComSearchFeedRequest alloc]initWithKeywords:keyWord count:BatchSize];
    __weak UMComSearchViewController *weakSelf = self;
    self.allSearchFeedViewController.feedsTableView.loadDataFinishBlock = ^(NSArray *data, NSError *error){
        if (error) {
            weakSelf.titleLabel.hidden = YES;
        }else{
            if (data.count == 0) {
                weakSelf.titleLabel.hidden = YES;
            }else{
                weakSelf.titleLabel.hidden = NO;
            }
        }
        weakSelf.spaceLine.hidden = NO;
    };
    [self.allSearchFeedViewController.feedsTableView refreshFeedsData];
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
