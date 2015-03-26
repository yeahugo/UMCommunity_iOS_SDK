//
//  UMComBarButtonItem.m
//  UMCommunity
//
//  Created by luyiyuan on 14/10/9.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComBarButtonItem.h"
#import "UMComButton.h"
#import "UMComTools.h"

@implementation UMComBarButtonItem

- (id)initWithNormalImageName:(NSString *)imageName target:(id)target action:(SEL)action
{
    if(![imageName length]){
        return nil;
    }
    
    UMComButton *button = [[UMComButton alloc] initWithNormalImageName:imageName target:target action:action];
    
    self = [super initWithCustomView:button];
    
    
    if(self){
        
    }
    
    return self;
}

- (id)initWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    if(![title length]){
        return nil;
    }
    
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 60, 35)];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UMComTools colorWithHexString:FontColorBlue] forState:UIControlStateNormal];

    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    self = [super initWithCustomView:button];
    
    return self;
}

@end
