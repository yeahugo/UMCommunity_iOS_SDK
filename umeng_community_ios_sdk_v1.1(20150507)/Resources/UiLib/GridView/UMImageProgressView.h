//
//  UMImageViewWithProgress.h
//  UMCommunity
//
//  Created by luyiyuan on 14/9/3.
//  Copyright (c) 2014年 luyiyuan. All rights reserved.
//

#import "UMImageView.h"



@interface UMImageProgressView : UMImageView <UMImageViewDelegate>

- (void)setThumImageViewUrl:(NSString *)urlString;
@property (nonatomic, strong) UMImageView *thumImageView;

@end
