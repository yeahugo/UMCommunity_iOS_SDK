//
//  UMComAction.m
//  UMCommunity
//
//  Created by Gavin Ye on 11/11/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComAction.h"
#import "UMComSession.h"

@interface UMComAction ()
@property (nonatomic, strong) NSError *error;
@end

@implementation UMComAction

+ (id)action
{
    UMComAction *action = [[super alloc] init];
    action.actionDelegate = action;
    return action;
}

- (void)loginFailPerformAction:(id)param response:(NSArray *)responseObject viewController:(UIViewController *)viewController completion:(LoadDataCompletion)loadDataCompletion
{
    SafeCompletionDataAndError(loadDataCompletion, nil, self.error);
}

- (void)performRecommendViewController:(id)param error:(NSError *)error viewController:(UIViewController *)viewController completion:(LoadDataCompletion)loadDataCompletion
{
    [[UMComTopicRecommendAction action] performAction:error viewController:viewController completion:^(NSArray *data, NSError *error) {
        [[UMComUserRecommendAction action] performAction:error viewController:data.firstObject completion:^(NSArray *data, NSError *error) {
            if ([self.actionDelegate respondsToSelector:@selector(loginSuccessPerformAction:response:viewController:completion:)]) {
                if ( !error) {
                    //将data改成dataArray
                    [self.actionDelegate loginSuccessPerformAction:param response:data viewController:viewController completion:loadDataCompletion];
                } else {
                    [self.actionDelegate loginFailPerformAction:param response:data viewController:viewController completion:loadDataCompletion];
                }
            }
        }];
    }];
}

- (void)performActionAfterLogin:(id)param
                 viewController:(UIViewController *)viewController
                     completion:(LoadDataCompletion)loadDataCompletion
{
    if (![UMComSession sharedInstance].uid) {
        __weak UMComAction * weakSelf = self;
        [[UMComLoginAction action] performAction:nil viewController:viewController completion:^(NSArray *data, NSError *error) {
            __strong UMComAction *strongSelf = weakSelf;
            weakSelf.error = error;
            int isRegistered = [[(UMComUser *)[data firstObject] registered] intValue];
            //第一次登录用户
            if (isRegistered == 0 && data) {
                // 注册后因为用户名有错误，已经修改过用户名
                if ([UMComSession sharedInstance].loginError) {
                    [UMComSession sharedInstance].loginError = nil;
                    [strongSelf performRecommendViewController:param error:error viewController:viewController completion:loadDataCompletion];
                }
                // 注册后用户名正确，没有修改过用户名
                else {
                    [[UMComUpdateProfileAction action] performAction:error viewController:viewController completion:^(NSArray *data, NSError *updateUserError) {
                        [strongSelf performRecommendViewController:param error:updateUserError viewController:viewController completion:loadDataCompletion];
                    }];
                }
            } else {
                if ([self.actionDelegate respondsToSelector:@selector(loginSuccessPerformAction:response:viewController:completion:)]) {
                    if ( !error) {
                        [self.actionDelegate loginSuccessPerformAction:param response:data viewController:viewController completion:loadDataCompletion];
                    } else {
                        [self.actionDelegate loginFailPerformAction:param response:data viewController:viewController completion:loadDataCompletion];
                    }
                }
            }
        }];
    } else {
        if ([self.actionDelegate respondsToSelector:@selector(loginSuccessPerformAction:response:viewController:completion:)]) {
            [self.actionDelegate loginSuccessPerformAction:param response:nil viewController:viewController completion:loadDataCompletion];
        }
    }
}


- (void)loginSuccessPerformAction:(id)param response:(NSArray *)responseObject viewController:(UIViewController *)viewController completion:(LoadDataCompletion)loadDataCompletion
{
    SafeCompletionDataAndError(loadDataCompletion, responseObject, nil);

}

@end
