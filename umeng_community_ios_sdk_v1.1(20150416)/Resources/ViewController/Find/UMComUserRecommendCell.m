//
//  UMComUserRecommendCell.m
//  UMCommunity
//
//  Created by umeng on 15-3-31.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComUserRecommendCell.h"
#import "UMComHttpManager.h"
#import "UMComUserCenterViewModel.h"
#import "UMComShowToast.h"

@implementation UMComUserRecommendCell

- (void)awakeFromNib {
    // Initialization code
    self.genderImageView.clipsToBounds = YES;
    self.genderImageView.layer.cornerRadius = self.genderImageView.frame.size.width/2;
    self.isHotUser = NO;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapAtThissView:)];
    [self addGestureRecognizer:tap];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)didTapAtThissView:(UIGestureRecognizer *)tap
{
    if (self.onClickAtCellViewAction) {
        self.onClickAtCellViewAction(self.user);
    }
}

- (void)displayWithUser:(UMComUser *)user isHotUser:(BOOL)isHotUser
{
    self.user = user;
    NSString *iconUrl = [user.icon_url valueForKey:@"240"];
    self.portrait.layer.cornerRadius = self.portrait.frame.size.width/2;
    self.portrait.clipsToBounds = YES;
    if ([user.gender intValue] == 0) {
        [self.portrait setPlaceholderImage:[UIImage imageNamed:@"female"]];
    } else{
        [self.portrait setPlaceholderImage:[UIImage imageNamed:@"male"]];
    }
    [self.portrait setImageURL:[NSURL URLWithString:iconUrl]];
    [self.portrait startImageLoad];
    [self.userName setText:user.name];
    self.descriptionLable.text =  [NSString stringWithFormat:@"发消息：%@ / 粉丝：%@",user.post_count,user.fans_count];
    
    CGSize textSize = [self.userName.text sizeWithFont:self.userName.font forWidth:self.descriptionLable.frame.size.width lineBreakMode:NSLineBreakByCharWrapping];
    self.genderImageView.frame = CGRectMake(20+textSize.width+self.portrait.frame.size.width, self.genderImageView.frame.origin.y, self.genderImageView.frame.size.width, self.genderImageView.frame.size.height);
    if ([user.gender intValue] == 1) {
        self.genderImageView.image = [UIImage imageNamed:@"♀.png"];
        
    }else{
        self.genderImageView.image = [UIImage imageNamed:@"♂.png"];
    }
    if (isHotUser) {
        self.isHotUser = YES;
        BOOL isFollow = [self.user.is_follow boolValue];
        [self changeFocusButton:self.focusButton isFollow:isFollow];
    }
}


- (IBAction)onClickFocusButton:(id)sender {
  
    BOOL isDelete = NO;
    if (self.isHotUser) {
        BOOL isFollow = [self.user.is_follow boolValue];
        if (isFollow) {
            isDelete = YES;
        }
    }
    [UMComHttpManager userFollow:self.user.uid isDelete:isDelete response:^(id responseObject, NSError *error) {
        if (!error) {
            if (isDelete == NO) {
                [self.user setValue:@1 forKey:@"is_follow"];
            }else{
                [self.user setValue:@0 forKey:@"is_follow"];
            }
            [self changeFocusButton:self.focusButton isFollow:!isDelete];
        }else{
            if (isDelete == NO) {
                if ([[[error.userInfo valueForKey:@"err_code"] description] isEqualToString:@"err_code"]) {
                    [self changeFocusButton:self.focusButton isFollow:!YES];
                }else{

                }
            }else{
            }
            [UMComShowToast focusUserFail:error];
        }
    }];
}

- (void)changeFocusButton:(UIButton *)focusButtun isFollow:(BOOL)isFollow
{
    if (isFollow) {
        [focusButtun setBackgroundColor:[UMComTools colorWithHexString:ViewGrayColor]];
        [focusButtun setTitle:UMComLocalizedString(@"has_been_followed" ,@"已关注") forState:UIControlStateNormal];
    }else{
        [focusButtun setBackgroundColor:[UMComTools colorWithHexString:ViewGreenBgColor]];
        [focusButtun setTitle:UMComLocalizedString(@"follow" ,@"关注") forState:UIControlStateNormal];
    }
}

@end
