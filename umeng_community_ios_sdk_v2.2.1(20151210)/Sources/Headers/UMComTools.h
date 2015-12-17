//
//  UMComTools.h
//  UMCommunity
//
//  Created by luyiyuan on 14/10/9.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//common method
#define UMComLocalizedString(key,defaultValue) NSLocalizedStringWithDefaultValue(key,@"UMCommunityStrings",[NSBundle mainBundle],defaultValue,nil)

#define UMComFontNotoSansLightWithSafeSize(FontSize) [UIFont fontWithName:@"FZLanTingHei-L-GBK-M" size:FontSize]?[UIFont fontWithName:@"FZLanTingHei-L-GBK-M" size:FontSize]:[UIFont systemFontOfSize:FontSize]

#define UMComImageWithImageName(imageName) [UIImage imageNamed:[NSString stringWithFormat:@"UMComSDKResources.bundle/images/%@",imageName]]

#define SafeCompletionData(completion,data) if(completion){completion(data);}
#define SafeCompletionDataAndError(completion,data,error) if(completion){completion(data,error);}
#define SafeCompletionDataNextPageAndError(completion,data,haveNext,error) if(completion){completion(data,haveNext,error);}
#define SafeCompletionAndError(completion,error) if(completion){completion(error);}

//common configuration
#define FontColorGray @"#666666"
#define FontColorBlue @"#4A90E2"
#define FontColorLightGray @"#8E8E93"
#define TableViewSeparatorColor @"#C8C7CC"
#define FeedTypeLabelBgColor @"#DDCFD5"
#define LocationTextColor  @"#9B9B9B"

#define ViewGreenBgColor @"#B8E986"
#define ViewGrayColor    @"#D8D8D8"

#define TableViewSeparatorRGBColor [UIColor colorWithRed:0.78 green:0.78 blue:0.8 alpha:1]

#define TableViewCellSpace  0.1
#define BottomLineHeight    0.3

#define TopicRulerString @"(#([^#]+)#)"
#define UserRulerString @"(@[\\u4e00-\\u9fa5_a-zA-Z0-9]+)"

#define TopicString     @"#%@#"
#define UserNameString  @"@%@"

extern NSInteger const kFeedContentLength;//feed列表字符限制
extern NSInteger const kCommentLenght; //feed的评论字数限制
extern CGFloat const kUMComRefreshOffsetHeight;//下拉刷新控件显示的高度
extern CGFloat const kUMComLoadMoreOffsetHeight;//上拉加载控件显示的高度

//Notification Name
extern NSString * const kUserLoginSucceedNotification;//用户登录成功通知
extern NSString * const kUserLogoutSucceedNotification;//用户退出登录通知
extern NSString * const kUMComFollowUserSucceedNotification;//关注用户成功之后的通知

extern NSString * const kNotificationPostFeedResultNotification;//feed发送完成通知
extern NSString * const kUMComFeedDeletedFinishNotification;//feed删除成功通知
extern NSString * const kUMComCommentOperationFinishNotification;//评论发送完成通知
extern NSString * const kUMComLikeOperationFinishNotification;//点赞或取消点赞操作完成通知
extern NSString * const kUMComFavouratesFeedOperationFinishNotification;//收藏或取消收藏操作完成通知
extern NSString * const kUMComRemoteNotificationReceivedNotification;//收到友盟的微社区的消息推送
extern NSString * const kUMComUnreadNotificationRefreshNotification;//未读消息更新完成
extern NSString * const kUMComCommunityInvalidErrorNotification;//社区被关闭导致请求错误的通知


//Common block
typedef void (^PageDataResponse)(id responseData,NSString * navigationUrl,NSError *error);

typedef void (^LoadDataCompletion)(NSArray *data, NSError *error);

typedef void (^LoadServerDataCompletion)(NSArray *data, BOOL haveChanged, NSError *error);

typedef void (^LoadChangedDataCompletion)(NSArray *data);

typedef void (^PostDataResponse)(NSError *error);

//enum
typedef enum {
    userNameDefault = 0,                //默认格式
    userNameNoBlank = 1,                //不包含空格
    userNameNoRestrict = 2              //没有字符限制
}UMComUserNameType;

typedef enum {
    userNameLengthDefault = 0,          //默认长度 2~20
    userNameLengthNoRestrict = 1        //1~50个字数
}UMComUserNameLength;


@interface UMComTools : NSObject

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;

+ (NSError *)errorWithDomain:(NSString *)domain Type:(NSInteger)type reason:(NSString *)reason;
extern NSString * createTimeString(NSString * create_time);

+ (NSInteger)getStringLengthWithString:(NSString *)string;

@end
