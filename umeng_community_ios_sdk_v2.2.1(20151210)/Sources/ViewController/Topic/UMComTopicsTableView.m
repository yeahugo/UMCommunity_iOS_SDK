//
//  UMComTopicsTableView.m
//  UMCommunity
//
//  Created by umeng on 15/7/28.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComTopicsTableView.h"
#import "UMComTools.h"
#import "UMComFilterTopicsViewCell.h"
#import "UMComPullRequest.h"
#import "UMComShowToast.h"
#import "UMComRefreshView.h"
#import "UMComClickActionDelegate.h"
#import "UMComScrollViewDelegate.h"


@interface UMComTopicsTableView () <UITableViewDelegate, UITableViewDataSource, UMComRefreshViewDelegate>

@end

@implementation UMComTopicsTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.rowHeight = 62;
        [self registerNib:[UINib nibWithNibName:@"UMComFilterTopicsViewCell" bundle:nil] forCellReuseIdentifier:@"FilterTopicsViewCell"];
        self.noDataTipLabel.text = UMComLocalizedString(@"no topics",@"暂无相关话题");
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"FilterTopicsViewCell";
    UMComFilterTopicsViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell == nil) {
        cell = [[UMComFilterTopicsViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.delegate = self.clickActionDelegate;
    
    UMComTopic *topic = [self.dataArray objectAtIndex:indexPath.row];
    [cell setWithTopic:topic];
    __weak typeof(self) weakSelf = self;
    __weak typeof(UMComFilterTopicsViewCell) *weakCell = cell;
    cell.clickOnTopic = ^(UMComTopic *topic){
        if (weakSelf.clickActionDelegate  && [self.clickActionDelegate respondsToSelector:@selector(customObj:clickOnTopic:)]) {
            __strong typeof(weakCell) strongCell = weakCell;
            [self.clickActionDelegate customObj:strongCell clickOnTopic:topic];
        }
    };
    return cell;
}

//#pragma requestDataMethod
//
//- (void)handleCoreDataDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
//{
//    if ([data isKindOfClass:[NSArray class]] &&  data.count > 0) {
//        [self.dataArray removeAllObjects];
//        [self.dataArray addObjectsFromArray:data];
//    }
//    if (finishHandler) {
//        finishHandler();
//    }
//}
//
//- (void)handleServerDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
//{
//    if ([data isKindOfClass:[NSArray class]] &&  data.count > 0) {
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
//    if (!error && [data isKindOfClass:[NSArray class]]) {
//        [self.dataArray addObjectsFromArray:data];
//    }else if (error){
//        [UMComShowToast showFetchResultTipWithError:error];
//    }
//    if (finishHandler) {
//        finishHandler();
//    }
//}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
