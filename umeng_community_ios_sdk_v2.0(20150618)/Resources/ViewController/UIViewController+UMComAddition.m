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


const char tipLabelKey;

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
//    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName] style:UIBarButtonItemStylePlain target:self action:action];
    UMComBarButtonItem *rightButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:imageName target:self action:action];
//    rightButtonItem.customView.frame = CGRectMake(0, 0, 40, 35);
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


- (void)showShareCollectionViewWithShareListView:(UMComShareCollectionView *)shareListView bgView:(UIView *)bgView
{
    __weak UIViewController *weakSelf = self;
    __weak UMComShareCollectionView *weakShareListView = shareListView;
    shareListView.didSelectedIndex = ^(NSIndexPath *indexPath){
        __strong UMComShareCollectionView *strongShareList = weakShareListView;
        [weakSelf hidenShareListView:strongShareList bgView:bgView];
    };
    shareListView.shareViewController = self;
    [self.view.window addSubview:bgView];
    [self.view.window addSubview:shareListView];
    [shareListView reloadData];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        shareListView.frame = CGRectMake(shareListView.frame.origin.x, self.view.window.frame.size.height-shareListView.frame.size.height, shareListView.frame.size.width, shareListView.frame.size.height);
    } completion:nil];
    
}
- (UIView *)createdShadowBgView
{

    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIApplication sharedApplication].keyWindow.frame.size.width, [UIApplication sharedApplication].keyWindow.frame.size.height)];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.2;
    return bgView;
}

- (void)hidenShareListView:(UMComShareCollectionView *)shareListView bgView:(UIView *)view
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        shareListView.frame = CGRectMake(shareListView.frame.origin.x, self.view.window.frame.size.height+64, shareListView.frame.size.width, shareListView.frame.size.height);
        [view removeFromSuperview];
    } completion:^(BOOL finished) {
        [shareListView removeFromSuperview];
    }];
}


- (void)showTipLableFromTopWithTitle:(NSString *)title
{
    UILabel *tipLabel = objc_getAssociatedObject(self, &tipLabelKey);//[self creatTipLabelWithTitle:title];
    if (!tipLabel) {
       tipLabel = [self creatTipLabelWithTitle:title];
    }
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

- (UILabel *)creatTipLabelWithTitle:(NSString *)title
{
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, -40, self.view.frame.size.width, 40)];
    tipLabel.text = title;
    tipLabel.backgroundColor = [UMComTools colorWithHexString:FontColorBlue];
    tipLabel.alpha = 0.8;
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.font = UMComFontNotoSansLightWithSafeSize(16);
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];
    objc_setAssociatedObject(self, &tipLabelKey, tipLabel, OBJC_ASSOCIATION_ASSIGN);
    return tipLabel;
}

- (void)transitionToFeedDetailViewControllerWithFeed:(UMComFeed *)feed showType:(UMComFeedDetailShowType)showType
{
    UMComFeedDetailViewController * feedDetailViewController = [[UMComFeedDetailViewController alloc] initWithFeed:feed showFeedDetailShowType:showType];
    [self.navigationController pushViewController:feedDetailViewController animated:YES];
}
@end
