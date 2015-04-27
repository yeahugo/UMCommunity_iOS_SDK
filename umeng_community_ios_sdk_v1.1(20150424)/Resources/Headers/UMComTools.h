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

//#define UMComFontNotoSansDemiWithSize(FontSize) [UIFont fontWithName:@"NotoSansHans-DemiLight" size:FontSize]
//#define UMComFontNotoSansLightWithSize(FontSize) [UIFont fontWithName:@"NotoSansHans-Light" size:FontSize]

#define UMComFontNotoSansDemiWithSafeSize(FontSize) [UIFont fontWithName:@"FZLanTingHei-L-GBK-M" size:FontSize]?[UIFont fontWithName:@"FZLanTingHei-L-GBK-M" size:FontSize]:[UIFont systemFontOfSize:FontSize]

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
@end
