//
//  UMComSyntaxHighlightTextStorage.m
//  UMCommunity
//
//  Created by luyiyuan on 14/9/24.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComSyntaxHighlightTextStorage.h"
#import "UMComMutiStyleTextView.h"
#import "UMComTopic.h"

static NSDictionary *_replacements = nil;

@implementation UMComSyntaxHighlightTextStorage
{
    NSMutableAttributedString *_backingStore;
}

- (id)init
{
    if (self = [super init]) {
        _backingStore = [NSMutableAttributedString new];
        [self createHighlightPatterns];
    }
    return self;
}


-(void)update {
    // update the highlight patterns
    [self createHighlightPatterns];
    
    // change the 'global' font
    NSDictionary* bodyFont = @{ NSForegroundColorAttributeName : [UIColor blackColor]};
    [self addAttributes:bodyFont
                  range:NSMakeRange(0, self.length)];
    
    // re-apply the regex matches
    [self applyStylesToRange:NSMakeRange(0, self.length)];
 
}


- (NSString *)string
{
    return [_backingStore string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location
                     effectiveRange:(NSRangePointer)range
{
    return [_backingStore attributesAtIndex:location
                             effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
//    NSLog(@"replaceCharactersInRange:%@ withString:%@", NSStringFromRange(range), str);
    
    [self beginEditing];
    [_backingStore replaceCharactersInRange:range withString:str];
    [self  edited:NSTextStorageEditedCharacters | NSTextStorageEditedAttributes
            range:range
   changeInLength:str.length - range.length];
    [self endEditing];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
//    NSLog(@"setAttributes:%@ range:%@", attrs, NSStringFromRange(range));
    
    [self beginEditing];
    [_backingStore setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}


- (void)processEditing
{
    [self performReplacementsForRange:[self editedRange]];
    [super processEditing];
}

- (void)performReplacementsForRange:(NSRange)changedRange
{
    NSRange extendedRange = NSUnionRange(changedRange, [[_backingStore string]
                                                lineRangeForRange:NSMakeRange(NSMaxRange(changedRange), 0)]);
    [self applyStylesToRange:extendedRange];
}


- (void)applyStylesToRange:(NSRange)searchRange
{
    // iterate over each replacement
    for (NSString* key in _replacements) {
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:key
                                      options:0
                                      error:nil];
        
        NSDictionary* attributes = _replacements[key];
        
        if (self.updateBlock) {
            self.updateBlock([regex matchesInString:[_backingStore string] options:0 range:searchRange],key);
        }
        __weak typeof(self) weakSelf = self;
        [regex enumerateMatchesInString:[_backingStore string]
                                options:0
                                  range:searchRange
                             usingBlock:^(NSTextCheckingResult *match,
                                          NSMatchingFlags flags,
                                          BOOL *stop){
                                 
                                 NSRange matchRange = NSMakeRange(match.range.location, match.range.length);
                                 NSString *matchText = [_backingStore.string substringWithRange:matchRange];
                                 for (NSString *item in weakSelf.chectWords) {
                                     if ([item isEqualToString:matchText]) {
                                         NSMutableDictionary *newAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
                                         [newAttributes setValue:[NSString stringWithFormat:@"%@",matchText] forKey:UMComContent];
                                         [weakSelf addAttributes:newAttributes range:matchRange];
                                     }
                                 }
                             }];
    }
}

- (void) createHighlightPatterns {
    UIColor *blueColor = [UMComTools colorWithHexString:FontColorBlue];
    NSDictionary* topicTextAttricbutes =
    @{ NSForegroundColorAttributeName : blueColor,@"contentType":[NSString stringWithFormat:@"%d",UMComContentTypeTopic]};
    NSDictionary * atTextAttricbutes = @{ NSForegroundColorAttributeName : blueColor,UMComContentKey:[NSString stringWithFormat:@"%d",UMComContentTypeFriend]};
    //原 @"(#([\\u4e00-\\u9fa5_a-zA-Z0-9\\]+)#)"//@"(#([^#]+)#)"
    _replacements = @{
                      TopicRulerString : topicTextAttricbutes,
                      UserRulerString: atTextAttricbutes};
}

@end
