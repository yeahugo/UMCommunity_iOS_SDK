//
//  UMComUserRecommendViewController.h
//  UMCommunity
//
//  Created by umeng on 15-3-31.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComTableViewController.h"
#import "UMComPullRequest.h"


@interface UMComUserRecommendViewController : UMComTableViewController

@property (nonatomic, strong) NSString *topicId;
@property (nonatomic, copy) LoadDataCompletion completion;

- (id)initWithCompletion:(LoadDataCompletion)completion;

@property (nonatomic, strong) UIViewController *viewController;

@end
