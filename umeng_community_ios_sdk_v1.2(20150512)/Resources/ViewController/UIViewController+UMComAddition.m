//
//  UIViewController+UMComAddition.m
//  UMCommunity
//
//  Created by umeng on 15/5/8.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UIViewController+UMComAddition.h"
#import "UMComTools.h"

@implementation UIViewController (UMComAddition)


- (void)setBackButtonWithTitle:(NSString *)title
{
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
        self.navigationController.navigationItem.leftBarButtonItem = nil;
        UIBarButtonItem *backButtonItem = [[UMComBarButtonItem alloc] initWithTitle:title target:self action:@selector(goBack)];
        backButtonItem.customView.frame = CGRectMake(0, 0, 40, 35);
        self.navigationItem.leftBarButtonItem = backButtonItem;
    }
}
- (void)setBackButtonWithImageName:(NSString *)imageName
{
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
        self.navigationController.navigationItem.leftBarButtonItem = nil;
        UIBarButtonItem *backButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:imageName target:self action:@selector(goBack)];
        backButtonItem.customView.frame = CGRectMake(0, 0, 40, 35);
        self.navigationItem.leftBarButtonItem = backButtonItem;
    }
}

- (void)setLeftButtonWithTitle:(NSString *)title action:(SEL)action
{
    UIBarButtonItem *backButtonItem = [[UMComBarButtonItem alloc] initWithTitle:title target:self action:@selector(action)];
    backButtonItem.customView.frame = CGRectMake(0, 0, 40, 35);
    self.navigationItem.leftBarButtonItem = backButtonItem;
}
- (void)setLeftButtonWithImageName:(NSString *)imageName action:(SEL)action
{
    UIBarButtonItem *backButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:imageName target:self action:@selector(goBack)];
    backButtonItem.customView.frame = CGRectMake(0, 0, 40, 35);
    self.navigationItem.leftBarButtonItem = backButtonItem;
}

- (void)setRightButtonWithTitle:(NSString *)title action:(SEL)action
{
    UIBarButtonItem *rightButtonItem = [[UMComBarButtonItem alloc] initWithTitle:title target:self action:action];
    rightButtonItem.customView.frame = CGRectMake(0, 0, 40, 35);
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)setRightButtonWithImageName:(NSString *)imageName action:(SEL)action
{
    UIBarButtonItem *rightButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:imageName target:self action:action];
    rightButtonItem.customView.frame = CGRectMake(0, 0, 40, 35);
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)setCustomButtonWithFrame:(CGRect)frame title:(NSString *)title action:(SEL)action
{
    UMComButton *rightButton = [UMComButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:frame];
    [rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [rightButton setTitle:title forState:UIControlStateNormal];
    [rightButton setTitleColor:[UMComTools colorWithHexString:FontColorBlue] forState:UIControlStateNormal];
    [rightButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:rightButton];
}


- (void)setCustomButtonWithFrame:(CGRect)frame imageName:(NSString *)imageName action:(SEL)action
{
     UMComButton *rightButton = [[UMComButton alloc]initWithNormalImageName:imageName target:self action:action];
    rightButton.frame = frame;
    [self.navigationController.navigationBar addSubview:rightButton];
}

- (void)setTitleViewWithTitle:(NSString *)title
{
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, self.view.frame.size.width-120, 60)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = UMComFontNotoSansLightWithSafeSize(18);
    titleLabel.text= title;
    titleLabel.textColor = [UIColor blackColor];
    [self.navigationItem setTitleView:titleLabel];
}

- (void)goBack
{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
        
        }];
    }
}
@end
