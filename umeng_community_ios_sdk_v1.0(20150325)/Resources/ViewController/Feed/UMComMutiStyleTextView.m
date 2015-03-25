//
//  UMComMutiStyleTextView.m
//  UMCommunity
//
//  Created by umeng on 15-3-5.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComMutiStyleTextView.h"
#import "UMComSyntaxHighlightTextStorage.h"
#import "UMComComment.h"
#import <QuartzCore/QuartzCore.h>
#import "UMComTopic.h"


@interface UMComMutiStyleTextView ()
@property (nonatomic,strong) NSMutableArray *runs;
@property (nonatomic,strong) NSMutableDictionary *runRectDictionary;
@property (nonatomic,strong) UMComMutiTextRun *touchRun;

@end

@implementation UMComMutiStyleTextView
{
//    CTFrameRef _frame;
    CTFrameRef frameRef;
    
}

- (id)init
{
    self = [super init];
    if (self) {
        [self createDefault];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createDefault];
    }
    return self;
}


#pragma mark - CreateDefault

- (void)createDefault
{
    self.textLayer = [CALayer layer];
    UIImage *image = [UIImage imageNamed:@"origin_image_bg"];
    self.textLayer.contents = (id) image.CGImage;
//    [self.layer addSublayer:self.textLayer];
    //public
    self.text        = nil;
    self.font        = [UIFont systemFontOfSize:13.0f];
    self.textColor   = [UIColor blackColor];
    self.runType = UMComMutiTextRunNoneType;//UMComMutiTextRunURLType | UMComMutiTextRunEmojiType;
    self.lineSpace   = 2.0f;
//    self.heightOffset = 0.0f;
    self.attributedText = nil;
    self.pointOffset = CGPointZero;
    //private
    self.runs        = [NSMutableArray array];
    self.runRectDictionary = [NSMutableDictionary dictionary];
    self.touchRun = nil;
    self.clikTextDict = [NSMutableArray arrayWithCapacity:1];
   
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.frame];
    self.backGroundImageView = bgImageView;
}


- (void)awakeFromNib
{
    [self createDefault];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapInCerrentView:)];
    [self addGestureRecognizer:tap];
}


#pragma mark - Draw Rect

- (void)drawRect:(CGRect)rect
{
    if (self.text == nil || self.text.length == 0){
        return;
    }
    [self.runs removeAllObjects];
    [self.runRectDictionary removeAllObjects];
    
    CGRect viewRect = CGRectMake(self.pointOffset.x, -self.pointOffset.y, rect.size.width, rect.size.height);//
    //绘制的文本
    NSMutableAttributedString *attString = nil;
    
    if (self.attributedText == nil)
    {
        attString = [[self class] createAttributedStringWithText:self.text font:self.font lineSpace:self.lineSpace];
    }
    else
    {
        attString = self.attributedText;
    }
    NSArray *runs = [[self class] createTextRunsWithAttString:attString runType:self.runType clickDicts:self.clikTextDict];
    [self.runs addObjectsFromArray:runs];
    
    
    //绘图上下文
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
   
    //修正坐标系
    CGAffineTransform affineTransform = CGAffineTransformIdentity;
    affineTransform = CGAffineTransformMakeTranslation(0.0, viewRect.size.height);
    affineTransform = CGAffineTransformScale(affineTransform, 1.0, -1.0);
    CGContextConcatCTM(contextRef, affineTransform);
    
    //创建一个用来描画文字的路径，其区域为viewRect  CGPath
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, viewRect);
    
    //创建一个framesetter用来管理描画文字的frame  CTFramesetter
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attString);
    
    //创建由framesetter管理的frame，是描画文字的一个视图范围  CTFrame
//    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, 0), pathRef, nil);
    
    //创建由framesetter管理的frame，是描画文字的一个视图范围  CTFrame
   frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, 0), pathRef, nil);
    

    //通过context在frame中描画文字内容
    CTFrameDraw(frameRef, contextRef);
    [self setRunsKeysToRunRect];

    CFRelease(pathRef);
    CFRelease(frameRef);
    CFRelease(framesetterRef);
}

