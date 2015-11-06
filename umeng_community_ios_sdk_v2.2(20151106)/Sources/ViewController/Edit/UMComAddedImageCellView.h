//
//  UMComAddedImageCellView.h
//  UMCommunity
//
//  Created by luyiyuan on 14/9/17.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UMComAddedImageCellView;

typedef void (^DeleteHandle)(UMComAddedImageCellView *iv);

@interface UMComAddedImageCellView : UIImageView

@property (nonatomic) NSUInteger curIndex;
@property (nonatomic,copy) DeleteHandle handle;

- (void)setIndex:(NSUInteger)index cellPad:(float)cellPad;

- (void)setIndex:(NSUInteger)index cellPad:(float)cellPad imageWidth:(CGFloat)imageWidth;

@end
