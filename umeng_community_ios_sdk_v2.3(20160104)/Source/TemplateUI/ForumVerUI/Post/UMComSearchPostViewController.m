//
//  UMComSearchPostViewController.m
//  UMCommunity
//
//  Created by umeng on 15/12/16.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComSearchPostViewController.h"
#import "UMComHorizontalTableView.h"
#import "UMComUsersTableViewController.h"
#import "UMComForumUserCenterViewController.h"
#import "UMComBarButtonItem.h"
#import "UMComShowToast.h"
#import "UMComAction.h"
#import "UIViewController+UMComAddition.h"
#import "UMComFeedDetailViewController.h"
#import "UMComPullRequest.h"
#import "UMComRefreshView.h"
#import "UMComForumUserTableViewController.h"

@interface UMComSearchPostViewController ()<UISearchBarDelegate>

@property (nonatomic, strong) UMComHorizontalTableView *userTableView;

@property (nonatomic, strong) UMComPullRequest *userFetchRequest;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UMComBarButtonItem *rightButtonItem;

@property (nonatomic, strong) UIView *spaceLine;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation UMComSearchPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.backBarButtonItem = nil;
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-160, 30)];
    searchBar.placeholder = UMComLocalizedString(@"Enter user or content key words", @"请输入用户或内容关键字");
    searchBar.backgroundImage = [[UIImage alloc] init];
    searchBar.delegate = self;
    [self.navigationItem setTitleView:searchBar];
    [searchBar becomeFirstResponder];
    self.searchBar = searchBar;

    self.tableView.tableHeaderView = nil;
//    self.tableView.refreshController.headView = nil;
    UMComBarButtonItem *rightButtonItem = [[UMComBarButtonItem alloc] initWithTitle:@"取消" target:self action:@selector(goBack:)];
    rightButtonItem.customButtonView.frame = CGRectMake(10, 0, 40, 30);
    rightButtonItem.customButtonView.titleLabel.font = UMComFontNotoSansLightWithSafeSize(17);
    self.rightButtonItem = rightButtonItem;
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]init];
    spaceItem.width = 5;
    [self.navigationItem setRightBarButtonItems:@[spaceItem,rightButtonItem,spaceItem]];
    self.tableView.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.userTableView) {
        self.tableView.frame = CGRectMake(0,self.tableView.frame.origin.y + self.searchBar.frame.size.height+20, self.view.frame.size.width, self.view.frame.size.height - self.searchBar.frame.size.height);
        self.tableView.tableHeaderView = [self creatHorizonTbaleView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.navigationController.viewControllers.count > 1) {
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.window.frame.size.height - self.navigationController.navigationBar.frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height);
    }else{
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.window.frame.size.height);
    }
}

- (UIView *)creatHorizonTbaleView
{
    self.userTableView = [[UMComHorizontalTableView alloc]initWithFrame:CGRectMake(0, 0, 100, self.view.frame.size.width) style:UITableViewStylePlain];
    self.userTableView.rowHeight = self.userTableView.frame.size.width/4;
    __weak typeof(self) weakSelf = self;
    self.userTableView.didSelectedUser = ^(UMComUser *user){
        UIViewController *tempViewController = nil;
        if (user) {
            tempViewController = [[UMComForumUserCenterViewController alloc] initWithUser:user];
        }else{
            UMComForumUserTableViewController *temSearchAllUserVc = [[UMComForumUserTableViewController alloc]init];
            tempViewController.title = UMComLocalizedString(@"related_user", @"相关用户");
            temSearchAllUserVc.userList = weakSelf.userTableView.userList;
            tempViewController = temSearchAllUserVc;
        }
        [weakSelf.navigationController pushViewController:tempViewController animated:YES];
    };
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
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
}


- (void)searchFeedsWithKeyWord:(NSString *)keyWord
{
    if (keyWord.length > 0) {
        if (!self.fetchRequest) {
            self.fetchRequest = [[UMComSearchFeedRequest alloc]initWithKeywords:keyWord count:BatchSize];
        }else{
            self.fetchRequest.keywords = keyWord;
        }
        [self refreshNewDataFromServer:nil];
    }
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
