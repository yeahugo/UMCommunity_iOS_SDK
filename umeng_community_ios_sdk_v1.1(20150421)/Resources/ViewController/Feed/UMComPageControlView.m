//
//  UMComPageControlView.m
//  UMCommunity
//
//  Created by umeng on 15-4-20.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComPageControlView.h"
#import "UMComTools.h"

@interface UMComPageControlView ()
@property (nonatomic,strong) NSMutableDictionary *pageNumDictionary;
@property (nonatomic,strong) NSMutableArray *pageNumArray;

@end

@implementation UMComPageControlView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.pageNumDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
        self.pageNumArray = [NSMutableArray arrayWithCapacity:1];
        self.unselectedColor = [UMComTools colorWithHexString:FontColorGray];
        self.selectedColor = [UMComTools colorWithHexString:FontColorBlue];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame totalPages:(NSInteger)totalPages currentPage:(NSInteger)currentPage
{
    self = [self initWithFrame:frame];
    if (self) {
        self.currentPage = currentPage;
        self.totalPages = totalPages;
    }
    return self;
}

- (void)resetPages
{
    CGFloat numberHeight = self.frame.size.height;
    CGFloat space = (self.frame.size.width - numberHeight*_totalPages)/(_totalPages +1);
    
    if (self.pageNumArray.count < _totalPages) {
        for (int index = (int)self.pageNumArray.count; index<_totalPages; index++) {
            UMComPageNumberView *pageNumView = [[UMComPageNumberView alloc]initWithFrame:CGRectMake(index*(space+numberHeight)+space, 0, numberHeight, numberHeight)];
            [self.pageNumArray addObject:pageNumView];
            [self addSubview:pageNumView];
        }
    }else{
        for (int index = (int)_totalPages; index< self.pageNumArray.count; index++) {
            UMComPageNumberView *pageNumView = self.pageNumArray[index];
            [self.pageNumArray removeObjectAtIndex:index];
            [pageNumView removeFromSuperview];
        }
    }
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    if (currentPage < self.pageNumArray.count) {
        _currentPage = currentPage;
        [self reloadPages];
    }
}


- (void)setTotalPages:(NSInteger)totalPages
{
    _totalPages = totalPages;
    [self resetPages];
}

- (void)setUnselectedColor:(UIColor *)unselectedColor
{
    _unselectedColor = unselectedColor;
    [self reloadPages];
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;
    [self reloadPages];
}

- (void)reloadPages
{
    for (int index = 0; index < self.pageNumArray.count; index++) {
        UMComPageNumberView *view = self.pageNumArray[index];
        if (index == self.currentPage) {
            view.numberColor = _selectedColor;
        }else{
            view.numberColor = _unselectedColor;
        }
        [view setNeedsDisplay];
    }
}

@end


@implementation UMComPageNumberView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Border
//    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetFillColorWithColor(context, self.numberColor.CGColor);
    CGContextFillEllipseInRect(context, self.bounds);
    // Body
    CGContextSetFillColorWithColor(context, self.numberColor.CGColor);
    CGContextFillEllipseInRect(context, CGRectInset(self.bounds, 1.0, 1.0));
    // Checkmark
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetLineWidth(context, 0.5);
    CGContextStrokePath(context);
}



@end