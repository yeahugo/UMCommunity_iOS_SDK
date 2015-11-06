//
//  UMComActionStyleTableView.h
//  UMCommunity
//
//  Created by umeng on 15/5/27.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UMComFeed;

@protocol UMComClickActionDelegate;

@interface UMComActionStyleTableView : UITableView

@property (nonatomic, strong) UMComFeed *feed;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, copy) void (^didSelectedAtIndexPath)(NSString *title, NSIndexPath *indexPath);

@property (nonatomic, strong) NSString *selectedTitle;

- (void)setImageNameList:(NSArray *)imageNameList titles:(NSArray *)titles;

- (void)showActionSheet;

- (void)actionSheetViewHidden;


@end
