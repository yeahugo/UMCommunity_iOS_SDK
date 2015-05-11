//
//  UMComShowToast.h
//  UMCommunity
//
//  Created by Gavin Ye on 1/21/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMComLoginManager.h"


@interface UMComShowToast : NSObject

+ (void)createFeedSuccess;

+ (void)showNotInstall;

+ (void)showNoMore;

+ (void)registerError:(NSError*)error;

+ (void)spamSuccess:(NSError *)error;

+ (void)loginFail:(NSError *)error;

+ (void)deleteSuccess:(NSError *)error;

+ (void)createCommentFail:(NSError *)error;

+ (void)createFeedFail:(NSError *)error;

+ (void)fetchFeedFail:(NSError *)error;

+ (void)createLikeFail:(NSError *)error;

+ (void)deleteLikeFail:(NSError *)error;

+ (void)fetchMoreFeedFail:(NSError *)error;

+ (void)updateProfileFail:(NSError *)error;

+ (void)fetchFailWithNoticeMessage:(NSString *)message;

+ (void)dealWithFeedFailWithErrorCode:(NSInteger)code;

+ (void)notSupportPlatform;

+ (void)showMoreCommentFail:(NSError *)error;

+ (void)fetchTopcsFail:(NSError *)error;

+ (void)fetchLocationsFail:(NSError *)error;

+ (void)fetchFriendsFail:(NSError *)error;

+ (void)saveIamgeResultNotice:(NSError *)error;

+ (void)focusUserFail:(NSError *)error;

+ (void)fetchRecommendUserFail:(NSError *)error;

@end
