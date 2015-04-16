//
//  UMComActionDeleteView.m
//  UMCommunity
//
//  Created by luyiyuan on 14/9/16.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComActionDeleteView.h"

@implementation UMComActionDeleteView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
//        self.userInteractionEnabled = YES;
    }
    return self;
}


- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(24.0, 24.0);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Border
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextFillEllipseInRect(context, self.bounds);
    
    // Body
    CGContextSetRGBFillColor(context, 1.0, 0, 0, 1.0);
    CGContextFillEllipseInRect(context, CGRectInset(self.bounds, 1.0, 1.0));
    
    // Checkmark
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetLineWidth(context, 1.2);
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    CGContextMoveToPoint(context, center.x- self.bounds.size.width/4,center.y);
    CGContextAddLineToPoint(context, center.x + self.bounds.size.width/4,center.y);
    
    CGContextStrokePath(context);
}


@end
