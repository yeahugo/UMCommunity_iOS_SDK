//
//  UMAppDelegate.m
//  UMCommunity
//
//  Created by Gavin Ye on 8/25/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMAppDelegate.h"
#import "UMCommViewController.h"
#import "UMCommunity.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaHandler.h"
#import "UMSocialWechatHandler.h"
#import "LoginViewController.h"
#import "UMComNavigationController.h"

#define UMengCommunityAppkey @"54d19091fd98c55a19000406"



#define UMengLoginAppkey UMengCommunityAppkey

@implementation UMAppDelegate

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [UMCommunity openLog:YES];
    //Message
    [UMCommunity setWithAppKey:UMengCommunityAppkey];//54d19091fd98c55a19000406
    
    NSDictionary *notificationDict = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if ([notificationDict valueForKey:@"umwsq"]) {
        [UMComMessageManager startWithOptions:launchOptions];
        if ([notificationDict valueForKey:@"aps"]) // 点击推送进入
        {
            [UMComMessageManager didReceiveRemoteNotification:notificationDict];
        }
    } else {
        [UMComMessageManager startWithOptions:nil];
        //使用你的消息通知处理
    }

    //下面实现自定义登录
//    LoginViewController *loginViewControler =[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
//    [UMComLoginManager setLoginHandler:loginViewControler];
//    //设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:@"wx96110a1e3af63a39" appSecret:@"c60e3d3ff109a5d17013df272df99199" url:@"http://www.umeng.com/social"];
    //设置分享到QQ互联的appId和appKey
    [UMSocialQQHandler setQQWithAppId:@"1104606393" appKey:@"X4BAsJAVKtkDQ1zQ" url:@"http://www.umeng.com/social"];
    [UMComLoginManager setAppKey:UMengLoginAppkey];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    UINavigationController *communityController = [UMCommunity getFeedsModalViewController];
    self.window.rootViewController = communityController;
    return YES;
}

#pragma mark Login
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [UMComLoginManager handleOpenURL:url];
    if (result == FALSE) {
        //调用其他SDK，例如新浪微博SDK等
    }
    return result;
}

#pragma mark Message
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"----devicetoken------%@",[[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
                  stringByReplacingOccurrencesOfString: @">" withString: @""]
                 stringByReplacingOccurrencesOfString: @" " withString: @""]);
    [UMComMessageManager registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if ([userInfo valueForKey:@"umwsq"]) {
        [UMComMessageManager didReceiveRemoteNotification:userInfo];
    } else {
        //使用你自己的消息推送处理
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
