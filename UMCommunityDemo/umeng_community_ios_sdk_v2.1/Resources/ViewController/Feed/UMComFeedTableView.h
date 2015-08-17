//
//  UMComFeedsTableView.h
//  UMCommunity
//
//  Created by Gavin Ye on 12/5/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComTableView.h"


@class UMComPullRequest, UMComLoadStatusView;
@protocol UMComClickActionDelegate, UMComScrollViewDelegate;


@interface UMComFeedTableView : UMComTableView<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) id<UMComClickActionDelegate> clickActionDelegate;//tableViewCell上的一些点击事件的delegate
@property (nonatomic, copy) void (^scrollViewDidScroll)(UIScrollView *scrollView, CGPoint lastPosition);
//
- (void)reloadRowAtIndex:(NSIndexPath *)indexPath;

@property (nonatomic, assign) BOOL showDistance;


@end
