//
//  UIViewController+UMComAddition.m
//  UMCommunity
//
//  Created by umeng on 15/5/8.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UIViewController+UMComAddition.h"
#import "UMComTools.h"
#import <objc/runtime.h>
#import "UMComBarButtonItem.h"
#import "UMComShareCollectionView.h"


const char kTopTipLabelKey;

@implementation UIViewController (UMComAddition)


- (void)setBackButtonWithTitle:(NSString *)title
{
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0 || self.navigationController.viewControllers.count == 1) {
        self.navigationController.navigationItem.leftBarButtonItem = nil;
        UIBarButtonItem *backButtonItem = [[UMComBarButtonItem alloc] initWithTitle:title target:self action:@selector(goBack)];
        backButtonItem.customView.frame = CGRectMake(0, 0, 40, 35);
        self.navigationItem.leftBarButtonItem = backButtonItem;
    }
}

- (void)setBackButtonWithImage
{
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0 || self.navigationController.viewControllers.count <= 1) {
        self.navigationController.navigationItem.leftBarButtonItem = nil;
        UMComBarButtonItem *backButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"Backx" target:self action:@selector(goBack)];
        backButtonItem.customView.frame = CGRectMake(0, 0, 40, 35);
        backButtonItem.customButtonView.frame = CGRectMake(5, 0, 20, 20);
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
    UMComBarButtonItem *backButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:imageName target:self action:@selector(goBack)];
    backButtonItem.customView.frame = CGRectMake(0, 0, 40, 35);
    backButtonItem.customButtonView.frame = CGRectMake(0, 0, 20, 20);
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
    UMComBarButtonItem *rightButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:imageName target:self action:action];
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

- (void)showTipLableFromTopWithTitle:(NSString *)title
{
    UILabel *tipLabel = objc_getAssociatedObject(self, &kTopTipLabelKey);//[self creatTipLabelWithTitle:title];
    if (!tipLabel) {
       tipLabel = [self creatTipLabel];
        tipLabel.backgroundColor = [UMComTools colorWithHexString:FontColorBlue];
        tipLabel.textColor = [UIColor whiteColor];
        objc_setAssociatedObject(self, &kTopTipLabelKey, tipLabel, OBJC_ASSOCIATION_ASSIGN);
    }
    tipLabel.text = title;
    tipLabel.frame = CGRectMake(0, -40, tipLabel.frame.size.width, tipLabel.frame.size.height);
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        tipLabel.frame = CGRectMake(0, 0, tipLabel.frame.size.width, tipLabel.frame.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
            tipLabel.frame = CGRectMake(0, -40, tipLabel.frame.size.width, tipLabel.frame.size.height);
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (UILabel *)creatTipLabel
{
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, -40, self.view.frame.size.width, 40)];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.textColor = [UIColor blackColor];
    tipLabel.alpha = 0.8;
    tipLabel.font = UMComFontNotoSansLightWithSafeSize(16);
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];
    return tipLabel;
}

@end
