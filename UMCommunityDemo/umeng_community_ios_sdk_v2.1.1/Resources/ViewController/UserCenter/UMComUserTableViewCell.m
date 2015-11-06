//
//  UMComUserTableViewCell.m
//  UMCommunity
//
//  Created by umeng on 15-3-31.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComUserTableViewCell.h"
#import "UMComPushRequest.h"
#import "UMComShowToast.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComImageView.h"
#import "UMComSession.h"
#import "UMComClickActionDelegate.h"
#import "UMComCoreData.h"

@interface UMComUserTableViewCell ()

@end

@implementation UMComUserTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.genderImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-8, 3, 10, 10)];
    [self.userName addSubview:self.genderImageView];
    self.genderImageView.clipsToBounds = YES;
    self.genderImageView.layer.cornerRadius = self.genderImageView.frame.size.width/2;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapAtThissView:)];
    [self addGestureRecognizer:tap];
    self.descriptionLable.textColor = [UMComTools colorWithHexString:FontColorGray];
    UMComImageView *portrait = [[[UMComImageView imageViewClassName] alloc] initWithFrame:CGRectMake(15, 10, 40, 40)];
    self.portrait = portrait;
    [self.contentView addSubview:self.portrait];
    self.userName.font = UMComFontNotoSansLightWithSafeSize(17);
    self.descriptionLable.font = UMComFontNotoSansLightWithSafeSize(10);
    self.focusButton.titleLabel.font = UMComFontNotoSansLightWithSafeSize(13);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)didTapAtThissView:(UIGestureRecognizer *)tap
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnUser:)]) {
        [self.delegate customObj:self clickOnUser:self.user];
    }
}

- (void)displayWithUser:(UMComUser *)user
{
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
    self.descriptionLable.text =  [NSString stringWithFormat:@"发表消息: %@ / 粉丝: %@",post_count,fans_count];
    CGSize textSize = [self.userName.text sizeWithFont:self.userName.font constrainedToSize:CGSizeMake(self.frame.size.width, self.userName.frame.size.height) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat originX = textSize.width;
    if (textSize.width >= self.userName.frame.size.width) {
        originX = self.userName.frame.size.width-5;
    }else if (textSize.width >= self.userName.frame.size.width-5){
        originX-= 5;
    }
    self.genderImageView.frame = CGRectMake(originX+2, self.genderImageView.frame.origin.y, self.genderImageView.frame.size.width, self.genderImageView.frame.size.height);
    if ([user.gender intValue] == 0) {
        self.genderImageView.image = [UIImage imageNamed:@"♀.png"];
        
    }else{
        self.genderImageView.image = [UIImage imageNamed:@"♂.png"];
    }
    BOOL isFollow = [self.user.has_followed boolValue];
    [self changeFocusWithIsFollow:isFollow];
}


- (IBAction)onClickFocusButton:(id)sender {
  
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnFollowUser:)]) {
        [self.delegate customObj:self clickOnFollowUser:self.user];
    }
}


- (void)focusUserAfterLoginSucceedWithResponse:(void (^)(NSError *error))response
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    BOOL hasFollow = [self.user.has_followed boolValue];
    __weak UMComUserTableViewCell *weakSelf = self;
        if (hasFollow) {
        [UMComFollowUserRequest postDisFollowerWithUserId:self.user.uid completion:^(NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if (error) {
                [UMComShowToast showFetchResultTipWithError:error];
            }else{
                UMComUser *loginUser = [UMComSession sharedInstance].loginUser;
                weakSelf.user.fans_count = [NSNumber numberWithInteger:([weakSelf.user.fans_count intValue] - 1)];
                NSInteger followersCount = [loginUser.following_count integerValue] -1;
                loginUser.following_count = [NSNumber numberWithInteger:followersCount];
                [weakSelf changeFocusWithIsFollow:NO];
                [[UMComCoreData sharedInstance] saveManagedObject:loginUser];
            }
            [[UMComCoreData sharedInstance] saveManagedObject:weakSelf.user];
        }];
    }else{
        [UMComFollowUserRequest postFollowerWithUserId:self.user.uid completion:^(NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if (error) {
                [UMComShowToast showFetchResultTipWithError:error];
                if (error.code == 10007) {
                    [weakSelf changeFocusWithIsFollow:YES];
                }else{
                    [weakSelf changeFocusWithIsFollow:NO];
                }
            }else{
                UMComUser *loginUser = [UMComSession sharedInstance].loginUser;
                weakSelf.user.fans_count = [NSNumber numberWithInteger:([weakSelf.user.fans_count intValue] + 1)];
                NSInteger followersCount = [loginUser.following_count integerValue] +1;
                loginUser.following_count = [NSNumber numberWithInteger:followersCount];
                [weakSelf changeFocusWithIsFollow:YES];
                
                if (response) {
                    response(nil);
                }
                [[UMComCoreData sharedInstance]  saveManagedObject:loginUser];
            }
            [[UMComCoreData sharedInstance]  saveManagedObject:weakSelf.user];
        }];
    }
}

- (void)changeFocusWithIsFollow:(BOOL)isFollow
{
    if (isFollow) {
        [self.focusButton setBackgroundColor:[UMComTools colorWithHexString:ViewGrayColor]];
        UIColor *bcolor = [UIColor colorWithRed:15.0/255.0 green:121.0/255.0 blue:254.0/255.0 alpha:1];
        [self.focusButton setTitleColor:bcolor forState:UIControlStateNormal];
        [self.focusButton setTitle:UMComLocalizedString(@"has_been_followed" ,@"取消关注") forState:UIControlStateNormal];
        [self.user setHas_followed:@1];
    }else{
        [self.focusButton setBackgroundColor:[UMComTools colorWithHexString:ViewGreenBgColor]];
        [self.focusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.focusButton setTitle:UMComLocalizedString(@"follow" ,@"关注") forState:UIControlStateNormal];
        [self.user setHas_followed:@0];
    }
    self.descriptionLable.text =  [NSString stringWithFormat:@"发表消息: %@ / 粉丝: %@",[self.user post_count],self.user.fans_count];
}

@end