- (void)setRunsKeysToRunRect
{
    CFArrayRef lines = CTFrameGetLines(frameRef);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), lineOrigins);
    
    
    for (int i = 0; i < CFArrayGetCount(lines); i++)
    {
        CTLineRef lineRef= CFArrayGetValueAtIndex(lines, i);
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        CGPoint lineOrigin = CGPointMake(lineOrigins[i].x, lineOrigins[i].y);//
        CTLineGetTypographicBounds(lineRef, &lineAscent, &lineDescent, &lineLeading);
        CFArrayRef runs = CTLineGetGlyphRuns(lineRef);
        
        for (int j = 0; j < CFArrayGetCount(runs); j++)
        {
            CTRunRef runRef = CFArrayGetValueAtIndex(runs, j);
            CGFloat runAscent;
            CGFloat runDescent;
            CGRect runRect;
            
            runRect.size.width = CTRunGetTypographicBounds(runRef, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
            runRect = CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(lineRef, CTRunGetStringRange(runRef).location, NULL),
                                 lineOrigin.y,
                                 runRect.size.width,
                                 runAscent + runDescent);
            
            NSDictionary * attributes = (__bridge NSDictionary *)CTRunGetAttributes(runRef);
            UMComMutiTextRun *mutiTextRun = [attributes objectForKey:UMComMutiTextRunAttributedName];
            if (mutiTextRun.drawSelf)
            {
                CGFloat runAscent,runDescent;
                CGFloat runWidth  = CTRunGetTypographicBounds(runRef, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
                CGFloat runHeight = (lineAscent + lineDescent );
                CGFloat runPointX = runRect.origin.x + lineOrigin.x;
                CGFloat runPointY = lineOrigin.y;
                
                CGRect runRectDraw = CGRectMake(runPointX, runPointY, runWidth, runHeight);
                
                [mutiTextRun drawRunWithRect:runRectDraw];
                
                [self.runRectDictionary setObject:mutiTextRun forKey:[NSValue valueWithCGRect:runRectDraw]];
            }
            else
            {
                if (mutiTextRun)
                {
                    [self.runRectDictionary setObject:mutiTextRun forKey:[NSValue valueWithCGRect:runRect]];
                }
            }
        }
    }
}

#pragma mark - Set
- (void)setText:(NSString *)text
{
    [self setNeedsDisplay];
    _text = text;
}

- (void)setFont:(UIFont *)font
{
//    [self setNeedsDisplay];
    _font = font;
}

- (void)setTextColor:(UIColor *)textColor
{
//    [self setNeedsDisplay];
    _textColor = textColor;
}

- (void)setLineSpace:(CGFloat)lineSpace
{
//    [self setNeedsDisplay];
    _lineSpace = lineSpace;
    
}

- (void)tapInCerrentView:(UITapGestureRecognizer *)tap
{
    CGPoint location = [tap locationInView:self];
    CGPoint runLocation = CGPointMake(location.x-self.pointOffset.x, self.frame.size.height - location.y+self.pointOffset.y+2);
    
    __weak UMComMutiStyleTextView *weakSelf = self;
    
    if (self.clickOnlinkText) {
        [self.runRectDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop){
            CGRect rect = [((NSValue *)key) CGRectValue];
            if(CGRectContainsPoint(rect, runLocation))
            {
                weakSelf.touchRun = object;
                weakSelf.clickOnlinkText(object);
            }
        }];
    }

}

//#pragma mark - Touches
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesBegan:touches withEvent:event];
//    
//    CGPoint location =[(UITouch *)[touches anyObject] locationInView:self];
//    CGPoint runLocation = CGPointMake(location.x, self.frame.size.height - location.y);
//    
//    __weak UMComMutiStyleTextView *weakSelf = self;
//    
//    
//    if (self.clickOnlinkText) {
//        [self.runRectDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop){
//            CGRect rect = [((NSValue *)key) CGRectValue];
//            if(CGRectContainsPoint(rect, runLocation))
//            {
//                weakSelf.touchRun = object;
//                self.clickOnlinkText(object);
//                
//            }
//        }];
//    }
//    
//    
////    if (self.delegage && [self.delegage respondsToSelector:@selector(mutiTextView: touchBeginRun:)])
////    {
////        __weak UMComMutiStyleTextView *weakSelf = self;
////        
////        [self.runRectDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop){
////            
////            CGRect rect = [((NSValue *)key) CGRectValue];
////            if(CGRectContainsPoint(rect, runLocation))
////            {
////                self.touchRun = object;
////                [weakSelf.delegage mutiTextView:weakSelf touchBeginRun:object];
////         
////            }
////        }];
////    }
//    
//
//}

