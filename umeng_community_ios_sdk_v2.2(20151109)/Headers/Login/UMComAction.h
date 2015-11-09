//
//  UMComAction.h
//  UMCommunity
//
//  Created by Gavin Ye on 11/11/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMComTools.h"

@protocol UMComActionDelegate <NSObject>

@optional
- (void)loginSuccessPerformAction:(id)param
                        response:(NSArray *)responseObject
                  viewController:(UIViewController *)viewController
                      completion:(LoadDataCompletion)loadDataCompletion;

- (void)loginFailPerformAction:(id)param
                         response:(NSArray *)responseObject
                   viewController:(UIViewController *)viewController
                       completion:(LoadDataCompletion)loadDataCompletion;

@optional
- (void)performAction:(id)param viewController:(UIViewController *)viewController completion:(LoadDataCompletion)loadDataCompletion;

@end

@interface UMComAction : NSObject<UMComActionDelegate>

@property (nonatomic, weak) id <UMComActionDelegate> actionDelegate;

+ (id)action;

- (void)performActionAfterLogin:(id)param
                 viewController:(UIViewController *)viewController
                     completion:(LoadDataCompletion)loadDataCompletion;

@end


@interface UMComLoginAction : UMComAction

@end

@interface UMComUpdateProfileAction : UMComAction

@end

@interface UMComUserRecommendAction : UMComAction

@end

@interface UMComTopicRecommendAction : UMComAction

@end
