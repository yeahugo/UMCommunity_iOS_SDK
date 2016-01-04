//
//  UMComUserCollectionViewController.h
//  UMCommunity
//
//  Created by umeng on 15/12/21.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComViewController.h"
@protocol UMComScrollViewDelegate;

@class UMComUser, UMComPullRequest, UMComRefreshView;

@interface UMComUserCollectionViewController : UMComViewController<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) CGFloat headerViewHeight;

@property (nonatomic, strong) NSMutableArray *userList;

@property (nonatomic, strong) UMComPullRequest *fecthRequest;

@property (nonatomic, strong) UMComUser *user;

@property (nonatomic, weak) id<UMComScrollViewDelegate> scrollViewDelegate;

@property (nonatomic, assign) CGPoint lastPosition;

@property (nonatomic, strong) UMComRefreshView *refreshViewController;

@property (nonatomic, copy) void (^ComplictionHandler)(UIScrollView *scrollView);

- (instancetype)initWithFetchRequest:(UMComPullRequest *)request;

- (void)refreshDataFromServer:(void(^)(NSArray *data, NSError *error))block;

- (void)refreshUsersList;

- (void)inserUser:(UMComUser *)user atIndex:(NSInteger)index;

- (void)deleteUser:(UMComUser *)user;

@end
