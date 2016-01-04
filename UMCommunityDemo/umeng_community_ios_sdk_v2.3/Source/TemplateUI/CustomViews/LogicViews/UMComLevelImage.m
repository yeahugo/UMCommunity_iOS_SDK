//
//  UMComLevelImage.m
//  UMCommunity
//
//  Created by luyiyuan on 14/10/17.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComLevelImage.h"
#import "UMComTools.h"

static inline NSString *getImageNameWithLevel(UMComUserLevel level)
{
    switch (level) {
        case UMComUserLevelQingTong:
            return @"qingtongx";
            break;
        case UMComUserLevelBaiying:
            return @"baiyingx";
            break;
        case UMComUserLevelhuangjin:
            return @"huangjinx";
            break;
        case UMComUserLevelHuangguan:
            return @"huangguanx";
            break;
        default:
            return nil;
            break;
    }
    
    return nil;
}

@implementation UMComLevelImage

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithLevel:(UMComUserLevel)level
{
    UIImage *image = UMComImageWithImageName(getImageNameWithLevel(level));
    self = [super initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    if(self){
        self.image = image;
    }
    
    return self;
}
- (void)setUserLevel:(UMComUserLevel)level
{
    self.image = UMComImageWithImageName(getImageNameWithLevel(level));
}
@end
