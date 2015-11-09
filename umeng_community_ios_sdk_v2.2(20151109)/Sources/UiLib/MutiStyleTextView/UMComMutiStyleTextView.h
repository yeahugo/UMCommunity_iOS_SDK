//
//  UMComMutiStyleTextView.h
//  UMCommunity
//
//  Created by umeng on 15-3-5.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "UMComMutiTextRun.h"


typedef NS_OPTIONS(NSUInteger, UMComMutiTextRunTypeList)
{
    UMComMutiTextRunNoneType  = 0,
    UMComMutiTextRunLikeType = 1,
    UMComMutiTextRunCommentType = 2,
    UMComMutiTextRunFeedContentType = 3,
};


@class UMComMutiTextRunDelegate,UMComMutiTextRun,UMComMutiStyleTextView;

@interface UMComMutiStyleTextView : UIView

@property (nonatomic, strong) NSMutableArray *checkWords;

@property (nonatomic, copy) void (^clickOnlinkText)(UMComMutiStyleTextView *mutiStyleTextView,UMComMutiTextRun *run);

@property (nonatomic,copy)   NSString              *text;       // default is nil
@property (nonatomic,copy)   NSMutableAttributedString *attributedText;
@property (nonatomic,strong) UIFont                *font;       // default is nil (system font 17 plain)
@property (nonatomic,strong) UIColor               *textColor;  // default is nil (text draws black)
@property (nonatomic,assign) UMComMutiTextRunTypeList runType;
@property (nonatomic,assign) CGFloat               lineSpace;
@property (nonatomic,assign) CGFloat               totalHeight;
@property (nonatomic,assign) CGPoint               pointOffset;

@property (nonatomic) id framesetterRef;


@property (nonatomic,strong) NSArray *runs;
@property (nonatomic,strong) NSMutableDictionary *runRectDictionary;
@property (nonatomic,strong) UMComMutiTextRun *touchRun;

- (void)setMutiStyleTextViewProperty:(UMComMutiStyleTextView *)styleTextView;

+ (UMComMutiStyleTextView *)rectDictionaryWithSize:(CGSize)size
                                              font:(UIFont *)font
                                         attString:(NSString *)string
                                         lineSpace:(CGFloat )lineSpace
                                           runType:(UMComMutiTextRunTypeList)runType
                                        checkWords:(NSMutableArray *)checkWords;


@end






