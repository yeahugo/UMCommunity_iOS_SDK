//
//  UMComLabel.m
//  UMCommunity
//
//  Created by luyiyuan on 14/10/15.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComLabel.h"
#import "UMComTools.h"

@interface UMComLabel ()
//@property (nonatomic,strong) UIFont *font;
@end

@implementation UMComLabel

- (id)initWithFont:(UIFont *)font
{
    self = [super init];
    
    if(self){
        if(font){
            self.font = font;
        }
    }
    
    return self;
}
- (id)initWithText:(NSString *)text font:(UIFont *)font
{
    if(![text length]){
        return nil;
    }
    
    self = [self initWithFont:font];
    
    if(self){
        [self setText:text];
    }
    
    return self;
}

- (void)setText:(NSString *)text
{
    
    if(![text length]){
        return;
    }
    
    CGSize size = [text sizeWithFont:self.font];
    
    [self setFrame:CGRectMake(0, 0, size.width, size.height+4)];
    
    [super setText:text];
    
    self.textColor = [UMComTools colorWithHexString:FontColorGray];
}

- (void)setText:(NSString *)text rect:(CGRect)rect
{
    
    if(![text length]){
        return;
    }
    
    CGSize size = [text sizeWithFont:self.font];
    
    [self setFrame:CGRectMake(0, 0, size.width, size.height+4)];
    
    [super setText:text];
    
    self.textColor = [UMComTools colorWithHexString:FontColorGray];
}
@end
