//
//  UMComUsersTableView.h
//  UMCommunity
//
//  Created by umeng on 15/7/26.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComTableView.h"

@class UMComPullRequest, UMComRefreshView;
@protocol UMComClickActionDelegate, UMComScrollViewDelegate;


@interface UMComUsersTableView : UMComTableView

@property (nonatomic, weak) id<UMComClickActionDelegate> clickActionDelegate;

@end
