//
//  UMComLoginManager.m
//  UMCommunity
//
//  Created by Gavin Ye on 8/25/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComLoginManager.h"
#import "UMComHttpManager.h"
#import "UMComSession.h"
#import "UMComMessageManager.h"
#import "UMComPullRequest.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComShowToast.h"
#import "UMComAction.h"
#import "UMUtils.h"
#import "UMComPushRequest.h"

@interface UMComLoginManager ()

@property (nonatomic, strong) id<UMComLoginDelegate> loginHandler;

@property (nonatomic, copy) NSString *appKey;

@property (nonatomic, copy) LoadDataCompletion loginCompletion;

@end

@implementation UMComLoginManager

static UMComLoginManager *_instance = nil;
+ (UMComLoginManager *)shareInstance {
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    
    return _instance;
}

+ (void)setAppKey:(NSString *)appKey
{
    if ([[self shareInstance].loginHandler respondsToSelector:@selector(setAppKey:)]) {
        [self shareInstance].appKey = appKey;
        [[self shareInstance].loginHandler setAppKey:appKey];
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        
        Class delegateClass = NSClassFromString(@"UMComUMengLoginHandler");
        self.loginHandler = [[delegateClass alloc] init];
    }
    return self;
}

+ (void)performLogin:(UIViewController *)viewController completion:(LoadDataCompletion)completion
{
    [UMComSession sharedInstance].beforeLoginViewController = viewController;
    if ([self shareInstance].loginHandler) {
        [self shareInstance].loginCompletion = completion;
        [[self shareInstance].loginHandler presentLoginViewController:viewController finishResponse:^(NSArray *data, NSError *error) {
            SafeCompletionDataAndError(completion, data, error);
        }];
    }
}

+ (id<UMComLoginDelegate>)getLoginHandler
{
    return [self shareInstance].loginHandler;
}

+ (BOOL)isLogin{
    BOOL isLogin = [UMComSession sharedInstance].uid ? YES : NO;
    return isLogin;
}

+ (void)setLoginHandler:(id <UMComLoginDelegate>)loginHandler
{
    [self shareInstance].loginHandler = loginHandler;
}

+ (BOOL)handleOpenURL:(NSURL *)url
{
    if ([[self shareInstance].loginHandler respondsToSelector:@selector(handleOpenURL:)]) {
        return [[self shareInstance].loginHandler handleOpenURL:url];
    }
    return NO;
}

+ (BOOL)isIncludeSpecialCharact:(NSString *)str {
    
    NSString *regex = @"(^[a-zA-Z0-9_\u4e00-\u9fa5]+$)";
    NSPredicate *   pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isRight = ![pred evaluateWithObject:str];
    return isRight;
}



+ (void)finishDismissViewController:(UIViewController *)viewController data:(NSArray *)data error:(NSError *)error
{
    if (viewController.presentingViewController) {
        [viewController dismissViewControllerAnimated:YES completion:^{
            if ([self shareInstance].loginCompletion) {
                [self shareInstance].loginCompletion(data, error);
            }
        }];
    } else {
        if ([self shareInstance].loginCompletion) {
            [self shareInstance].loginCompletion(data, error);
        }
    }
}

+ (void)saveData:(id)responseObject error:(NSError *)error completion:(LoadDataCompletion)completion
{
    if (![[responseObject firstObject] isKindOfClass:[UMComUser class]]) {
        SafeCompletionDataAndError(completion, nil, error);
        return;
    }
    SafeCompletionDataAndError(completion, responseObject, error);
    
    NSString *uid = [[responseObject firstObject] uid];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoginSucceedNotification object:nil];
    UMLog(@"error is %@",error);
    NSString *aliasKey = @"UM_COMMUNITY";
    [UMComMessageManager addAlias:uid type:aliasKey response:^(id responseObject, NSError *error) {
        if (error) {
            //添加alias失败的话在每次启动时候重新添加
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"UMComMessageAddAliasFail"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            UMLog(@"add alias is %@ error is %@",responseObject,error);
        }
    }];
}

+ (void)finishLoginWithAccount:(UMComUserAccount *)userAccount completion:(LoadDataCompletion)completion
{
    if (userAccount) {
        [UMComPushRequest loginWithUser:userAccount completion:^(id responseObject, NSError *error) {
            if (error.code == ERR_CODE_USER_NAME_LENGTH_ERROR || error.code == ERR_CODE_USER_NAME_SENSITIVE || error.code == ERR_CODE_USER_NAME_DUPLICATE || error.code == ERR_CODE_USER_NAME_CONTAINS_ILLEGAL_CHARS) {
                [UMComSession sharedInstance].currentUserAccount = userAccount;
                [UMComShowToast showFetchResultTipWithError:error];
                
                [UMComSession sharedInstance].loginError = error;
                [[UMComUpdateProfileAction action] loginSuccessPerformAction:error response:@[userAccount] viewController:nil completion:^(NSArray *data, NSError *error) {
                    
                    [self saveData:data error:error completion:completion];
                }];
                SafeCompletionDataAndError(completion, responseObject, error);
            } else if(error){
                SafeCompletionDataAndError(completion, responseObject, error);
                [UMComShowToast showFetchResultTipWithError:error];
            } else if (responseObject) {
                [self saveData:responseObject error:error completion:completion];
            }
        }];
    }
}



+ (void)userLogout
{
    [[UMComSession sharedInstance] userLogout];
}

@end
