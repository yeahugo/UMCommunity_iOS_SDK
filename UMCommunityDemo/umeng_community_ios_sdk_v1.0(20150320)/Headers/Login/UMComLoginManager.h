//
//  UMComLoginManager.h
//  UMCommunity
//
//  Created by Gavin Ye on 8/25/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMComUserAccount.h"
#import "UMComLoginDelegate.h"
#import "UMComPullRequest.h"


@interface UMComLoginManager : NSObject

/**
 设置登录SDK的appkey
 
 */
+ (void)setAppKey:(NSString *)appKey;

/**
 处理SSO跳转回来之后的url
 
 */
+ (BOOL)handleOpenURL:(NSURL *)url;

/**
 得到登录SDK实现对象
 
 */
+ (id<UMComLoginDelegate>)getLoginHandler;


/**
 设置登录SDK实现对象
 
 */
+ (void)setLoginHandler:(id <UMComLoginDelegate>)loginHandler;

/**
 获取当前是否登录
 
 */
+ (BOOL)isLogin;

/**
 提供社区SDK调用，默认使用友盟登录SDK，或者自定义的第三方登录SDK，实现登录功能
 
 */
+ (void)performLogin:(UIViewController *)viewController completion:(FetchCoreDataResponse)completion;


/**
 第三方登录SDK登录完成后，调用此方法上传登录的账号信息
 
 */
+ (void)finishLoginWithAccount:(UMComUserAccount *)userAccount completion:(FetchCoreDataResponse)completion;

/**
 用户注销方法
 */
+ (void)userLogout;
@end



