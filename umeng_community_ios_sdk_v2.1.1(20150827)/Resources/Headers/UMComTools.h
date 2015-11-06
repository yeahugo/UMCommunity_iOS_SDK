//
//  UMComTools.h
//  UMCommunity
//
//  Created by luyiyuan on 14/10/9.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define UMComLocalizedString(key,defaultValue) NSLocalizedStringWithDefaultValue(key,@"UMCommunityStrings",[NSBundle mainBundle],defaultValue,nil)

#define UMComFontNotoSansLightWithSafeSize(FontSize) [UIFont fontWithName:@"FZLanTingHei-L-GBK-M" size:FontSize]?[UIFont fontWithName:@"FZLanTingHei-L-GBK-M" size:FontSize]:[UIFont systemFontOfSize:FontSize]

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

extern NSInteger const kFeedContentLenght;//feed列表字符限制
extern CGFloat const kUMComRefreshOffsetHeight;//下拉刷新控件显示的高度
extern CGFloat const kUMComLoadMoreOffsetHeight;//上拉加载控件显示的高度

extern NSString * const kNotificationPostFeedResult;//feed发送完成通知
extern NSString * const kNotificationForwardFeedResult;//feed转发完成通知
extern NSString * const kUMComFeedDeletedFinish;//feed删除成功通知
extern NSString * const kUMComCommentOperationFinish;//评论发送完成通知
extern NSString * const kUMComLikeOperationFinish;//点赞或取消点赞操作完成通知
extern NSString * const kUMComFavouratesFeedOperationFinish;//收藏或取消收藏操作完成通知
extern NSString * const kUMComRemoteNotificationReceived;//收到友盟的微社区的消息推送
extern NSString * const kUMComUnreadNotificationRefresh;//未读消息更新完成


#define SafeCompletionData(completion,data) if(completion){completion(data);}
#define SafeCompletionDataAndError(completion,data,error) if(completion){completion(data,error);}
#define SafeCompletionDataNextPageAndError(completion,data,haveNext,error) if(completion){completion(data,haveNext,error);}
#define SafeCompletionAndError(completion,error) if(completion){completion(error);}

typedef void (^PageDataResponse)(id responseData,NSString * navigationUrl,NSError *error);

typedef void (^LoadDataCompletion)(NSArray *data, NSError *error);

typedef void (^LoadServerDataCompletion)(NSArray *data, BOOL haveChanged, NSError *error);

typedef void (^LoadChangedDataCompletion)(NSArray *data);

typedef void (^PostDataResponse)(NSError *error);

@interface UMComTools : NSObject
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;

+ (NSError *)errorWithDomain:(NSString *)domain Type:(NSInteger)type reason:(NSString *)reason;
extern NSString * createTimeString(NSString * create_time);

@end
