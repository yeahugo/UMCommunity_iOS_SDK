//
//  UMComFavouratesViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 8/12/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import "UMComFavouratesViewController.h"
#import "UMComFavouratesTableView.h"
#import "UMComFeed.h"
#import "UMComAction.h"
#import "UMComPushRequest.h"
#import "UMComShowToast.h"

@interface UMComFavouratesViewController ()

@end

@implementation UMComFavouratesViewController

- (id)initWithFeedsTableView:(UMComFavouratesTableView *)feedsView
{
    self = [super init];
    self.feedsTableView = feedsView;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    if (self.feedsTableView == nil) {
//        
//        self.feedsTableView = favouratesTableView;
//    }
//    [super updateFeedsTableView:self.feedsTableView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customObj:(id)obj clickOnAddCollection:(UMComFeed *)feed
{
    BOOL isFavourite = ![[feed has_collected] boolValue];
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        [UMComFavouriteFeedRequest favouriteFeedWithFeedId:feed.feedID isFavourite:isFavourite completion:^(NSError *error) {
            if (!error) {
                if (isFavourite) {
                    [feed setHas_collected:@1];
                }else{
                    [feed setHas_collected:@0];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kUMComCollectionOperationFinish object:feed];
            }
            [UMComShowToast favouriteFeedFail:error isFavourite:isFavourite];
        }];
    }];
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
