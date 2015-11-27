//
//  UMComTools.m
//  UMCommunity
//
//  Created by luyiyuan on 14/10/9.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComTools.h"
#define DEFAULT_VOID_COLOR [UIColor whiteColor]

NSInteger const kFeedContentLength = 300;
NSInteger const kCommentLenght = 300;
CGFloat const kUMComRefreshOffsetHeight = 60.0f;
CGFloat const kUMComLoadMoreOffsetHeight = 50.0f;

//notifications
NSString * const kUserLoginSucceedNotification = @"kUserLoginSucceedNotification";//用户登录成功通知
NSString * const kUserLogoutSucceedNotification = @"kUserLogoutSucceedNotification";//用户退出登录通知

NSString * const kUMComFollowUserSucceedNotification = @"kUMComFollowUserSucceedNotification";

NSString * const kNotificationPostFeedResultNotification = @"kNotificationPostFeedResultNotification";
NSString * const kUMComFeedDeletedFinishNotification = @"kUMComFeedDeletedFinishNotification";
NSString * const kUMComCommentOperationFinishNotification = @"kUMComCommentOperationFinishNotification";
NSString * const kUMComLikeOperationFinishNotification = @"kUMComLikeOperationFinishNotification";
NSString * const kUMComFavouratesFeedOperationFinishNotification = @"kUMComFavouratesFeedOperationFinishNotification";
NSString * const kUMComRemoteNotificationReceivedNotification = @"kUMComRemoteNotificationReceivedNotification";
NSString * const kUMComUnreadNotificationRefreshNotification = @"kUMComUnreadNotificationRefreshNotification";

NSString * const kUMComCommunityInvalidErrorNotification = @"kUMComCommunityInvalidErrorNotification";

@implementation UMComTools

+ (NSInteger)getStringLengthWithString:(NSString *)string
{
    __block NSInteger stringLength = 0;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
     {
         const unichar hs = [substring characterAtIndex:0];
         if (0xd800 <= hs && hs <= 0xdbff)
         {
             if (substring.length > 1)
             {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10;
                 if (0x1d <= uc && uc <= 0x1f77f)
                 {
                     stringLength += 1;
                 }
                 else
                 {
                     stringLength += 1;
                 }
             }
             else
             {
                 stringLength += 1;
             }
         } else if (substring.length > 1)
         {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3)
             {
                 stringLength += 1;
             }
             else
             {
                 stringLength += 1;
             }
         } else {
             if (0x2100 <= hs && hs <= 0x27ff)
             {
                 stringLength += 1;
             }
             else if (0x2B05 <= hs && hs <= 0x2b07)
             {
                 stringLength += 1;
             }
             else if (0x2934 <= hs && hs <= 0x2935)
             {
                 stringLength += 1;
             }
             else if (0x3297 <= hs && hs <= 0x3299)
             {
                 stringLength += 1;
             }
             else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50)
             {
                 stringLength += 1;
             }
             else
             {
                 stringLength += 1;
             }
         }
     }];
    
    return stringLength;
}


+ (UIColor *)colorWithHexString:(NSString *)stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString length] < 6)
        return DEFAULT_VOID_COLOR;
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return DEFAULT_VOID_COLOR;
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}


+ (NSError *)errorWithDomain:(NSString *)domain Type:(NSInteger)type reason:(NSString *)reason
{
    if([reason length])
    {
        return [NSError errorWithDomain:domain code:(NSInteger)type userInfo:@{NSLocalizedFailureReasonErrorKey:reason}];
    }
    else
    {
        return [NSError errorWithDomain:domain code:(NSInteger)type userInfo:nil];
    }
}


//
NSString * createTimeString(NSString * create_time)
{
    if (![create_time isKindOfClass:[NSString class]] || create_time.length == 0) {
        return @"";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSCalendar *calendar =
    [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    [dateFormatter setCalendar:calendar];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *createDate= [dateFormatter dateFromString:create_time];
    if (createDate == nil) {
        return @"";
    }
    NSTimeInterval timeInterval = -[createDate timeIntervalSinceNow];
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponent = [currentCalendar components:NSCalendarUnitYear fromDate:createDate];
    NSDateComponents *currentDateComponent = [currentCalendar components:NSCalendarUnitYear fromDate:[NSDate date]];
    NSDateFormatter *showFormatter = [[NSDateFormatter alloc] init];
    if (dateComponent.year == currentDateComponent.year) {
        [showFormatter setDateFormat:@"MM-dd HH:mm"];
    }else{
        [showFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    NSString * showDate = [showFormatter stringFromDate:createDate];
    NSString *timeDescription = nil;
    float timeValue = timeInterval/60;
    if (timeValue < 1) {
        timeDescription = nil;//[NSString stringWithFormat:@"0 秒前"];
        if (timeValue <= 0) {
            timeDescription = @"0秒前";
            return timeDescription;
            
        }else{
            timeDescription = [NSString stringWithFormat:@"%d秒前",(int)timeInterval];
            return timeDescription;
        }
    }
    if(timeValue >= 1 && timeValue < 60){
        timeDescription = [NSString stringWithFormat:@"%d分钟前",(int)timeValue];
        return timeDescription;
    }
    timeValue = timeValue/60;
    
    if ( timeValue >= 1 && timeValue < 24) {
        timeDescription = [NSString stringWithFormat:@"%d小时前 ",(int)timeValue];
        return timeDescription;
    }
    timeValue = timeValue/24;
    if (timeValue >= 1 && timeValue < 2) {
        timeDescription = [NSString stringWithFormat:@"昨天"];
        return timeDescription;
    }
    else if (timeValue >= 2 && timeValue < 3){
        timeDescription = [NSString stringWithFormat:@"前天"];
        return timeDescription;
    }
    
    timeDescription = showDate;
    
    return timeDescription;
}
@end
