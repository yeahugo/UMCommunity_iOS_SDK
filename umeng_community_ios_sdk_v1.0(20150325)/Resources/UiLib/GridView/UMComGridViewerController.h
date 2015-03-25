//
//  UMComGridViewerController.h
//  UMCommunity
//
//  Created by luyiyuan on 14/9/2.
//  Copyright (c) 2014年 luyiyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMImageView.h"

@interface UMComGridViewerController : UIViewController<UIScrollViewDelegate,UMImageViewDelegate>

- (id)initWithArray:(NSArray *)array index:(NSUInteger)index;

- (void)setArray:(NSArray *)array index:(NSUInteger)index;

//默认一周（60*60*24*7）
- (void)setCacheSecondes:(NSTimeInterval)secondes;

- (void)startDownload;
@end
