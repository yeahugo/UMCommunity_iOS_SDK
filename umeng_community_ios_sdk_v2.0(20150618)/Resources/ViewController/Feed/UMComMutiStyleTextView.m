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
#import "UMComLike.h"
#import "UMComUser.h"

@implementation UMComMutiStyleTextView

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

- (void)setMutiStyleTextViewProperty:(UMComMutiStyleTextView *)styleTextView
{
    self.attributedText = styleTextView.attributedText;
    self.framesetterRef = styleTextView.framesetterRef;
    self.frameRef = styleTextView.frameRef;
    self.pathRef = styleTextView.pathRef;
    self.runs = styleTextView.runs;
    [self setNeedsDisplay];
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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapInCerrentView:)];
    [self addGestureRecognizer:tap];
}


#pragma mark - Set
- (void)setText:(NSString *)text
{
    [self setNeedsDisplay];

    _text = text;
}


- (void)awakeFromNib
{
    [self createDefault];

}

#pragma mark - Draw Rect

- (void)drawRect:(CGRect)rect
{
    //绘图上下文
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    if (self.attributedText == nil || self.attributedText.length == 0 ){
        return;
    }

    CGRect viewRect = CGRectMake(self.pointOffset.x, -self.pointOffset.y, rect.size.width, rect.size.height);//
    //修正坐标系
    CGAffineTransform affineTransform = CGAffineTransformIdentity;
    affineTransform = CGAffineTransformMakeTranslation(0.0, viewRect.size.height);
    affineTransform = CGAffineTransformScale(affineTransform, 1.0, -1.0);
    CGContextConcatCTM(contextRef, affineTransform);
    
    //创建一个用来描画文字的路径，其区域为viewRect  CGPath
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, viewRect);

    self.frameRef = CTFramesetterCreateFrame(self.framesetterRef, CFRangeMake(0, 0), pathRef, nil);
    //通过context在frame中描画文字内容
    CTFrameDraw(self.frameRef, contextRef);
    [self.runRectDictionary removeAllObjects];
    [self setRunsKeysToRunRect];

    CFRelease(pathRef);
}

- (void)setRunsKeysToRunRect
{
    CFArrayRef lines = CTFrameGetLines(self.frameRef);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(self.frameRef, CFRangeMake(0, 0), lineOrigins);
    
    
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


- (void)tapInCerrentView:(UITapGestureRecognizer *)tap
{
    CGPoint location = [tap locationInView:self];
    CGPoint runLocation = CGPointMake(location.x-self.pointOffset.x, self.frame.size.height - location.y+self.pointOffset.y+2);
    
    __weak UMComMutiStyleTextView *weakSelf = self;
    if (self.clickOnlinkText) {
        if (self.runRectDictionary.count > 0) {
            BOOL isInclude = NO;
            
            for (NSValue *key in [self.runRectDictionary allKeys]) {
                id object = [self.runRectDictionary objectForKey:key];                
                CGRect rect = [((NSValue *)key) CGRectValue];
                if(CGRectContainsPoint(rect, runLocation))
                {
                    isInclude = YES;
                    weakSelf.touchRun = (UMComMutiTextRun *)object;
                    break;
                }
            }
            if (isInclude == YES) {
                weakSelf.clickOnlinkText(self,weakSelf.touchRun);
            }else{
                weakSelf.clickOnlinkText(self,nil);
            }
//            [self.runRectDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop){
//
//
//            }];
        }else{
            weakSelf.clickOnlinkText(self,nil);
        }

    }

}


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
    
//    //设置字体间距
//    CGFloat number = 1.5;
//    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault, kCFNumberCGFloatType, &number);
//    [attString addAttribute:(id)kCTKernAttributeName value:(__bridge id)num range:NSMakeRange(0, [attString length])];
//    CFRelease(num);
    
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

+ (UMComMutiStyleTextView *)rectDictionaryWithSize:(CGSize)size
                                              font:(UIFont *)font
                                         attString:(NSString *)string
                                         lineSpace:(CGFloat )lineSpace
                                           runType:(UMComMutiTextRunTypeList)runType
                                        clickArray:(NSMutableArray *)clickArray
{
    UMComMutiStyleTextView * styleTextView = [[UMComMutiStyleTextView alloc] init];
    styleTextView.runType = runType;
    styleTextView.clikTextDict = clickArray;
    [styleTextView rectDictionaryWithSize:size font:font attString:string lineSpace:lineSpace];
    return styleTextView;
}

- (void)rectDictionaryWithSize:(CGSize)size font:(UIFont *)font attString:(NSString *)string lineSpace:(CGFloat )lineSpace
{
    if (!string || string.length == 0) {
        return;
    }
    CGFloat shortestLineWith = 0;
    int lineCount = 0;
    NSMutableAttributedString *attString = [[self class] createAttributedStringWithText:string font:font lineSpace:lineSpace];
    NSDictionary *dic = [attString attributesAtIndex:0 effectiveRange:nil];
    CTParagraphStyleRef paragraphStyle = (__bridge CTParagraphStyleRef)[dic objectForKey:(id)kCTParagraphStyleAttributeName];
    CGFloat linespace = 0;
    
    CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierLineSpacing, sizeof(linespace), &linespace);
    
    CGFloat height = 0;
    CGFloat width = 0;
    CFIndex lineIndex = 0;
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, CGRectMake(0, 0, size.width, size.height));
    
    NSArray *runs = [[self class] createTextRunsWithAttString:attString runType:self.runType clickDicts:self.clikTextDict];
    self.runs = runs;
    
    self.framesetterRef = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attString);
    self.frameRef = CTFramesetterCreateFrame(_framesetterRef, CFRangeMake(0, 0), pathRef, nil);
    self.pathRef = pathRef;
    CFArrayRef lines = CTFrameGetLines(_frameRef);
    
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
                self.lineHeight = rect.size.height + lineSpace;
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
        }
        width = size.width;
    }
    else
    {
        CTLineRef lineRef= CFArrayGetValueAtIndex(lines, 0);
        CGRect rect = CTLineGetBoundsWithOptions(lineRef,kCTLineBoundsExcludeTypographicShifts);
        shortestLineWith = rect.size.width;
        self.lineHeight = rect.size.height + linespace;

        width = rect.size.width;
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        CTLineGetTypographicBounds(lineRef, &lineAscent, &lineDescent, &lineLeading);
        
        height += (lineAscent + lineDescent + lineLeading + linespace);
        height = height;
    }
    
    CGRect rect = CGRectMake(0,0,width,height);
    self.totalHeight = height;
    self.lastLineWidth = shortestLineWith;
    self.frame = rect;
    self.lineCount = lineCount;
    self.attributedText = attString;
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
//    if (range.length + range.location > attributedString.length) {
//        return;
//    }
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
//    if (range.length + range.location > attributedString.length) {
//        return;
//    }
    [super decorateToAttributedString:attributedString range:range];
//    [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)self.textColor.CGColor range:range];
    [attributedString addAttributes:@{NSFontAttributeName:self.font,NSForegroundColorAttributeName:self.textColor,UMComContentKey:[NSNumber numberWithInt:UMComContentTypeNormal]} range:range];
}

+ (NSArray *)runsForAttributedString:(NSMutableAttributedString *)attributedString withClickDicts:(NSArray *)dicts
{
    NSMutableArray *runsArr = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *dict in dicts) {
        NSString *key = [dict allKeys].lastObject;

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