//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesMoved:touches withEvent:event];
//}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesEnded:touches withEvent:event];
//    
//    CGPoint location = [(UITouch *)[touches anyObject] locationInView:self];
//    CGPoint runLocation = CGPointMake(location.x, self.frame.size.height - location.y);
//    
//    if (self.delegage && [self.delegage respondsToSelector:@selector(mutiTextView: touchBeginRun:)])
//    {
//        __weak UMComMutiStyleTextView *weakSelf = self;
//        
//        [self.runRectDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
//            
//            CGRect rect = [((NSValue *)key) CGRectValue];
//            if(CGRectContainsPoint(rect, runLocation))
//            {
//                self.touchRun = obj;
//                [weakSelf.delegage mutiTextView:weakSelf touchEndRun:obj];
//            }
//        }];
//    }
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesCancelled:touches withEvent:event];
//    
//    CGPoint location = [(UITouch *)[touches anyObject] locationInView:self];
//    CGPoint runLocation = CGPointMake(location.x, self.frame.size.height - location.y);
//    
//    if (self.delegage && [self.delegage respondsToSelector:@selector(mutiTextView: touchBeginRun:)])
//    {
//        __weak UMComMutiStyleTextView *weakSelf = self;
//        
//        [self.runRectDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
//            
//            CGRect rect = [((NSValue *)key) CGRectValue];
//            if(CGRectContainsPoint(rect, runLocation))
//            {
//                self.touchRun = obj;
//                [weakSelf.delegage mutiTextView:weakSelf touchCanceledRun:obj];
//            }
//        }];
//    }
//}

//- (UIResponder*)nextResponder
//{
//    [super nextResponder];
//    
//    return self.touchRun;
//}

#pragma mark -

+ (NSMutableAttributedString *)createAttributedStringWithText:(NSString *)text font:(UIFont *)font lineSpace:(CGFloat)lineSpace
{
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:text];
    //设置字体
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    [attString addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)fontRef range:NSMakeRange(0,attString.length)];
    CFRelease(fontRef);
    
    //添加换行模式
    CTParagraphStyleSetting lineBreakMode;
    CTLineBreakMode lineBreak = kCTLineBreakByCharWrapping;
    lineBreakMode.spec        = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakMode.value       = &lineBreak;
    lineBreakMode.valueSize   = sizeof(lineBreak);

    //行距
    CTParagraphStyleSetting lineSpaceStyle;
    lineSpaceStyle.spec = kCTParagraphStyleSpecifierLineSpacing;
    lineSpaceStyle.valueSize = sizeof(lineSpace);
    lineSpaceStyle.value =&lineSpace;
    
//    //创建文本对齐方式
//    CTTextAlignment alignment = 0;//左对齐
//    CTParagraphStyleSetting alignmentStyle;
//    alignmentStyle.spec=kCTParagraphStyleSpecifierAlignment;//指定为对齐属性
//    alignmentStyle.valueSize=sizeof(alignment);
//    alignmentStyle.value=&alignment;
    
    
//    CGFloat LineSpacingAdjustment = 10;//
//    CTParagraphStyleSetting LineSpacingAdjustmentStyle;
//    LineSpacingAdjustmentStyle.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;//
//    LineSpacingAdjustmentStyle.valueSize=sizeof(LineSpacingAdjustment);
//    LineSpacingAdjustmentStyle.value=&LineSpacingAdjustment;
    
    
    CTParagraphStyleSetting settings[] = {lineSpaceStyle,lineBreakMode};
    CTParagraphStyleRef style = CTParagraphStyleCreate(settings, sizeof(settings)/sizeof(settings[0]));
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:(__bridge id)style forKey:(id)kCTParagraphStyleAttributeName ];
    CFRelease(style);
    
    [attString addAttributes:attributes range:NSMakeRange(0, [attString length])];
    
    return attString;
}

+ (NSArray *)createTextRunsWithAttString:(NSMutableAttributedString *)attString runType:(UMComMutiTextRunTypeList)type clickDicts:(NSArray *)dicts
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if (UMComMutiTextRunLikeType == type)
    {
        [array addObjectsFromArray:[UMComMutiTextRunLike runsForAttributedString:attString withClickDicts:dicts]];
    }
    if (UMComMutiTextRunCommentType == type)
    {
        [array addObjectsFromArray:[UMComMutiTextRunComment runsForAttributedString:attString withClickDicts:dicts]];
    }
    if (UMComMutiTextRunFeedContentType == type)
    {
        [array addObjectsFromArray:[UMComMutiTextRunTopic runsForAttributedString:attString topics:dicts]];
    }
    return  array;
}

+ (NSArray *)createTextRunsWithAttString:(NSMutableAttributedString *)attString runTypeList:(UMComMutiTextRunTypeList)typeList
{

    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if (UMComMutiTextRunLikeType == typeList)
    {
        [array addObjectsFromArray:[UMComMutiTextRunLike runsForAttributedString:attString withClickDicts:nil]];
    }
    if (UMComMutiTextRunCommentType == typeList)
    {
        [array addObjectsFromArray:[UMComMutiTextRunComment runsForAttributedString:attString withClickDicts:nil]];
    }
    if (UMComMutiTextRunFeedContentType == typeList)
    {
        [array addObjectsFromArray:[UMComMutiTextRunTopic runsForAttributedString:attString topics:nil]];
    }
    return  array;


}


