//
//  UMComUsersTableView.h
//  UMCommunity
//
//  Created by umeng on 15/7/26.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UMComPullRequest, UMComRefreshView;
@protocol UMComClickActionDelegate, UMComScrollViewDelegate;


@interface UMComUsersTableView : UITableView

@property (nonatomic, strong) UMComPullRequest *fetchRequest;

@property (nonatomic, strong) UMComRefreshView *headView;

@property (nonatomic, strong) UMComRefreshView *footView;

@property (nonatomic, strong) NSArray *userList;

@property (nonatomic, weak) id<UMComClickActionDelegate> clickActionDelegate;

@property (nonatomic, weak) id<UMComScrollViewDelegate> scrollViewDelegate;

@property (nonatomic, assign, readonly) CGPoint lastPosition;

- (void)refreshAllData;

- (void)refreshDataFromServer:(void (^)(NSArray *data, NSError *error))block;

@end
