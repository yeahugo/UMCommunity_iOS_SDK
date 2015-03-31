//
//  UMComLabel.h
//  UMCommunity
//
//  Created by luyiyuan on 14/10/15.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UMComLabel : UILabel
- (id)initWithFont:(UIFont *)font;
- (id)initWithText:(NSString *)text font:(UIFont *)font;
- (void)setText:(NSString *)text;
@end
