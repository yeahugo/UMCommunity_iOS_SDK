//
//  UMComUserCenterTableDelegate.m
//  UMCommunity
//
//  Created by luyiyuan on 14/10/14.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComUserCenterTableDelegate.h"
#import "UMComFeedsTableViewCell.h"
#import "UMComUsersTableCell.h"
#import "UMComFeed.h"
#import "UMComUsersTableCellOne.h"
#import "UMUtils.h"

@interface UMComUserCenterTableDelegate ()

@property (nonatomic, strong) NSArray *resultArray;
@property (nonatomic) UMComUserCenterDataType curDataType;
@property (nonatomic, weak) UIViewController *viewController;

@end

@implementation UMComUserCenterTableDelegate

- (id)initWithViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        self.viewController = viewController;
    }
    return self;
}

- (void)setDataWithType:(UMComUserCenterDataType)dataType dataArray:(NSArray *)dataArrat
{
    self.curDataType = dataType;
    self.resultArray = dataArrat;
    
}

- (void)registerTableViewCell:(UITableView *)tableView dataType:(UMComUserCenterDataType)dataType
{
    if(self.curDataType==UMComUserCenterDataFeeds)
    {
        [tableView registerNib:[UINib nibWithNibName:@"UMComFeedsTableViewCell" bundle:nil] forCellReuseIdentifier:@"FeedsTableViewCell"];
    }
    else if(self.curDataType==UMComUserCenterDataFollow
            ||self.curDataType==UMComUserCenterDataFans)
    {
        [tableView registerClass:[UMComUsersTableCell class] forCellReuseIdentifier:@"UsersTableViewCell"];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.curDataType==UMComUserCenterDataFollow
       ||self.curDataType==UMComUserCenterDataFans)
    {
        return [UMComUsersTableCell getGridTableLineNumber:self.resultArray.count countOfOneLine:[UMComUsersTableCell countOfOneLine]];
    }else{
        return self.resultArray.count;
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    if(self.curDataType==UMComUserCenterDataFollow
            ||self.curDataType==UMComUserCenterDataFans)
    {
        return [UMComUsersTableCell staticHeight];
    }
    
    return 0.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if(self.curDataType==UMComUserCenterDataFollow
            ||self.curDataType==UMComUserCenterDataFans)
    {
        static NSString * cellIdentifier = @"UsersTableViewCell";
        
        UMComUsersTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(!cell){
            cell = [[UMComUsersTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell registerCellClasser:[UMComUsersTableCell class] CellOneViewClasser:[UMComUsersTableCellOne class]];
        cell.viewController = self.viewController;

        NSRange range = [UMComUsersTableCell getGridTableRangeForIndex:indexPath.row allCount:[self.resultArray count]countOfOneLine:[UMComUsersTableCell countOfOneLine]];
        [cell reloadWithDataArray:[self.resultArray subarrayWithRange:range]];
        
        return cell;
    }
    else
    {
        UMLog(@"error,dataType[%d]",self.curDataType);
    }
    
    return nil;
}



//数据为空时，分割线为空
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    // This will create a "invisible" footer
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

@end