+ (CGRect)boundingRectWithSize:(CGSize)size font:(UIFont *)font AttString:(NSMutableAttributedString *)attString
{

    if (attString.length == 0) {
        return CGRectMake(0, 0, size.width, 0);
    }
    NSDictionary *dic = [attString attributesAtIndex:0 effectiveRange:nil];
    CTParagraphStyleRef paragraphStyle = (__bridge CTParagraphStyleRef)[dic objectForKey:(id)kCTParagraphStyleAttributeName];
    CGFloat linespace = 0;
    
    CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierLineSpacing, sizeof(linespace), &linespace);
    
    CGFloat height = 0;
    CGFloat width = 0;
    CFIndex lineIndex = 0;
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, CGRectMake(0, 0, size.width, size.height));
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attString);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, 0), pathRef, nil);
    CFArrayRef lines = CTFrameGetLines(frameRef);
    
    lineIndex = CFArrayGetCount(lines);
    
    if (lineIndex > 1)
    {
        for (int i = 0; i <lineIndex ; i++)
        {
            CTLineRef lineRef= CFArrayGetValueAtIndex(lines, i);
            CGFloat lineAscent;
            CGFloat lineDescent;
            CGFloat lineLeading;
            CTLineGetTypographicBounds(lineRef, &lineAscent, &lineDescent, &lineLeading);
            
            if (i == lineIndex - 1)
            {
                height += (lineAscent + lineDescent +linespace);
            }
            else
            {
                height += (lineAscent + lineDescent + linespace);
            }
//            UMLog(@"\nattString:%@,\nlinespace:%f,\nlineAscent:%f,\nlineDescent:%f,\nheight:%f",attString,linespace,lineAscent,lineDescent,height);
        }
        
        width = size.width;
    }
    else
    {
        for (int i = 0; i <lineIndex ; i++)
        {
            CTLineRef lineRef= CFArrayGetValueAtIndex(lines, i);
            CGRect rect = CTLineGetBoundsWithOptions(lineRef,kCTLineBoundsExcludeTypographicShifts);
            width = rect.size.width;
            
            CGFloat lineAscent;
            CGFloat lineDescent;
            CGFloat lineLeading;
            CTLineGetTypographicBounds(lineRef, &lineAscent, &lineDescent, &lineLeading);
            
            height += (lineAscent + lineDescent + lineLeading + linespace);
//            UMLog(@"\nattString:%@,\nlinespace:%f,\nlineAscent:%f,\nlineDescent:%f,\nheight:%f\nlineLeading:%f",attString,linespace,lineAscent,lineDescent,height,lineLeading);

        }
        
        height = height;
    }
    
    CFRelease(pathRef);
    CFRelease(frameRef);
    CFRelease(framesetterRef);
    CGRect rect = CGRectMake(0,0,width,height);
    
    return rect;
}

+ (CGRect)boundingRectWithSize:(CGSize)size font:(UIFont *)font string:(NSString *)string lineSpace:(CGFloat )lineSpace
{
    NSMutableAttributedString *attributedString = [[self class] createAttributedStringWithText:string font:font lineSpace:lineSpace];
    return [[self class] boundingRectWithSize:size font:font AttString:attributedString];
}


