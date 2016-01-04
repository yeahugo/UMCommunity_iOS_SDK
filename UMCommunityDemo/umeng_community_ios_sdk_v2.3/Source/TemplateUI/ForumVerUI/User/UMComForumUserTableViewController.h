//
//  UMComForumUserTableViewController.h
//  UMCommunity
//
//  Created by umeng on 15/11/27.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComRequestTableViewController.h"

@class UMComUser;

@interface UMComForumUserTableViewController : UMComRequestTableViewController

@property (nonatomic, strong) NSArray *userList;

@property (nonatomic, copy) void (^focusedUserFinish)();

- (void)insertUserToTableView:(UMComUser *)user;

- (void)deleteUserFromTableView:(UMComUser *)user;


@end
