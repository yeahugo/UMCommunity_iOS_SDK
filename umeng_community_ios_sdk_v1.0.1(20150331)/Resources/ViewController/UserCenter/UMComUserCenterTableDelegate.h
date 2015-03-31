//
//  UMComUserCenterTableDelegate.h
//  UMCommunity
//
//  Created by luyiyuan on 14/10/14.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMComUserCenterViewModel.h"

@interface UMComUserCenterTableDelegate : NSObject<UITableViewDelegate,UITableViewDataSource>

- (id)initWithViewController:(UIViewController *)viewController;

- (void)setDataWithType:(UMComUserCenterDataType)dataType dataArray:(NSArray *)dataArrat;

- (void)registerTableViewCell:(UITableView *)tableView dataType:(UMComUserCenterDataType)dataType;
@end