+ (NSDictionary *)rectWithSize:(CGSize)size font:(UIFont *)font AttString:(NSString *)string lineSpace:(CGFloat )lineSpace
{
    NSMutableDictionary *frameDict = [NSMutableDictionary dictionaryWithCapacity:1];
    if (!string || string.length == 0) {
        [frameDict setValue:NSStringFromCGRect(CGRectMake(0, 0, size.width, 0)) forKey:@"rect"];
        [frameDict setValue:@0 forKey:@"lineCount"];
        [frameDict setValue:@0 forKey:@"lastLineWidth"];
        [frameDict setValue:@0 forKey:@"lineHeight"];

        return frameDict;
//        return ;
    }
    
    CGFloat shortestLineWith = 0;
    int lineCount = 0;
    
    NSAttributedString *attString = [[self class] createAttributedStringWithText:string font:font lineSpace:lineSpace];
    NSDictionary *dic = [attString attributesAtIndex:0 effectiveRange:nil];
    CTParagraphStyleRef paragraphStyle = (__bridge CTParagraphStyleRef)[dic objectForKey:(id)kCTParagraphStyleAttributeName];
    CGFloat linespace = 0;
    
    CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierLineSpacing, sizeof(linespace), &linespace);
    
    CGFloat height = 0;
    CGFloat width = 0;
    CFIndex lineIndex = 0;
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, CGRectMake(0, 0, size.width, size.height));
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attString);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, 0), pathRef, nil);
    CFArrayRef lines = CTFrameGetLines(frameRef);
    
    lineIndex = CFArrayGetCount(lines);
    lineCount = (int)lineIndex;
    
    if (lineIndex > 1)
    {
        for (int i = 0; i <lineIndex ; i++)
        {
            CTLineRef lineRef= CFArrayGetValueAtIndex(lines, i);
            if (i == lineIndex - 1) {
                CGRect rect = CTLineGetBoundsWithOptions(lineRef,kCTLineBoundsExcludeTypographicShifts);
                shortestLineWith = rect.size.width;
                [frameDict setValue:[NSNumber numberWithFloat:rect.size.height+linespace] forKey:@"lineHeight"];

            }
            CGFloat lineAscent;
            CGFloat lineDescent;
            CGFloat lineLeading;
            CTLineGetTypographicBounds(lineRef, &lineAscent, &lineDescent, &lineLeading);
            
            if (i == lineIndex - 1)
            {
                height += (lineAscent + lineDescent +linespace);
            }
            else
            {
                height += (lineAscent + lineDescent + linespace);
            }
            //            UMLog(@"\nattString:%@,\nlinespace:%f,\nlineAscent:%f,\nlineDescent:%f,\nheight:%f",attString,linespace,lineAscent,lineDescent,height);
        }
        
        width = size.width;
    }
    else
    {
        CTLineRef lineRef= CFArrayGetValueAtIndex(lines, 0);
        CGRect rect = CTLineGetBoundsWithOptions(lineRef,kCTLineBoundsExcludeTypographicShifts);
        shortestLineWith = rect.size.width;
        [frameDict setValue:[NSNumber numberWithFloat:rect.size.height+linespace] forKey:@"lineHeight"];

        width = rect.size.width;
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        CTLineGetTypographicBounds(lineRef, &lineAscent, &lineDescent, &lineLeading);
        
        height += (lineAscent + lineDescent + lineLeading + linespace);
        height = height;
    }
    
    CFRelease(pathRef);
    CFRelease(frameRef);
    CFRelease(framesetterRef);
    CGRect rect = CGRectMake(0,0,width,height);
    [frameDict setValue:[NSNumber numberWithFloat:shortestLineWith] forKey:@"lastLineWidth"];
    [frameDict setValue:NSStringFromCGRect(rect) forKey:@"rect"];
    [frameDict setValue:[NSNumber numberWithInt:lineCount] forKey:@"lineCount"];
    
    return frameDict;
}



//CFIndex CFIndexGet(CGPoint point,CTFrameRef frame){
//    
//    //获取每一行
//    CFArrayRef lines = CTFrameGetLines(frame);
//    CGPoint origins[CFArrayGetCount(lines)];
//    //获取每行的原点坐标
//    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
//    CTLineRef line = NULL;
//    CGPoint lineOrigin = CGPointZero;
//    CGPathRef path = CTFrameGetPath(frame);
//    //获取整个CTFrame的大小
//    CGRect rect = CGPathGetBoundingBox(path);
//    for (int i= 0; i < CFArrayGetCount(lines); i++)
//    {
//        CGPoint origin = origins[i];
//        //坐标转换，把每行的原点坐标转换为uiview的坐标体系
//        CGFloat y = rect.origin.y + rect.size.height - origin.y;
//        //判断点击的位置处于那一行范围内
//        if ((point.y <= y) && (point.x >= origin.x))
//        {
//            line = CFArrayGetValueAtIndex(lines, i);
//            lineOrigin = origin;
//            break;
//        }
//    }
//    point.x -= lineOrigin.x;
//    //获取点击位置所处的字符位置，就是相当于点击了第几个字符
//    CFIndex index = CTLineGetStringIndexForPosition(line, point);
//    return index;
//}

- (void)clickOnLinkText:(id)object inRange:(NSRange)range
{
    
    if (_clickOnlinkText) {
        _clickOnlinkText(object);
    }
}

@end



NSString * const UMComMutiTextRunAttributedName = @"UMComMutiTextRunAttributedName";

@implementation UMComMutiTextRun

/**
 *  向字符串中添加相关Run类型属性
 */
- (void)decorateToAttributedString:(NSMutableAttributedString *)attributedString range:(NSRange)range
{
    if (attributedString.length == 0) {
        return;
    }
    [attributedString addAttribute:UMComMutiTextRunAttributedName value:self range:range];
    
    self.font = [attributedString attribute:NSFontAttributeName atIndex:0 longestEffectiveRange:nil inRange:range];
    
}

/**
 *  绘制Run内容
 */
- (void)drawRunWithRect:(CGRect)rect
{
    
}

@end


@implementation UMComMutiTextRunDelegate

/**
 *  向字符串中添加相关Run类型属性
 */
