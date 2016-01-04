//
//  UMComForumTopicTableViewController.h
//  UMCommunity
//
//  Created by umeng on 15/11/26.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComRequestTableViewController.h"

@class UMComForumTopicTableViewCell;
@interface UMComForumTopicTableViewController : UMComRequestTableViewController

- (UITableViewCell *)cellForIndexPath:(NSIndexPath *)indexPath;

- (void)showTopicPostTableViewWithTopicAtIndexPath:(NSIndexPath *)indexPath;


@end
