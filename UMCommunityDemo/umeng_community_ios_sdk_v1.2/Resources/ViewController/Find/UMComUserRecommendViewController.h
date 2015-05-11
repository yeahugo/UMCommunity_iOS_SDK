//
//  UMComUserRecommendViewController.h
//  UMCommunity
//
//  Created by umeng on 15-3-31.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComTableViewController.h"
#import "UMComPullRequest.h"
#import "UMComUserRecommendCell.h"


@interface UMComUserRecommendViewController : UMComTableViewController

@property (nonatomic, strong) NSString *topicId;

@property (nonatomic, assign) UMComUserType userDataSourceType;

@property (nonatomic, copy) LoadDataCompletion completion;

@property (nonatomic, strong) UIViewController *viewController;

@property (nonatomic, strong) NSArray *recommendUserList;


- (id)initWithCompletion:(LoadDataCompletion)completion;



@end
