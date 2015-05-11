//
//  UIViewController+UMComAddition.h
//  UMCommunity
//
//  Created by umeng on 15/5/8.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComBarButtonItem.h"

@interface UIViewController (UMComAddition)
- (void)setBackButtonWithTitle:(NSString *)title;
- (void)setBackButtonWithImageName:(NSString *)imageName;

- (void)setLeftButtonWithTitle:(NSString *)title action:(SEL)action;
- (void)setLeftButtonWithImageName:(NSString *)imageName action:(SEL)action;

- (void)setRightButtonWithTitle:(NSString *)title action:(SEL)action;
- (void)setRightButtonWithImageName:(NSString *)imageName action:(SEL)action;

- (void)setCustomButtonWithFrame:(CGRect)frame title:(NSString *)title action:(SEL)action;
- (void)setCustomButtonWithFrame:(CGRect)frame imageName:(NSString *)imageName action:(SEL)action;


- (void)setTitleViewWithTitle:(NSString *)title;


@end
