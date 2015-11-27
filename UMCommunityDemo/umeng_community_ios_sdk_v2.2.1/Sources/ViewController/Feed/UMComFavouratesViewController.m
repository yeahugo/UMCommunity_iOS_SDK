//
//  UMComFavouratesViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 8/12/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import "UMComFavouratesViewController.h"
#import "UMComFeed.h"
#import "UMComAction.h"
#import "UMComPushRequest.h"
#import "UMComShowToast.h"
#import "UMComFeedTableView.h"

@interface UMComFavouratesViewController ()

@end

@implementation UMComFavouratesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.feedsTableView.feedType = feedFavourateType;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favouratesFeedOperationFinish:) name:kUMComFavouratesFeedOperationFinishNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UMComClickActionDelegate

- (void)customObj:(id)obj clickOnFavouratesFeed:(UMComFeed *)feed
{
    BOOL isFavourite = ![[feed has_collected] boolValue];
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        [UMComPushRequest favouriteFeedWithFeed:feed isFavourite:isFavourite completion:^(NSError *error) {
            if (!error) {
                if (isFavourite) {
                    [feed setHas_collected:@1];
                }else{
                    [feed setHas_collected:@0];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kUMComFavouratesFeedOperationFinishNotification object:feed];
            }
            [UMComShowToast favouriteFeedFail:error isFavourite:isFavourite];
        }];
    }];
}


#pragma mark - notification 
- (void)favouratesFeedOperationFinish:(NSNotification *)notification
{
    [self.feedsTableView reloadFeedData];
//    UMComFeed *feed = notification.object;
//    if ([feed isKindOfClass:[UMComFeed class]]) {
//        if ([feed.has_collected boolValue] == YES) {
//            BOOL isContain = NO;
//            for (UMComFeedStyle *feedStyle in self.feedsTableView.dataArray) {
//                if ([feedStyle.feed.feedID isEqualToString:feed.feedID]) {
//                    isContain = YES;
//                }
//            }
//            if (isContain == NO) {
//                UMComFeedStyle *feedStyle = [UMComFeedStyle feedStyleWithFeed:feed viewWidth:self.feedsTableView.frame.size.width feedType:self.feedsTableView.feedType];
//                [self.feedsTableView.dataArray insertObject:feedStyle atIndex:0];
//            }
//        }else{
//            [self.feedsTableView.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                UMComFeedStyle *feedStyle = obj;
//                if ([feed.feedID isEqualToString:feedStyle.feed.feedID] && [feed.has_collected boolValue] == NO) {
//                    *stop = YES;
//                    [self.feedsTableView.dataArray removeObject:obj];
//                }
//            }];
//        }
//    }
    [self.feedsTableView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
