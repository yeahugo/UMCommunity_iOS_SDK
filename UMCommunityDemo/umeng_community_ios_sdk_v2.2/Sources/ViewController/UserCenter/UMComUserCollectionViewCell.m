//
//  UMComUserCollectionViewCell.m
//  UMCommunity
//
//  Created by umeng on 15/5/6.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComUserCollectionViewCell.h"
#import "UMComTools.h"
#import "UMComUser.h"
#import "UMComImageView.h"
#import "UMComUser+UMComManagedObject.h"

@implementation UMComUserCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat imageHeight = frame.size.height/2;
        CGFloat labelHeigth = imageHeight/2;
        self.portrait = [[[UMComImageView imageViewClassName] alloc]initWithFrame:CGRectMake(frame.size.width/2-imageHeight/2, labelHeigth/2, imageHeight, imageHeight)];
        self.portrait.clipsToBounds = YES;
        self.portrait.layer.cornerRadius = imageHeight/2;
        [self.contentView addSubview:self.portrait];
        
        self.userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(2, labelHeigth/2+imageHeight, frame.size.width-4, labelHeigth)];
        self.userNameLabel.font = UMComFontNotoSansLightWithSafeSize(12);
        self.userNameLabel.textAlignment = NSTextAlignmentCenter;
        self.userNameLabel.backgroundColor = [UIColor clearColor];
        self.userNameLabel.textColor = [UMComTools colorWithHexString:FontColorGray];
        [self.contentView addSubview:self.userNameLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickAtUser:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)clickAtUser:(id)sender
{
    if (self.clickAtUser) {
        self.clickAtUser(self.user);
    }
}

- (void)showWithUser:(UMComUser *)user
{
    if (!user) {
        self.portrait.hidden = YES;
        self.userNameLabel.hidden = YES;
        return;
    }else{
        self.portrait.hidden = NO;
        self.userNameLabel.hidden = NO;
    }
    self.user = user;
    NSString *iconURL = [user iconUrlStrWithType:UMComIconSmallType];
    [self.portrait setImageURL:iconURL placeHolderImage:[UMComImageView placeHolderImageGender:user.gender.integerValue]];
    if (user.name) {
        self.userNameLabel.text = user.name;   
    }
}

@end
