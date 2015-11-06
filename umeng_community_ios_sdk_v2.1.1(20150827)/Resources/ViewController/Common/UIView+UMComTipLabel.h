//
//  UIView+UMComTipLabel.h
//  UMCommunity
//
//  Created by umeng on 15/8/1.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (UMComTipLabel)

- (void)showTipLableInViewCentreWithTitle:(NSString *)title;

- (void)hidenTipLableInViewCentre;

- (void)showTipLableInViewCentreWithData:(NSArray *)data error:(NSError *)error message:(NSString *)message;

@end
