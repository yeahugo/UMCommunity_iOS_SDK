//
//  UMComLoginAction.m
//  UMCommunity
//
//  Created by Gavin Ye on 11/11/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComAction.h"
#import "UMComLoginManager.h"

@implementation UMComLoginAction

- (void)performAction:(NSString *)param
       viewController:(UIViewController *)viewController
           completion:(LoadDataCompletion)loadDataCompletion
{
    [UMComLoginManager performLogin:viewController completion:loadDataCompletion];
}

@end
