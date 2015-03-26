//
//  UMComMutiStyleTextView.h
//  UMCommunity
//
//  Created by umeng on 15-3-5.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "UMComLike.h"
#import "UMComUser.h"

#define TopicRulerString @"(#([^#]+)#)"
#define UserRulerString @"(@[\\u4e00-\\u9fa5_a-zA-Z0-9]+)"


typedef NS_OPTIONS(NSUInteger, UMComMutiTextRunTypeList)
{
    UMComMutiTextRunNoneType  = 0,
    UMComMutiTextRunLikeType = 1,
    UMComMutiTextRunCommentType = 2,
    UMComMutiTextRunFeedContentType = 3,
    UMComMutiTextRunURLType = 4,
    UMComMutiTextRunEmojiType = 5,
    
};


@class UMComMutiTextRunDelegate;
@class UMComMutiTextRun;
@class UMComMutiStyleTextView;

@protocol UMComMutiStyleTextViewDelegate<NSObject>

@optional
- (void)richTextView:(UMComMutiStyleTextView *)view touchBeginRun:(UMComMutiTextRun *)run;
- (void)richTextView:(UMComMutiStyleTextView *)view touchEndRun:(UMComMutiTextRun *)run;
- (void)richTextView:(UMComMutiStyleTextView *)view touchCanceledRun:(UMComMutiTextRun *)run;

@end


@interface UMComMutiStyleTextView : UIView


@property (nonatomic, strong) NSMutableArray *clikTextDict;

@property (nonatomic, copy) void (^clickOnlinkText)(UMComMutiTextRun *run);

@property (nonatomic, strong) UIImageView *backGroundImageView;

@property (nonatomic, strong) UIImage *showImage;

@property(nonatomic,weak) id<UMComMutiStyleTextViewDelegate> delegage;

@property (nonatomic,copy)   NSString              *text;       // default is nil
@property (nonatomic,copy)   NSMutableAttributedString *attributedText;
@property (nonatomic,strong) UIFont                *font;       // default is nil (system font 17 plain)
@property (nonatomic,strong) UIColor               *textColor;  // default is nil (text draws black)
@property (nonatomic,assign) UMComMutiTextRunTypeList runType;
@property (nonatomic,assign) CGFloat               lineSpace;
//@property (nonatomic,assign) CGFloat               heightOffset;
@property (nonatomic,assign) CGPoint               pointOffset;


@property (nonatomic, strong) CALayer *textLayer;

+ (NSMutableAttributedString *)createAttributedStringWithText:(NSString *)text font:(UIFont *)font lineSpace:(CGFloat)lineSpace;

+ (NSArray *)createTextRunsWithAttString:(NSMutableAttributedString *)attString runTypeList:(UMComMutiTextRunTypeList)typeList;

+ (NSArray *)createTextRunsWithAttString:(NSMutableAttributedString *)attString runType:(UMComMutiTextRunTypeList)type clickDicts:(NSMutableArray *)dicts;

+ (CGRect)boundingRectWithSize:(CGSize)size font:(UIFont *)font AttString:(NSMutableAttributedString *)attString;

+ (CGRect)boundingRectWithSize:(CGSize)size font:(UIFont *)font string:(NSString *)string lineSpace:(CGFloat )lineSpace;

+ (NSDictionary *)rectWithSize:(CGSize)size font:(UIFont *)font AttString:(NSString *)string lineSpace:(CGFloat )lineSpace;

@end




//**********************************文字单元CTRun*************************************

extern NSString * const UMComMutiTextRunAttributedName;

@interface UMComMutiTextRun : UIResponder

/**
 *  文本单元内容
 */
@property (nonatomic,copy  ) NSString *text;

/**
 *  文本单元字体
 */
@property (nonatomic,strong) UIFont   *font;

/**
 *  文本单元颜色
 */
@property (nonatomic,strong) UIColor   *textColor;


/**
 *  文本单元在字符串中的位置
 */
@property (nonatomic,assign) NSRange  range;


/**
 *  是否自己绘制自己
 */
@property(nonatomic,getter = isDrawSelf) BOOL drawSelf;

/**
 *  向字符串中添加相关Run类型属性
 */
- (void)decorateToAttributedString:(NSMutableAttributedString *)attributedString range:(NSRange)range;

/**
 *  绘制Run内容
 */
- (void)drawRunWithRect:(CGRect)rect;

@end

//**********************************UMComMutiTextRunDelegate******************************************


@interface UMComMutiTextRunDelegate : UMComMutiTextRun

@end


//********************点击用户名CTRun*************************************
@interface UMComMutiTextRunClickUser : UMComMutiTextRun

@property (nonatomic, strong) UMComUser *user;

+ (NSArray *)runsForAttributedString:(NSMutableAttributedString *)attributedString withClickDicts:(NSArray *)dicts;

@end




//**********************************点击喜欢的人的姓名*************************************

@interface UMComMutiTextRunLike : UMComMutiTextRun

@property (nonatomic, strong) UMComLike *like;

+ (NSArray *)runsForAttributedString:(NSMutableAttributedString *)attributedString withClickDicts:(NSArray *)dicts;

@end


//******************评论*************************************

@interface UMComMutiTextRunComment : UMComMutiTextRun

@property (nonatomic, strong) UMComComment *comment;

+ (NSArray *)runsForAttributedString:(NSMutableAttributedString *)attributedString withClickDicts:(NSArray *)dicts;

@end


//******************话题*************************************

@interface UMComMutiTextRunTopic : UMComMutiTextRun

@property (nonatomic, strong) UMComTopic *topic;

+ (NSArray *)runsForAttributedString:(NSMutableAttributedString *)attributedString topics:(NSArray *)topics;
@end



//**********************************暂时没有用到*************************************************
@interface UMComMutiTextRunURL : UMComMutiTextRun

/**
 *  解析字符串中url内容生成Run对象
 *
 *  @param attributedString 内容
 *
 *  @return UMComMutiTextRunURL对象数组
 */
+ (NSArray *)runsForAttributedString:(NSMutableAttributedString *)attributedString;

@end


@interface UMComMutiTextRunEmoji : UMComMutiTextRunDelegate

/**
 *  解析字符串中url内容生成Run对象
 *
 *  @param attributedString 内容
 *
 *  @return UMComMutiTextRunURL对象数组
 */
+ (NSArray *)runsForAttributedString:(NSMutableAttributedString *)attributedString;

@end


