//
//  UMComEditForwardView.m
//  UMCommunity
//
//  Created by umeng on 15/11/20.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComEditForwardView.h"
#import "UMComImageView.h"
#import "UMComEditTextView.h"
#import "UMComTools.h"



@implementation UMComEditForwardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)reloadViewsWithText:(NSString *)text checkWords:(NSArray *)checkWords urlString:(NSString *)urlString
{
    [self.forwardImageView removeFromSuperview];
    [self.forwardEditTextView removeFromSuperview];
    self.forwardEditTextView.placeholderLabel.text = @" 说说你的观点...";
    NSArray *regexArray = [NSArray arrayWithObjects:UserRulerString, TopicRulerString,UrlRelerSring, nil];
    if (urlString) {
        self.forwardImageView = [[[UMComImageView imageViewClassName] alloc] initWithFrame:CGRectMake(self.frame.size.width-75, self.frame.size.height/2-35+3, 70, 70)];
        self.forwardImageView.isAutoStart = YES;
        self.forwardImageView.backgroundColor = [UIColor clearColor];
        [self.forwardImageView setImageURL:urlString placeHolderImage:UMComImageWithImageName(@"photox")];
        self.forwardEditTextView = [[UMComEditTextView alloc]initWithFrame:CGRectMake(5, 5, self.frame.size.width-self.forwardImageView.frame.size.width-5, self.frame.size.height-5) checkWords:checkWords regularExStrArray:regexArray];
        [self addSubview:self.forwardImageView];
    }else{
        self.forwardEditTextView = [[UMComEditTextView alloc]initWithFrame:CGRectMake(5, 5, self.frame.size.width-10, self.frame.size.height-5) checkWords:checkWords regularExStrArray:regexArray];
    }
    UIImage *resizableImage = [UMComImageWithImageName(@"origin_image_bg") resizableImageWithCapInsets:UIEdgeInsetsMake(20, 50, 0, 0)];
    self.image = resizableImage;
    self.forwardEditTextView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.forwardEditTextView];
    self.userInteractionEnabled = YES;
    self.forwardEditTextView.checkWords = checkWords;
    [self.forwardEditTextView setFont:UMComFontNotoSansLightWithSafeSize(15)];
    self.forwardEditTextView.text = text;
    self.forwardEditTextView.editable = NO;
    [self.forwardEditTextView updateEditTextView];
}

@end


