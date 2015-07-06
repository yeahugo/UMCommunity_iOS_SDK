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

- (void)setAppKey:(NSString *)appKey;

- (BOOL)handleOpenURL:(NSURL *)url;

- (void)presentLoginViewController:(UIViewController *)viewController finishResponse:(LoadDataCompletion)loginCompletion;

- (void)didSelectPlatform:(NSString *)platformName
                     feed:(UMComFeed *)feed
           viewController:(UIViewController *)viewControlller;
@end
