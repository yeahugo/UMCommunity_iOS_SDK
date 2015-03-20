//
//  AppDelegate.m
//  UMCommunityDemo
//
//  Created by Gavin Ye on 3/18/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import "UMAppDelegate.h"
#import "UMCommunity.h"
#import "UMComMessageManager.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMCommViewController.h"

#define UMengMessageAppkey @"54d19091fd98c55a19000406"
#define UMengCommunityAppkey @"4eaee02c527015373b000003"//
#define UMengLoginAppkey UMengCommunityAppkey

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [UMComMessageManager setAppkey:UMengMessageAppkey];
    [UMCommunity openLog:YES];
    [UMComMessageManager startWithOptions:launchOptions];
    
    [UMCommunity setWithAppKey:UMengCommunityAppkey];
    
    //设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:@"wxd930ea5d5a258f4f" appSecret:@"db426a9829e4b49a0dcac7b4162da6b6" url:@"http://www.umeng.com/social"];
    
    //设置分享到QQ互联的appId和appKey
    [UMSocialQQHandler setQQWithAppId:@"100424468" appKey:@"c7394704798a158208a74ab60104f0ba" url:@"http://www.umeng.com/social"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    UMCommViewController *demoViewController = [[UMCommViewController alloc] initWithNibName:@"UMCommViewController" bundle:nil];
    self.window.rootViewController = demoViewController;

    // Override point for customization after application launch.
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
    [UMComMessageManager registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [UMComMessageManager didReceiveRemoteNotification:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
