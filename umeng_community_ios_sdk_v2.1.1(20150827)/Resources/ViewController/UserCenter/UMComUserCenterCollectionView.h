//
//  UMComUserCenterCollectionView.h
//  UMCommunity
//
//  Created by umeng on 15/5/6.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UMComClickActionDelegate, UMComScrollViewDelegate;

@class UMComUser, UMComPullRequest, UMComRefreshView;
@interface UMComUserCenterCollectionView : UICollectionView<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray *userList;

@property (nonatomic, strong) UMComPullRequest *fecthRequest;

@property (nonatomic, strong) UMComUser *user;

@property (nonatomic, weak) id<UMComClickActionDelegate> cellDelegate;

@property (nonatomic, weak) id<UMComScrollViewDelegate> scrollViewDelegate;

@property (nonatomic, assign) CGPoint lastPosition;

@property (nonatomic, strong) UMComRefreshView *refreshViewController;

@property (nonatomic, copy) void (^ComplictionHandler)(UIScrollView *scrollView);

- (void)refreshUsersList;

@end
