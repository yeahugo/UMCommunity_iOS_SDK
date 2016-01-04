//
//  UMComUserRecommendAction.m
//  UMCommunity
//
//  Created by umeng on 15-4-1.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComAction.h"
#import "UMComUsersTableViewController.h"
#import "UMComPullRequest.h"

@implementation UMComUserRecommendAction

- (void)loginSuccessPerformAction:(id)param
                         response:(NSArray *)responseObject
                   viewController:(UIViewController *)viewController
                       completion:(LoadDataCompletion)loadDataCompletion
{
    UMComUsersTableViewController *userRecommendViewController = [[UMComUsersTableViewController alloc] init];
    userRecommendViewController.fetchRequest = [[UMComRecommendUsersRequest alloc]initWithCount:BatchSize];
    userRecommendViewController.title = UMComLocalizedString(@"user_recommend", @"用户推荐");
    [viewController.navigationController  pushViewController:userRecommendViewController animated:YES];
}


- (void)performAction:(id)param
       viewController:(UIViewController *)viewController
           completion:(LoadDataCompletion)loadDataCompletion
{
    UMComUsersTableViewController *userRecommendViewController = [[UMComUsersTableViewController alloc] initWithCompletion:loadDataCompletion];
    userRecommendViewController.fetchRequest = [[UMComRecommendUsersRequest alloc]initWithCount:BatchSize];
    userRecommendViewController.title = UMComLocalizedString(@"user_recommend", @"用户推荐");
    [viewController.navigationController  pushViewController:userRecommendViewController animated:YES];

}

@end
