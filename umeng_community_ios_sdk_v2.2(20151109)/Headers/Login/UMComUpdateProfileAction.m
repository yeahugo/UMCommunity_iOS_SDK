//
//  UMComUpdateProfileAction.m
//  UMCommunity
//
//  Created by Gavin Ye on 11/11/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComAction.h"
#import "UMComProfileSettingController.h"
#import "UMComSession.h"
#import "UMComNavigationController.h"

@implementation UMComUpdateProfileAction

-(void)loginSuccessPerformAction:(id)param
                        response:(NSArray *)responseObject
                  viewController:(UIViewController *)viewController completion:(LoadDataCompletion)loadDataCompletion
{
    UMComProfileSettingController *profileController = [[UMComProfileSettingController alloc] initWithUid:[UMComSession sharedInstance].uid];
    profileController.completion = loadDataCompletion;
    if ([param isKindOfClass:[NSError class]]) {
        profileController.registerError = (NSError *)param;
    }
    
    UMComNavigationController *profileNaviController = [[UMComNavigationController alloc] initWithRootViewController:profileController];
    if (viewController == nil) {
        UIViewController *parentViewController = [UMComSession sharedInstance].beforeLoginViewController;
        if (parentViewController == nil) {
            parentViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
            [parentViewController presentViewController:profileNaviController animated:YES completion:nil];
        } else {
            [parentViewController dismissViewControllerAnimated:YES completion:^{
                [parentViewController presentViewController:profileNaviController animated:YES completion:nil];
            }];        
        }
    } else {
        [viewController presentViewController:profileNaviController animated:YES completion:nil];
    }
}


- (void)performAction:(id)param
       viewController:(UIViewController *)viewController
           completion:(LoadDataCompletion)loadDataCompletion
{
    UMComProfileSettingController *profileController = [[UMComProfileSettingController alloc] initWithUid:[UMComSession sharedInstance].uid];
    profileController.completion = loadDataCompletion;
    UMComNavigationController *profileNaviController = [[UMComNavigationController alloc] initWithRootViewController:profileController];
    [viewController presentViewController:profileNaviController animated:YES completion:nil];
}
@end
