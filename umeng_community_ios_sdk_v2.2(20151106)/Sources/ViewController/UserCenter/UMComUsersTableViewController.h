//
//  UMComUserRecommendViewController.h
//  UMCommunity
//
//  Created by umeng on 15-3-31.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComViewController.h"

@class UMComPullRequest;

@interface UMComUsersTableViewController : UMComViewController

@property (nonatomic, copy) void (^completion)(NSArray *data, NSError *error);

@property (nonatomic, strong) UMComPullRequest *fetchRequest;

@property (nonatomic, strong) NSArray *userList;

- (id)initWithCompletion:(void (^)(NSArray *data, NSError *error))completion;


@end
