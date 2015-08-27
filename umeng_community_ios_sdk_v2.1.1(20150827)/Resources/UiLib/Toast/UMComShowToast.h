//
//  UMComShowToast.h
//  UMCommunity
//
//  Created by Gavin Ye on 1/21/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMComLoginManager.h"

//===user===
extern  NSInteger  const  ERR_CODE_USER_NOT_EXIST;
extern  NSInteger  const  ERR_CODE_USER_NOT_LOGIN;
extern  NSInteger  const  ERR_CODE_USER_NO_PRIVILEGE;
extern  NSInteger  const  ERR_CODE_USER_IDENTITY_INVAILD;
extern  NSInteger  const  ERR_CODE_USER_HAS_CREATED;
extern  NSInteger  const  ERR_CODE_USER_HAVE_FOLLOWED;
extern  NSInteger  const  ERR_CODE_USER_LOGIN_INFO_NOT_COMPLETE;
extern  NSInteger  const  ERR_CODE_USER_CANNOT_FOLLOW_SELF;
extern  NSInteger  const  ERR_CODE_USER_NAME_LENGTH_ERROR;
extern  NSInteger  const  ERR_CODE_USER_IS_UNUSABLE;
extern  NSInteger  const  ERR_CODE_USER_NAME_SENSITIVE;
extern  NSInteger  const  ERR_CODE_USER_NAME_DUPLICATE;
extern  NSInteger  const  ERR_CODE_USER_CUSTOM_LENGTH_ERROR;
extern  NSInteger  const  ERR_CODE_ONE_TIME_ONE_USER;
extern  NSInteger  const  ERR_CODE_USER_NAME_CONTAINS_ILLEGAL_CHARS;
extern  NSInteger  const  ERR_CODE_DEVICE_IN_BLACKLIST;
extern  NSInteger  const  ERR_CODE_FAVOURITES_OVER_LIMIT;
extern  NSInteger  const  ERR_CODE_HAS_ALREADY_COLLECTED;
extern  NSInteger  const  ERR_CODE_HAS_NOT_COLLECTED;
//===Feed===
extern  NSInteger  const  ERR_CODE_FEED_UNAVAILABLE;
extern  NSInteger  const  ERR_CODE_FEED_NOT_EXSIT;
extern  NSInteger  const  ERR_CODE_FEED_HAS_BEEN_LIKED;
extern  NSInteger  const  ERR_CODE_FEED_RELATED_USER_ID_INVALID;
extern  NSInteger  const  ERR_CODE_FEED_CANNOT_FORWARD;
extern  NSInteger  const  ERR_CODE_FEED_RELATED_TOPIC_ID_INVALID;
extern  NSInteger  const  ERR_CODE_COMMENT_CONTENT_LENGTH_ERROR;
extern  NSInteger  const  ERR_CODE_FEED_CONTENT_LENGTH_ERROR;
extern  NSInteger  const  ERR_CODE_FEED_TYPE_INVALID;
extern  NSInteger  const  ERR_CODE_FEED_CUSTOM_LENGTH_ERROR;
extern  NSInteger  const  ERR_CODE_FEED_SHARE_CALLBACK_PLATFORM_ERROR;
//===topic===
extern  NSInteger  const  ERR_CODE_HAVE_FOCUSED;
extern  NSInteger  const  ERR_CODE_NOT_EXIST;
extern  NSInteger  const  ERR_CODE_TOPIC_CANNOT_CREATE;
extern  NSInteger  const  ERR_CODE_TOPIC_RANK_ERROR;
extern  NSInteger  const  ERR_CODE_HAVE_NOT_FOCUSED;
//===spammer===
extern  NSInteger  const  ERR_CODE_STATUS_INVILD;
extern  NSInteger  const  ERR_CODE_SPAMMER_HAS_CREATED;
extern  NSInteger  const  ERR_CODE_INVALID_TYPE;
//===midgard_commen===
extern  NSInteger  const  ERR_CODE_REQUEST_PRARMS_ERROR;
extern  NSInteger  const  ERR_CODE_IMAGE_UPLOAD_FAILED;
extern  NSInteger  const  ERR_CODE_INVALID_AUTH_TOKEN;
@interface UMComShowToast : NSObject


+ (void)showFetchResultTipWithError:(NSError *)error;

+ (void)createFeedSuccess;

+ (void)showNotInstall;

+ (void)showNoMore;

+ (void)spamSuccess:(NSError *)error;

+ (void)spamComment:(NSError *)error;

+ (void)spamUser:(NSError *)error;

+ (void)commentMoreWord;

+ (void)fetchFailWithNoticeMessage:(NSString *)message;

+ (void)notSupportPlatform;

+ (void)saveIamgeResultNotice:(NSError *)error;

+ (void)favouriteFeedFail:(NSError *)error isFavourite:(BOOL)isFavourite;


//+ (void)loginFail:(NSError *)error;

//+ (void)createCommentFail:(NSError *)error;

//+ (void)createFeedFail:(NSError *)error;

//+ (void)fetchFeedFail:(NSError *)error;

//+ (void)createLikeFail:(NSError *)error;

//+ (void)deleteLikeFail:(NSError *)error;

//+ (void)fetchMoreFeedFail:(NSError *)error;



//+ (void)fetchTopcsFail:(NSError *)error;

//+ (void)fetchLocationsFail:(NSError *)error;

//+ (void)fetchFriendsFail:(NSError *)error;

//+ (void)focusTopicFail:(NSError *)error;

//+ (void)focusUserFail:(NSError *)error;

//+ (void)fetchRecommendUserFail:(NSError *)error;

//+ (void)fetchUserFail:(NSError *)error;

//+ (void)deletedFail:(NSError *)error;




@end