- (void)decorateToAttributedString:(NSMutableAttributedString *)attributedString range:(NSRange)range
{
    [super decorateToAttributedString:attributedString range:range];
    
    CTRunDelegateCallbacks callbacks;
    callbacks.version    = kCTRunDelegateVersion1;
    callbacks.dealloc    = UMComMutiTextRunDelegateDeallocCallback;
    callbacks.getAscent  = UMComMutiTextRunDelegateGetAscentCallback;
    callbacks.getDescent = UMComMutiTextRunDelegateGetDescentCallback;
    callbacks.getWidth   = UMComMutiTextRunDelegateGetWidthCallback;
    
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callbacks, (__bridge void*)self);
    [attributedString addAttribute:(NSString *)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:range];
    CFRelease(runDelegate);
    
    [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor clearColor].CGColor range:range];
}

#pragma mark - RunCallback

- (void)mutiTextRunDealloc
{
    
}

- (CGFloat)mutiTextRunGetAscent
{
    return self.font.ascender;
}

- (CGFloat)mutiTextRunGetDescent
{
    return self.font.descender;
}

- (CGFloat)mutiTextRunGetWidth
{
    return self.font.ascender - self.font.descender;
}

#pragma mark - RunDelegateCallback

void UMComMutiTextRunDelegateDeallocCallback(void *refCon)
{
    //    UMComMutiTextRunDelegate *run =(__bridge UMComMutiTextRunDelegate *) refCon;
    //
    //    [run mutiTextRunDealloc];
}

//--上行高度
CGFloat UMComMutiTextRunDelegateGetAscentCallback(void *refCon)
{
    UMComMutiTextRunDelegate *run =(__bridge UMComMutiTextRunDelegate *) refCon;
    
    return [run mutiTextRunGetAscent];
}

//--下行高度
CGFloat UMComMutiTextRunDelegateGetDescentCallback(void *refCon)
{
    UMComMutiTextRunDelegate *run =(__bridge UMComMutiTextRunDelegate *) refCon;
    
    return [run mutiTextRunGetDescent];
}

//-- 宽
CGFloat UMComMutiTextRunDelegateGetWidthCallback(void *refCon)
{
    UMComMutiTextRunDelegate *run =(__bridge UMComMutiTextRunDelegate *) refCon;
    
    return [run mutiTextRunGetWidth];
}

@end




@implementation UMComMutiTextRunClickUser

- (void)decorateToAttributedString:(NSMutableAttributedString *)attributedString range:(NSRange)range
{
    if (attributedString.length == 0) {
        return;
    }
    [super decorateToAttributedString:attributedString range:range];
    [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:self.textColor range:range];
}

+ (NSArray *)runsForAttributedString:(NSMutableAttributedString *)attributedString withClickDicts:(NSArray *)dicts
{
    NSMutableArray *runsArr = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *dict in dicts) {
        NSString *key = [dict allKeys].firstObject;
        UMComUser *user = nil;
        id obj = [dict valueForKey:key];
        UMComMutiTextRunClickUser *run = [[UMComMutiTextRunClickUser alloc]init];
        if ([obj isKindOfClass:[UMComUser class]]) {
            user = (UMComUser *)obj;
            run.text = user.name;
            run.user = user;
        }
        run.textColor = [UMComTools colorWithHexString:FontColorBlue];
        run.range = NSRangeFromString(key);
        run.font = UMComFontNotoSansLightWithSafeSize(13);
        [run decorateToAttributedString:attributedString range:run.range];
        [runsArr addObject:run];
    }
    return runsArr;
}



@end





@implementation UMComMutiTextRunLike

- (void)decorateToAttributedString:(NSMutableAttributedString *)attributedString range:(NSRange)range
{
    if (attributedString.length == 0) {
        return;
    }
    [super decorateToAttributedString:attributedString range:range];
//    [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)self.textColor.CGColor range:range];
    [attributedString addAttributes:@{NSFontAttributeName:self.font,NSForegroundColorAttributeName:self.textColor,UMComContentKey:[NSNumber numberWithInt:UMComContentTypeFriend]} range:range];
}

+ (NSArray *)runsForAttributedString:(NSMutableAttributedString *)attributedString withClickDicts:(NSArray *)dicts
{
    NSMutableArray *runsArr = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *dict in dicts) {
        NSString *key = [dict allKeys].firstObject;
        UMComMutiTextRunClickUser *run = [[UMComMutiTextRunClickUser alloc]init];
        id obj = [dict valueForKey:key];

        if ([obj isKindOfClass:[UMComLike class]]) {
            UMComLike *like = (UMComLike *)obj;
            run.text = like.creator.name;
            run.user = like.creator;
        }
        run.textColor = [UMComTools colorWithHexString:FontColorBlue];
        run.font = UMComFontNotoSansLightWithSafeSize(14);
        run.range = NSRangeFromString(key);
        [run decorateToAttributedString:attributedString range:run.range];
        [runsArr addObject:run];
    }
