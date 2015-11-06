//
//  UMComErrorCode.h
//  UMCommunity
//
//  Created by umeng on 15/9/9.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>



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
extern  NSInteger  const  ERR_CODE_LIKE_HAS_BEEN_CANCELED;
extern  NSInteger  const  ERR_CODE_TITLE_LENGTH_ERROR;
extern  NSInteger  const  ERR_CODE_FEED_COMMENT_UNAVAILABLE;


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

//Community
extern NSInteger   const  ERR_CODE_INVALID_COMMUNITY;



//user
extern  NSString * const  ERR_MSG_USER_BASE_INFO_NOT_COMPLETE;
extern  NSString * const  ERR_MSG_USER_NOT_EXIST;
extern  NSString * const  ERR_MSG_USER_NOT_LOGIN;
extern  NSString * const  ERR_MSG_USER_NO_PRIVILEGE;
extern  NSString * const  ERR_MSG_USER_IDENTITY_INVAILD;
extern  NSString * const  ERR_MSG_USER_HAS_CREATED;
extern  NSString * const  ERR_MSG_USER_HAVE_FOLLOWED;
extern  NSString * const  ERR_MSG_USER_LOGIN_INFO_NOT_COMPLETE;
extern  NSString * const  ERR_MSG_USER_CANNOT_FOLLOW_SELF;
extern  NSString * const  ERR_MSG_USER_NAME_LENGTH_ERROR;
extern  NSString * const  ERR_MSG_USER_IS_UNUSABLE;
extern  NSString * const  ERR_MSG_USER_NAME_SENSITIVE;
extern  NSString * const  ERR_MSG_USER_NAME_DUPLICATE;
extern  NSString * const  ERR_MSG_USER_CUSTOM_LENGTH_ERROR;
extern  NSString * const  ERR_MSG_ONE_TIME_ONE_USER_ERROR;
extern  NSString * const  ERR_MSG_USER_NAME_CONTAINS_ILLEGAL_CHARS;
extern  NSString * const  ERR_MSG_DEVICE_IN_BLACKLIST;
extern  NSString * const  ERR_MSG_FAVOURITES_OVER_LIMIT;
extern  NSString * const  ERR_MSG_HAS_ALREADY_COLLECTED;
extern  NSString * const  ERR_MSG_HAS_NOT_COLLECTED;

//feed
extern  NSString * const  ERR_MSG_FEED_UNAVAILABLE;
extern  NSString * const  ERR_MSG_FEED_NOT_EXSIT;
extern  NSString * const  ERR_MSG_FEED_HAS_BEEN_LIKED;
extern  NSString * const  ERR_MSG_FEED_RELATED_USER_ID_INVALID;
extern  NSString * const  ERR_MSG_FEED_CANNOT_FORWARD;
extern  NSString * const  ERR_MSG_FEED_RELATED_TOPIC_ID_INVALID;
extern  NSString * const  ERR_MSG_COMMENT_CONTENT_LENGTH_ERROR;
extern  NSString * const  ERR_MSG_FEED_CONTENT_LENGTH_ERROR;
extern  NSString * const  ERR_MSG_FEED_CUSTOM_LENGTH_ERROR;
extern  NSString * const  ERR_MSG_FEED_TYPE_INVALID;
extern  NSString * const  ERR_MSG_FEED_SHARE_CALLBACK_PLATFORM_ERROR;
extern  NSString * const  ERR_MSG_LIKE_HAS_BEEN_CANCELED;
extern  NSString * const  EER_MSG_TITLE_LENGTH_ERROR;
extern  NSString * const  ERR_MSG_FEED_COMMENT_UNAVAILABLE;


//topic
extern  NSString * const  ERR_MSG_HAVE_FOCUSED;
extern  NSString * const  ERR_MSG_NOT_EXSIT;
extern  NSString * const  ERR_MSG_TOPIC_CANNOT_CREATE;
extern  NSString * const  ERR_MSG_HAVE_NOT_FOCUSED;
extern  NSString * const  ERR_MSG_TOPIC_RANK_ERROR;

//spammer
extern  NSString * const  ERR_MSG_STATUS_INVILD;
extern  NSString * const  ERR_MSG_SPAMMER_HAS_CREATED;
extern  NSString * const  ERR_MSG_INVALID_TYPE;

//===midgard_commen===
extern  NSString * const  ERR_MSG_REQUEST_PRARMS_ERROR;
extern  NSString * const  ERR_MSG_IMAGE_UPLOAD_FAILED;
extern  NSString * const  ERR_MSG_INVALID_AUTH_TOKEN;

//Community
extern  NSString * const  ERR_MSG_INVALID_COMMUNITY;


@interface UMComErrorCode : NSObject


@end
