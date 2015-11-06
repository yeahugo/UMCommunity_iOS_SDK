//
//  UMComGenderView.h
//  UMCommunity
//
//  Created by luyiyuan on 14/10/17.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,UMComUserGender)
{
    UMComUserGenderFemale,
    UMComUserGenderMale,
};

@interface UMComGenderView : UIImageView

+ (NSString *)genderName:(UMComUserGender)genderType;

- (id)initWithGender:(UMComUserGender)gender;
- (void)setUserGender:(UMComUserGender)gender;

@end
