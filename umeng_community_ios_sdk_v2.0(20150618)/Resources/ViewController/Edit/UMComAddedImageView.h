//
//  UMComAddedImageView.h
//  UMCommunity
//
//  Created by luyiyuan on 14/9/11.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PickerHandleAction)(void);

@interface UMComAddedImageView : UIScrollView
@property (nonatomic,copy) PickerHandleAction pickerAction;
@property (nonatomic,strong,readonly) NSMutableArray *arrayImages;
@property (nonatomic,copy) void (^imagesChangeFinish)(void);
@property (nonatomic,copy) void (^imagesDeleteFinish)(NSInteger index);
@property (nonatomic,copy) void (^actionWithTapImages)(void);

@property (nonatomic,assign,readonly) CGFloat imageSpace;

- (void)setScreemWidth:(float)screemWidth;
- (id)initWithUIImages:(NSArray *)images screenWidth:(float)screenWidth;
- (void)setOrign:(CGPoint)orign;
- (void)addImages:(NSArray *)images;
@end