//    [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:[UMComTools colorWithHexString:@"#8e8e93"] range:NSMakeRange(attributedString.length-3, 3)];
    return runsArr;
}

@end



@implementation UMComMutiTextRunComment

- (void)decorateToAttributedString:(NSMutableAttributedString *)attributedString range:(NSRange)range
{
    if (attributedString.length == 0) {
        return;
    }
    [super decorateToAttributedString:attributedString range:range];
//    [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)self.textColor.CGColor range:range];
    [attributedString addAttributes:@{NSFontAttributeName:self.font,NSForegroundColorAttributeName:self.textColor,UMComContentKey:[NSNumber numberWithInt:UMComContentTypeNormal]} range:range];
}

+ (NSArray *)runsForAttributedString:(NSMutableAttributedString *)attributedString withClickDicts:(NSArray *)dicts
{
    NSMutableArray *runsArr = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *dict in dicts) {
        NSString *key = [dict allKeys].firstObject;

        id obj = [dict valueForKey:key];
        if ([obj isKindOfClass:[UMComUser class]]) {
           UMComMutiTextRunClickUser *run = [[UMComMutiTextRunClickUser alloc]init];
            UMComUser *user = (UMComUser *)obj;
            run.user = user;
            run.text = user.name;
            run.textColor = [UMComTools colorWithHexString:FontColorBlue];
            run.range = NSRangeFromString(key);
            run.font = UMComFontNotoSansLightWithSafeSize(13);
            [run decorateToAttributedString:attributedString range:run.range];
            [runsArr addObject:run];
        }else if([obj isKindOfClass:[UMComComment class]]){
            UMComComment *comment = (UMComComment *)obj;
            UMComMutiTextRunComment *run = [[UMComMutiTextRunComment alloc]init];
            run.text = comment.content;
            run.comment = comment;
            run.textColor = [UIColor blackColor];
            run.range = NSRangeFromString(key);
            run.font = UMComFontNotoSansLightWithSafeSize(13);
            [run decorateToAttributedString:attributedString range:run.range];
            [runsArr addObject:run];
        }
    }
    return runsArr;
}

@end



@implementation UMComMutiTextRunTopic

/**
 *  向字符串中添加相关Run类型属性
 */
- (void)decorateToAttributedString:(NSMutableAttributedString *)attributedString range:(NSRange)range
{
    if (attributedString.length == 0) {
        return;
    }
    [super decorateToAttributedString:attributedString range:range];
    [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:self.textColor range:range];
}

/**
 *  解析字符串中名字和话题内容生成Run对象
 *
 *  @param attributedString 内容
 *
 *  @return UMComMutiTextRunURL对象数组
 */
+ (NSArray *)runsForAttributedString:(NSMutableAttributedString *)attributedString topics:(NSArray *)clikTextDicts
{
    
    NSString *string = attributedString.string;
    NSMutableArray *array = [NSMutableArray array];
    NSError *error = nil;
    
    UIColor *blueColor = [UMComTools colorWithHexString:FontColorBlue];
    
    
    for (NSDictionary *dict in clikTextDicts) {
        NSArray *topics = [dict valueForKey:@"topics"];
        NSString *regulaStr = TopicRulerString;//\\u4e00-\\u9fa5_a-zA-Z0-9
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        if (error == nil)
        {
            NSArray *arrayOfAllMatches = [regex matchesInString:string
                                                        options:0
                                                          range:NSMakeRange(0, [string length])];
            for (NSTextCheckingResult *match in arrayOfAllMatches)
            {
                NSString* substringForMatch = [string substringWithRange:match.range];
                for (UMComTopic *topic in topics) {
                    NSString *topicName = [NSString stringWithFormat:@"#%@#",topic.name];
                    if ([substringForMatch isEqualToString:topicName]) {
                        UMComMutiTextRunTopic *run = [[UMComMutiTextRunTopic alloc] init];
                        run.range       = match.range;
                        run.text     = substringForMatch;
                        run.drawSelf = NO;
                        run.textColor = blueColor;
                        [run decorateToAttributedString:attributedString range:match.range];
                        [array addObject:run];
                        break;
                    }
                }
            }
        }
    
 /*********************************************************************************************/
        NSArray *related_users = [dict valueForKey:@"related_user"];
        
        
        NSString *userNameRegulaStr = UserRulerString;//@"(@[\\u4e00-\\u9fa5_a-zA-Z0-9]+)";
        NSRegularExpression *userNameRegex = [NSRegularExpression regularExpressionWithPattern:userNameRegulaStr
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:&error];
        if (error == nil)
        {
            NSArray *arrayOfAllMatches = [userNameRegex matchesInString:string
                                                                options:0
                                                                  range:NSMakeRange(0, [string length])];
            for (NSTextCheckingResult *match in arrayOfAllMatches)
            {
                NSString* substringForMatch = [string substringWithRange:match.range];
                
                for (UMComUser *user in related_users) {
                    NSString *userName = [NSString stringWithFormat:@"@%@",user.name];
                    if ([substringForMatch isEqualToString:userName]) {
                        UMComMutiTextRunClickUser *run = [[UMComMutiTextRunClickUser alloc] init];
                        run.range    = match.range;
                        run.text     = substringForMatch;
                        run.drawSelf = NO;
                        run.textColor = blueColor;
                        [run decorateToAttributedString:attributedString range:match.range];
                        [array addObject:run];
                        break;
                    }
                }
            }
        }
        
    }
    

    return array;
}


