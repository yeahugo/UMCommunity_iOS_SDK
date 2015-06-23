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

//- (void)registerTableViewCell:(UITableView *)tableView dataType:(UMComUserCenterDataType)dataType
//{
//    if(self.curDataType==UMComUserCenterDataFeeds)
//    {
//        [tableView registerNib:[UINib nibWithNibName:@"UMComFeedsTableViewCell" bundle:nil] forCellReuseIdentifier:@"FeedsTableViewCell"];
//    }
//    else if(self.curDataType==UMComUserCenterDataFollow
//            ||self.curDataType==UMComUserCenterDataFans)
//    {
//        [tableView registerClass:[UMComUsersTableCell class] forCellReuseIdentifier:@"UsersTableViewCell"];
//    }
//}


@end
