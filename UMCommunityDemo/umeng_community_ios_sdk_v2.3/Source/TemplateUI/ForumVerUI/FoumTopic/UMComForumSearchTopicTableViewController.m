//
//  UMComForumRecommedTopicsTableViewController.m
//  UMCommunity
//
//  Created by umeng on 15/12/8.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumSearchTopicTableViewController.h"
#import "UMComSearchBar.h"
#import "UMComTools.h"
#import "UMComNavigationController.h"
#import "UMComPullRequest.h"
#import "UMComBarButtonItem.h"

@interface UMComForumSearchTopicTableViewController ()<UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation UMComForumSearchTopicTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    searchBar.placeholder = UMComLocalizedString(@"Search_topic", @"搜索话题");
    searchBar.delegate = self;
    searchBar.backgroundImage = [[UIImage alloc] init];
    [self.navigationItem setTitleView:searchBar];
    _searchBar = searchBar;
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithPatternImage:UMComImageWithImageName(@"search_frame")];
    self.fetchRequest = [[UMComSearchTopicRequest alloc]initWithKeywords:@""];
    
    UMComBarButtonItem *rightButtonItem = [[UMComBarButtonItem alloc] initWithTitle:@"取消" target:self action:@selector(goBack:)];
    rightButtonItem.customButtonView.frame = CGRectMake(10, 0, 40, 30);
    rightButtonItem.customButtonView.titleLabel.font = UMComFontNotoSansLightWithSafeSize(17);
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]init];
    spaceItem.width = 5;
    [self.navigationItem setRightBarButtonItems:@[spaceItem,rightButtonItem,spaceItem]];
    [_searchBar becomeFirstResponder];
    // Do any additional setup after loading the view.

}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
{
    self.fetchRequest.keywords = searchBar.text;
    [self loadAllData:nil fromServer:nil];
}
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//    self.fetchRequest.keywords = searchBar.text;
//    [self loadAllData:nil fromServer:nil];
//}


- (void)goBack:(id)sender
{
    if (self.dismissBlock) {
        self.dismissBlock();
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
