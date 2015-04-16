//
//  UMComBarButtonItem.h
//  UMCommunity
//
//  Created by luyiyuan on 14/10/9.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UMComBarButtonItem : UIBarButtonItem
- (id)initWithNormalImageName:(NSString *)imageName target:(id)target action:(SEL)action;
- (id)initWithTitle:(NSString *)title target:(id)target action:(SEL)action;
@end
