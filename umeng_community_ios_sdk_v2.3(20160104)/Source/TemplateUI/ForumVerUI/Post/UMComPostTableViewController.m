//
//  UMComPostViewController.m
//  UMCommunity
//
//  Created by umeng on 15/11/17.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComPostTableViewController.h"
#import "UMComFeed.h"
#import "UMComFeed+UMComManagedObject.h"

#import "UMComPostTableViewCell.h"
#import "UMComPostContentViewController.h"
#import "UMComTools.h"

@interface UMComPostTableViewController ()
<UMComPostContentViewControllerDelegate>

@end

@implementation UMComPostTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = UMComRGBColor(245, 246, 250);
    [self.tableView registerClass:[UMComPostTableViewCell class] forCellReuseIdentifier:UMComPostTableViewCellIdentifier];
    self.tableView.rowHeight = [UMComPostTableViewCell cellHeightForPlainStyle];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UMComPostTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:UMComPostTableViewCellIdentifier forIndexPath:indexPath];
    
    UMComFeed *feed = self.dataArray[indexPath.row];
    cell.postFeed = feed;
    
    cell.showTopMark = (_showTopMark && [feed.is_top boolValue]);
    cell.touchOnImage = ^(UMComGridViewerController *viewerController, UIImageView *imageView) {
        [self presentViewController:(UIViewController *)viewerController animated:YES completion:nil];
    };
    [cell refreshLayout];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UMComFeed *feed = self.dataArray[indexPath.row];
    CGFloat cellHeight = 0;
    if (feed.image_urls.count > 0) {
        cellHeight = [UMComPostTableViewCell cellHeightForImageStyle];
    }else{
        cellHeight = [UMComPostTableViewCell cellHeightForPlainStyle];
    }
    return cellHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UMComFeed *feed = self.dataArray[indexPath.row];
    UMComPostContentViewController *controller = [[UMComPostContentViewController alloc] initWithFeed:feed];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)inserNewFeedInTabelView:(UMComFeed *)newFeed
{
    if (![newFeed isKindOfClass:[UMComFeed class]]) {
        return;
    }
    if (self.dataArray.count > 0) {
       NSMutableArray *array = [NSMutableArray arrayWithArray:self.dataArray];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UMComFeed *feed = obj;
            if (![feed.is_top boolValue]) {
                *stop = YES;
                [array insertObject:newFeed atIndex:idx];
                self.dataArray = array;
                [self.tableView reloadData];
            }
        }];
    }else{
        self.dataArray = @[newFeed];
        [self.tableView reloadData];
    }
}

- (void)deleteNewFeedInTabelView:(UMComFeed *)deleteFeed
{
    if (![deleteFeed isKindOfClass:[UMComFeed class]] || self.dataArray.count == 0) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.dataArray];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UMComFeed *feed = obj;
        if ([feed.feedID isEqualToString:deleteFeed.feedID]) {
            *stop = YES;
            [array removeObject:feed];
            weakSelf.dataArray = array;
            [weakSelf.tableView reloadData];
        }
    }];
}


#pragma mark - delegate
- (void)viewController:(UMComPostContentViewController *)viewController action:(UMComPostContentViewActionType)type object:(id)object
{
    if (type == UMPostContentViewActionDelete) {
        UMComFeed *feed = [object isKindOfClass:[UMComFeed class]] ? object : nil;
        [self deleteNewFeedInTabelView:feed];
    } else if (type == UMPostContentViewActionUpdateCount) {
        [self.tableView reloadData];
    }
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
