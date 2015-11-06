//
//  UMComLoginDelegate.h
//  UMCommunity
//
//  Created by Gavin Ye on 11/11/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMComTools.h"

@class UMComFeed;

@protocol UMComLoginDelegate <NSObject>

@optional
/**
 设置自定义登录的Appkey
 
 */
- (void)setAppKey:(NSString *)appKey;


/**
 自定义登录或者自定义分享处理URL地址
 
 @param 应用回传的URL地址
 
 @returns 处理结果
 */
- (BOOL)handleOpenURL:(NSURL *)url;


/**
 处理自定义登录，在友盟微社区没有登录情况下点击遇到需要登录的按钮，就会触发此方法
 
 @param viewController 父ViewController
 @param LoadDataCompletion 登录完成的回调
 
 */
- (void)presentLoginViewController:(UIViewController *)viewController finishResponse:(LoadDataCompletion)loginCompletion;

/**
 点击某个分享平台之后的回调方法
 
 @param platformName 分享平台名
 @param feed 分享的当条Feed
 @param viewController 当前ViewController

 */
- (void)didSelectPlatform:(NSString *)platformName
                     feed:(UMComFeed *)feed
           viewController:(UIViewController *)viewControlller;
@end
