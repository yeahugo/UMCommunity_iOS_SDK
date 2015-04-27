//
//  UMComPageControlView.h
//  UMCommunity
//
//  Created by umeng on 15-4-20.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UMComPageControlView : UIView

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, assign) NSInteger totalPages;

@property (nonatomic, strong) UIColor *selectedColor;

@property (nonatomic, strong) UIColor *unselectedColor;


- (id)initWithFrame:(CGRect)frame totalPages:(NSInteger)totalPages currentPage:(NSInteger)currentPage;
//刷新pages
- (void)reloadPages;

@end


@interface UMComPageNumberView : UIView

@property (nonatomic, strong) UIColor *numberColor;

@end