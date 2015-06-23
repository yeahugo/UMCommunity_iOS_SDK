//
//  UMComActionStyleTableView.h
//  UMCommunity
//
//  Created by umeng on 15/5/27.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComClickActionDelegate.h"

@class UMComFeed;
@interface UMComActionStyleTableView : UITableView

@property (nonatomic, strong) UMComFeed *feed;

@property (nonatomic, copy) void (^didSelectedAtIndexPath)(UMComActionStyleTableView *actionStyleView, NSIndexPath *indexPath);
- (void)setImageNameList:(NSArray *)imageNameList titles:(NSArray *)titles;
@end
