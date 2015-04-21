//
//  UMComUserRecommendViewController.m
//  UMCommunity
//
//  Created by umeng on 15-3-31.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComUserRecommendViewController.h"
#import "UMComUserRecommendCell.h"
#import "UMComUser.h"
#import "UMComAction.h"
#import "UMComBarButtonItem.h"
#import "UMComShowToast.h"

@interface UMComUserRecommendViewController ()

@property (nonatomic, strong) NSArray *recommendUserList;

@property (nonatomic, strong) UMComPullRequest *fetchRequest;

@property (nonatomic, strong) UILabel *noRecommendTip;

@end

@implementation UMComUserRecommendViewController

- (id)initWithCompletion:(LoadDataCompletion)completion
{
    if (self) {
        self.completion = completion;
        
        UMComBarButtonItem *rightButtonItem = [[UMComBarButtonItem alloc] initWithTitle:UMComLocalizedString(@"FinishStep",@"完成") target:self action:@selector(onClickNext)];
        [self.navigationItem setRightBarButtonItem:rightButtonItem];

    }
    return self;
}

- (void)onClickNext
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.completion) {
            self.completion(nil,nil);
        }        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = UMComLocalizedString(@"User_Recommend", @"用户推荐");
    [self.tableView registerNib:[UINib nibWithNibName:@"UMComUserRecommendCell" bundle:nil] forCellReuseIdentifier:@"UserRecommendCell"];
    self.tableView.rowHeight = 60.0f;

    self.recommendUserList = [NSMutableArray arrayWithCapacity:1];
    if (!self.topicId) {
        self.fetchRequest = [[UMComRecommendUsersRequest alloc]initWithCount:BatchSize];
    }else{
        self.fetchRequest = [[UMComRecommendTopicUsersRequest alloc]initWithTopicId:self.topicId count:BatchSize];
    }
    [self requestRecommendUsers];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.recommendUserList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"UserRecommendCell";
    UMComUserRecommendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];

    UMComUser *user = self.recommendUserList[indexPath.row];
    if (self.topicId) {
        [cell displayWithUser:user isHotUser:YES];
     
    }else{
        [cell displayWithUser:user isHotUser:NO];
    }
    __weak UMComUserRecommendViewController *weakSelf = self;
    cell.onClickAtCellViewAction = ^(UMComUser *user){
        [weakSelf didSelectUser:user];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UMComUser *user = self.recommendUserList[indexPath.row];
    UIViewController *paramViewController = self;
    if (self.viewController) {
        paramViewController = self.viewController;
    }
    [[UMComUserCenterAction action] performActionAfterLogin:user viewController:paramViewController completion:nil];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y < -65) {
        [self requestRecommendUsers];
    }
}

#pragma mark - private method
- (void)didSelectUser:(UMComUser *)user
{
    UIViewController *paramViewController = self;
    if (self.viewController) {
        paramViewController = self.viewController;
    }
    [[UMComUserCenterAction action] performActionAfterLogin:user viewController:paramViewController completion:nil];
}


- (void)requestRecommendUsers
{
    [self.fetchRequest fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        self.noRecommendTip.hidden = YES;
        self.recommendUserList = data;
        if (error) {
            self.noRecommendTip.hidden = YES;
            [UMComShowToast fetchRecommendUserFail:error];
        }else{
            if (self.recommendUserList.count == 0) {
                if (self.noRecommendTip == nil) {
                    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height/2-80, self.view.frame.size.width, 40)];
                    label.backgroundColor = [UIColor clearColor];
                    label.text = UMComLocalizedString(@"Tehre is no recommend user", @"暂时没有推荐用户咯");
                    label.textAlignment = NSTextAlignmentCenter;
                    [self.tableView addSubview:label];
                    self.noRecommendTip = label;
                } else {
                    self.noRecommendTip.hidden = NO;
                }
            }else{
                if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
                    self.footView.backgroundColor = TableViewSeparatorRGBColor;
                }
                self.noRecommendTip.hidden = YES;
            }
        }
        [self.tableView reloadData];
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
