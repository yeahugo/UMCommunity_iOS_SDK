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
#import "UMComSession.h"

@interface UMComUserRecommendCell ()

@end

@implementation UMComUserRecommendCell

- (void)awakeFromNib {
    // Initialization code
    self.genderImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -5, 15, 15)];
    [self.userName addSubview:self.genderImageView];
    self.genderImageView.clipsToBounds = YES;
    self.genderImageView.layer.cornerRadius = self.genderImageView.frame.size.width/2;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapAtThissView:)];
    [self addGestureRecognizer:tap];
    
    UMComImageView *portrait = [[[UMComImageView imageViewClassName] alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
    self.portrait = portrait;
    [self.contentView addSubview:self.portrait];
    
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

- (void)displayWithUser:(UMComUser *)user userType:(UMComUserType)userType
{
    self.userType = userType;
    self.user = user;
    NSString *iconUrl = [user.icon_url valueForKey:@"240"];
    self.portrait.layer.cornerRadius = self.portrait.frame.size.width/2;
    self.portrait.clipsToBounds = YES;
    [self.portrait setImageURL:iconUrl placeHolderImage:[UMComImageView placeHolderImageGender:user.gender.integerValue]];
    [self.userName setText:user.name];
    NSNumber *post_count = user.post_count;
    NSNumber *fans_count = user.fans_count;
    if (!post_count) {
        post_count = @0;
    }
    if (!fans_count) {
        fans_count = @0;
    }
    self.descriptionLable.text =  [NSString stringWithFormat:@"发消息:%@ / 粉丝:%@",post_count,fans_count];
    CGSize textSize = [self.userName.text sizeWithFont:self.userName.font constrainedToSize:CGSizeMake(self.userName.frame.size.width, self.userName.frame.size.height) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat originX = textSize.width;
    if (textSize.width >= self.userName.frame.size.width-5) {
        originX-= 5;
    }
    self.genderImageView.frame = CGRectMake(originX+5, self.genderImageView.frame.origin.y, self.genderImageView.frame.size.width, self.genderImageView.frame.size.height);
    if ([user.gender intValue] == 0) {
        self.genderImageView.image = [UIImage imageNamed:@"♀.png"];
        
    }else{
        self.genderImageView.image = [UIImage imageNamed:@"♂.png"];
    }
    if (self.userType != UMComReccommentUser) {
        BOOL isFollow = [self.user.is_follow boolValue];
        [self changeFocusButton:self.focusButton isFollow:isFollow];
    }
}


- (IBAction)onClickFocusButton:(id)sender {
  
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    BOOL isDelete = [self.user.is_follow boolValue];
    [UMComHttpManager userFollow:self.user.uid isDelete:isDelete response:^(id responseObject, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (!error) {
            [self changeFocusButton:self.focusButton isFollow:!isDelete];
        }else{
            if (self.userType == UMComTopicHotUser) {
                if (isDelete == NO) {
                    if ([[[error.userInfo valueForKey:@"err_code"] description] isEqualToString:@"err_code"]) {
                        [self changeFocusButton:self.focusButton isFollow:!YES];
                    }else{
                        
                    }
                }else{
                }
            }else{
                if (isDelete == NO) {
                    if ([[[error.userInfo valueForKey:@"NSLocalizedFailureReason"] description] isEqualToString:@"user has been followed"]) {
                        [self changeFocusButton:self.focusButton isFollow:YES];
                    }else{
                        [self changeFocusButton:self.focusButton isFollow:NO];
                    }
                }else{
                }
            }

            [UMComShowToast focusUserFail:error];
        }
    }];
}

- (void)changeFocusButton:(UIButton *)focusButtun isFollow:(BOOL)isFollow
{
    if (isFollow) {
        [focusButtun setBackgroundColor:[UMComTools colorWithHexString:ViewGrayColor]];
        UIColor *bcolor = [UIColor colorWithRed:15.0/255.0 green:121.0/255.0 blue:254.0/255.0 alpha:1];
        [focusButtun setTitleColor:bcolor forState:UIControlStateNormal];
        [focusButtun setTitle:UMComLocalizedString(@"has_been_followed" ,@"已关注") forState:UIControlStateNormal];
        [self.user setHaveFollow];
    }else{
        [focusButtun setBackgroundColor:[UMComTools colorWithHexString:ViewGreenBgColor]];
        [focusButtun setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [focusButtun setTitle:UMComLocalizedString(@"follow" ,@"关注") forState:UIControlStateNormal];
        [self.user setDisFollow];
    }
}

@end
