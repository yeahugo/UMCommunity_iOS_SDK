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

+ (void)handleLoginUser:(UMComUserAccount *)userAccount response:(id)responseObject error:(NSError *)error completion:(LoadDataCompletion)completion
{
    [[UMComUpdateProfileAction action] loginSuccessPerformAction:error response:@[userAccount] viewController:nil completion:^(NSArray *data, NSError *error) {
        
        if (![responseObject valueForKey:@"id"]) {
            SafeCompletionDataAndError(completion, data, error);
            return;
        }
        NSString *uid = [responseObject valueForKey:@"id"];
        [UMComSession sharedInstance].uid = uid;
        [UMComSession sharedInstance].token = [responseObject valueForKey:@"token"];
        
        [[UMComSession sharedInstance] saveLoginUser:responseObject completion:^{
            SafeCompletionDataAndError(completion, responseObject, error);
        }];

        [[NSNotificationCenter defaultCenter] postNotificationName:UserLoginSecceed object:nil];
        NSString *aliasKey = @"UM_COMMUNITY";
        
        UMComUserProfileRequest *userProfileController = [[UMComUserProfileRequest alloc] initWithUid:uid sourceUid:nil];
        [userProfileController fetchRequestFromServer:nil];
        UMComFollowersRequest *followerController = [[UMComFollowersRequest alloc] initWithUid:uid count:BatchSize*2];
        [followerController fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        }];
        
        [UMComMessageManager addAlias:uid type:aliasKey response:^(id responseObject, NSError *error) {
            if (error) {
                UMLog(@"add alias is %@ error is %@",responseObject,error);
            }
        }];
    }];
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

+ (void)finishLoginWithAccount:(UMComUserAccount *)userAccount completion:(LoadDataCompletion)completion
{
    if (userAccount) {
        if([self isIncludeSpecialCharact:userAccount.name]){
            NSError *error = [NSError errorWithDomain:@"UMComHttpClient.Error" code:kUserNameWrongCharater userInfo:nil];
            [UMComShowToast registerError:error];
            [UMComSession sharedInstance].currentUserAccount = userAccount;
            [self handleLoginUser:userAccount response:nil error:error completion:completion];
            SafeCompletionDataAndError(completion, nil, error);
        } else {
            [UMComHttpManager userLogin:userAccount response:^(id responseObject, NSError *error) {
                if (error.code == kUserNameTooLong || error.code == kUserNameSensitive || error.code == kUserNameRepeat || error.code == kUserNameWrongName) {
                    [UMComSession sharedInstance].currentUserAccount = userAccount;
                    [UMComShowToast registerError:error];
                    [self handleLoginUser:userAccount response:responseObject error:error completion:completion];
                    SafeCompletionDataAndError(completion, responseObject, error);
                } else if(error){
                    SafeCompletionDataAndError(completion, responseObject, error);
                    [UMComShowToast loginFail:error];
                } else if (responseObject) {
                    if (![responseObject valueForKey:@"id"]) {
                        SafeCompletionDataAndError(completion, nil, error);
                        return;
                    }
                    NSString *uid = [responseObject valueForKey:@"id"];
                    [UMComSession sharedInstance].uid = uid;
                    [UMComSession sharedInstance].token = [responseObject valueForKey:@"token"];
                    
                    [[UMComSession sharedInstance] saveLoginUser:responseObject completion:^{
                        SafeCompletionDataAndError(completion, responseObject, error);
                    }];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:UserLoginSecceed object:nil];
                    UMLog(@"error is %@",error);
                    NSString *aliasKey = @"UM_COMMUNITY";
                    
                    UMComUserProfileRequest *userProfileController = [[UMComUserProfileRequest alloc] initWithUid:uid sourceUid:nil];
                    [userProfileController fetchRequestFromServer:nil];
                    UMComFollowersRequest *followerController = [[UMComFollowersRequest alloc] initWithUid:uid count:2*BatchSize];
                    [followerController fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
                    }];
                    
                    [UMComMessageManager addAlias:uid type:aliasKey response:^(id responseObject, NSError *error) {
                        if (error) {
                            UMLog(@"add alias is %@ error is %@",responseObject,error);
                        }
                    }];
                }
            }];
        }
    }
}



+ (void)userLogout
{
    [[UMComSession sharedInstance] userLogout];
}

@end
