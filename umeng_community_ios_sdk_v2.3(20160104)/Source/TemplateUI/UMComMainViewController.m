//
//  UMComMainViewController.m
//  UMCommunity
//
//  Created by umeng on 15/11/19.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComMainViewController.h"
#import "UMCommunity.h"
#import "UMComTools.h"

@interface UMComMainViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *labels;

#define labelCount 2

@end

@implementation UMComMainViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat tableHeight = 120;
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height/2-tableHeight, self.view.frame.size.width, tableHeight*2)];
    tableView.rowHeight = tableHeight/2;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    self.labels = [self labels];
    // Do any additional setup after loading the view.
}


- (NSArray *)labels
{
    NSMutableArray *labels = [NSMutableArray array];
    for (int index = 0;  index < labelCount; index ++ ) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 45)];
        label.font = UMComFontNotoSansLightWithSafeSize(18);
        label.backgroundColor = UMComColorWithColorValueString(@"#008BEA");
        label.textColor = UMComColorWithColorValueString(@"#FFFFFF");
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.cornerRadius = 5;
        label.clipsToBounds = YES;
        [labels addObject:label];
    }
    return labels;
}


- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.labels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    UILabel *label = self.labels[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        if (label.superview != cell.contentView) {
            [cell.contentView addSubview:label];
        }
        label.text = @"微博页面";
    }else{
        if (label.superview != cell.contentView) {
            [cell.contentView addSubview:label];
        }
        label.text = @"论坛页面";
    }
    label.center = CGPointMake(tableView.frame.size.width/2, tableView.rowHeight/2);
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UIViewController *communityController = [UMCommunity getFeedsViewController];
        [self.navigationController pushViewController:communityController animated:YES];
    }else{
        UIViewController *communityController = [UMCommunity getForumViewController];
        [self.navigationController pushViewController:communityController animated:YES];
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
