//
//  UMComUsersTableView.m
//  UMCommunity
//
//  Created by umeng on 15/7/26.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComUsersTableView.h"
#import "UMComUserTableViewCell.h"
#import "UMComShowToast.h"
#import "UMComRefreshView.h"

@interface UMComUsersTableView ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation UMComUsersTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self registerNib:[UINib nibWithNibName:@"UMComUserTableViewCell" bundle:nil] forCellReuseIdentifier:@"ComUserTableViewCell"];
        self.rowHeight = 60.0f;
        self.noDataTipLabel.text = UMComLocalizedString(@"Tehre is no user", @"暂时没有相关用户咯");
    }
    return self;
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataArray.count > 0) {
        [self.indicatorView stopAnimating];
    }
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"ComUserTableViewCell";
    UMComUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.delegate = self.clickActionDelegate;
    UMComUser *user = self.dataArray[indexPath.row];
    [cell displayWithUser:user];
    return cell;
}

#pragma mark - data handle

//- (void)handleCoreDataDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
//{
//    if (!error && [data isKindOfClass:[NSArray class]]) {
//        [self.dataArray removeAllObjects];
//        [self.dataArray addObjectsFromArray:data];
//    }else if (error){
//        [UMComShowToast showFetchResultTipWithError:error];
//    }
//    if (finishHandler) {
//        finishHandler();
//    }
//}
//
//- (void)handleServerDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
//{
//    if (!error && [data isKindOfClass:[NSArray class]]) {
//        [self.dataArray removeAllObjects];
//        [self.dataArray addObjectsFromArray:data];
//    }else if (error){
//        [UMComShowToast showFetchResultTipWithError:error];
//    }
//    if (finishHandler) {
//        finishHandler();
//    }
//}
//
//- (void)handleLoadMoreDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
//{
//    if (!error && [data isMemberOfClass:[NSArray class]]) {
//        if ([data isKindOfClass:[NSArray class]]) {
//            [self.dataArray addObjectsFromArray:data];
//        }
//    }else if (error){
//        [UMComShowToast showFetchResultTipWithError:error];
//    }
//    if (finishHandler) {
//        finishHandler();
//    }
//}

@end
