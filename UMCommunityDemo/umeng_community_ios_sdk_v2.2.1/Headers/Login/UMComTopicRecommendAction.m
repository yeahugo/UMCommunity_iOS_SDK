//
//  UMComTopicRecommendAction.m
//  UMCommunity
//
//  Created by umeng on 15-4-1.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComAction.h"
#import "UMComTopicsTableViewController.h"
#import "UMComNavigationController.h"
#import "UMComPullRequest.h"
#import "UMComTools.h"

@implementation UMComTopicRecommendAction
- (void)loginSuccessPerformAction:(id)param
                         response:(NSArray *)responseObject
                   viewController:(UIViewController *)viewController
                       completion:(LoadDataCompletion)loadDataCompletion
{
    
    UMComTopicsTableViewController *topicsRecommendViewController = [[UMComTopicsTableViewController alloc] init];
    topicsRecommendViewController.title = UMComLocalizedString(@"user_topic_recommend", @"话题推荐");
    topicsRecommendViewController.fetchRequest = [[UMComRecommendTopicsRequest alloc]initWithCount:BatchSize];
    [viewController.navigationController  pushViewController:topicsRecommendViewController animated:YES];
}

- (void)performAction:(id)param
       viewController:(UIViewController *)viewController
           completion:(LoadDataCompletion)loadDataCompletion
{
    UMComTopicsTableViewController *topicsRecommendViewController = [[UMComTopicsTableViewController alloc] init];
    topicsRecommendViewController.completion = loadDataCompletion;
    topicsRecommendViewController.isShowNextButton = YES;
    topicsRecommendViewController.title = UMComLocalizedString(@"user_topic_recommend", @"话题推荐");
    topicsRecommendViewController.fetchRequest = [[UMComRecommendTopicsRequest alloc]initWithCount:BatchSize];
    UMComNavigationController *topicsNav = [[UMComNavigationController alloc] initWithRootViewController:topicsRecommendViewController];
    [viewController presentViewController:topicsNav animated:YES completion:nil];
}

@end
