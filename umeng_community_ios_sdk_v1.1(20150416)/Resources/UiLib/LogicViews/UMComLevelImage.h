//
//  UMComLevelImage.h
//  UMCommunity
//
//  Created by luyiyuan on 14/10/17.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,UMComUserLevel)
{
    UMComUserLevelQingTong,
    UMComUserLevelBaiying,
    UMComUserLevelhuangjin,
    UMComUserLevelHuangguan,
    UMComUserLevelDefault = UMComUserLevelQingTong,
};

@interface UMComLevelImage : UIImageView
- (id)initWithLevel:(UMComUserLevel)level;
- (void)setUserLevel:(UMComUserLevel)level;
@end
