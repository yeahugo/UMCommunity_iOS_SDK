//
//  UIView+UMComTipLabel.m
//  UMCommunity
//
//  Created by umeng on 15/8/1.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UIView+UMComTipLabel.h"
#import <objc/runtime.h>
#import "UMComTools.h"
const char kCentreTipLabelKey;

@implementation UIView (UMComTipLabel)



- (void)showTipLableInViewCentreWithTitle:(NSString *)title
{
    UILabel *centreTipLabel = objc_getAssociatedObject(self, &kCentreTipLabelKey);
    if (!centreTipLabel) {
        centreTipLabel = [self creatTipLabel];
        centreTipLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        objc_setAssociatedObject(self, &kCentreTipLabelKey, centreTipLabel, OBJC_ASSOCIATION_ASSIGN);
    }
    centreTipLabel.text = title;
    centreTipLabel.hidden = NO;
}

- (void)hidenTipLableInViewCentre
{
    UILabel *centreTipLabel = objc_getAssociatedObject(self, &kCentreTipLabelKey);
    centreTipLabel.hidden = YES;
}

- (UILabel *)creatTipLabel
{
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, -40, self.frame.size.width, 40)];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.textColor = [UIColor blackColor];
    tipLabel.alpha = 0.8;
    tipLabel.font = UMComFontNotoSansLightWithSafeSize(16);
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:tipLabel];
    return tipLabel;
}

- (void)showTipLableInViewCentreWithData:(NSArray *)data error:(NSError *)error message:(NSString *)message{
    if (!error) {
        if (data.count > 0) {
            [self hidenTipLableInViewCentre];
        }else{
            NSString *messageStr = message;
            if (!messageStr) {
                messageStr = UMComLocalizedString(@"no_data", @"暂时没有数据咯");
            }
            [self showTipLableInViewCentreWithTitle:messageStr];
        }
    }else{
        if (data.count > 0) {
            [self hidenTipLableInViewCentre];
        }else{
            [self showTipLableInViewCentreWithTitle:UMComLocalizedString(@"Network_Error", @"网络不给力哦，下拉可以再次刷新")];
        }
    }
}



@end
