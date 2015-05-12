//
//  UMComUserCenterCollectionView.h
//  UMCommunity
//
//  Created by umeng on 15/5/6.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComPullRequest.h"
#import "UMComUser.h"

@interface UMComUserCenterCollectionView : UICollectionView<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray *userList;

@property (nonatomic, strong) UMComPullRequest *fecthRequest;

@property (nonatomic, strong) UMComUser *user;

@property (nonatomic, strong) UIViewController *viewController;

- (void)refreshUsersList;

@end
