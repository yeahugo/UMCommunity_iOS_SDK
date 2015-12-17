//
//  UMComGenderView.m
//  UMCommunity
//
//  Created by luyiyuan on 14/10/17.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComGenderView.h"
#import "UMComTools.h"

static inline NSString *getImageNameWithGender(UMComUserGender gender)
{
    switch (gender) {
        case UMComUserGenderFemale:
            return @"♀.png";
            break;
        case UMComUserGenderMale:
            return @"♂.png";
            break;
        default:
            return nil;
            break;
    }
    
    return nil;
}

static inline NSString *getGenderNameWithGender(UMComUserGender gender)
{
    switch (gender) {
        case UMComUserGenderFemale:
            return UMComLocalizedString(@"Female", @"女");
            break;
        case UMComUserGenderMale:
            return UMComLocalizedString(@"Male", @"男");
            break;
        default:
            return nil;
            break;
    }
    
    return nil;
}

@implementation UMComGenderView

+ (NSString *)genderName:(UMComUserGender)genderType
{
    return getGenderNameWithGender(genderType);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithGender:(UMComUserGender)gender
{
    UIImage *image = UMComImageWithImageName(getImageNameWithGender(gender));
    self = [super initWithFrame:CGRectMake(0, 0, 15, 15)];
    
    if(self){
        self.image = image;
    }
    
    return self;
}

- (void)setUserGender:(UMComUserGender)gender
{
    self.image = UMComImageWithImageName(getImageNameWithGender(gender));
}
@end
