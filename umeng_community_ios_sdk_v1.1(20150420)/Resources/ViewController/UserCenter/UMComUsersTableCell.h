//
//  UMComUsersTableCell.h
//  UMCommunity
//
//  Created by luyiyuan on 14/10/16.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComGridTableViewCell.h"
#import "UMComUser.h"

@interface UMComUsersTableCell : UMComGridTableViewCell

@property (nonatomic, weak) UIViewController * viewController;
//- (void)reloadUser:(UMComUser *)user tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
@end