@end






@implementation UMComMutiTextRunURL

/**
 *  向字符串中添加相关Run类型属性
 */
- (void)decorateToAttributedString:(NSMutableAttributedString *)attributedString range:(NSRange)range
{
    if (attributedString.length == 0) {
        return;
    }
    [super decorateToAttributedString:attributedString range:range];
    [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor blueColor].CGColor range:range];
}

/**
 *  解析字符串中url内容生成Run对象
 *
 *  @param attributedString 内容
 *
 *  @return UMComMutiTextRunURL对象数组
 */
+ (NSArray *)runsForAttributedString:(NSMutableAttributedString *)attributedString
{
    NSString *string = attributedString.string;
    NSMutableArray *array = [NSMutableArray array];
    
    NSError *error = nil;;
    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error == nil)
    {
        NSArray *arrayOfAllMatches = [regex matchesInString:string
                                                    options:0
                                                      range:NSMakeRange(0, [string length])];
        
        for (NSTextCheckingResult *match in arrayOfAllMatches)
        {
            NSString* substringForMatch = [string substringWithRange:match.range];
            
            UMComMutiTextRunURL *run = [[UMComMutiTextRunURL alloc] init];
            run.range    = match.range;
            run.text     = substringForMatch;
            run.drawSelf = NO;
            [run decorateToAttributedString:attributedString range:match.range];
            [array addObject:run ];
        }
    }
    
    return array;
}


@end




@implementation UMComMutiTextRunEmoji

/**
 *  返回表情数组
 */
+ (NSArray *) emojiStringArray
{
    return [NSArray arrayWithObjects:@"[smile]",@"[cry]",@"[hei]",nil];
}

/**
 *  解析字符串中url内容生成Run对象
 *
 *  @param attributedString 内容
 *
 *  @return UMComMutiTextRunURL对象数组
 */
+ (NSArray *)runsForAttributedString:(NSMutableAttributedString *)attributedString
{
    NSString *markL       = @"[";
    NSString *markR       = @"]";
    NSString *string      = attributedString.string;
    NSMutableArray *array = [NSMutableArray array];
    NSMutableArray *stack = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < string.length; i++)
    {
        NSString *s = [string substringWithRange:NSMakeRange(i, 1)];
        
        if (([s isEqualToString:markL]) || ((stack.count > 0) && [stack[0] isEqualToString:markL]))
        {
            if (([s isEqualToString:markL]) && ((stack.count > 0) && [stack[0] isEqualToString:markL]))
            {
                [stack removeAllObjects];
            }
            
            [stack addObject:s];
            
            if ([s isEqualToString:markR] || (i == string.length - 1))
            {
                NSMutableString *emojiStr = [[NSMutableString alloc] init];
                for (NSString *c in stack)
                {
                    [emojiStr appendString:c];
                }
                
                if ([[UMComMutiTextRunEmoji emojiStringArray] containsObject:emojiStr])
                {
                    NSRange range = NSMakeRange(i + 1 - emojiStr.length, emojiStr.length);
                    
                    [attributedString replaceCharactersInRange:range withString:@" "];
                    
                    UMComMutiTextRunEmoji *run = [[UMComMutiTextRunEmoji alloc] init];
                    run.range    = NSMakeRange(i + 1 - emojiStr.length, 1);
                    run.text     = emojiStr;
                    run.drawSelf = YES;
                    [run decorateToAttributedString:attributedString range:run.range];
                    
                    [array addObject:run];
                }
                
                [stack removeAllObjects];
            }
        }
    }
    
    return array;
}

/**
 *  绘制Run内容
 */
- (void)drawRunWithRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSString *emojiString = [NSString stringWithFormat:@"%@.png",self.text];
    
    UIImage *image = [UIImage imageNamed:emojiString];
    if (image)
    {
        CGContextDrawImage(context, rect, image.CGImage);
    }
}

@end
