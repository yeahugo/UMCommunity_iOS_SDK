//
//  UMComForumUserCenterViewController.h
//  UMCommunity
//
//  Created by umeng on 15/11/27.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComViewController.h"

@class UMComUser, UMComImageView, UMComUserProfileDetailView;
@interface UMComForumUserCenterViewController : UMComViewController

- (instancetype)initWithUser:(UMComUser *)user;

@end



@protocol UMComUserProfileDetaiViewDelegate <NSObject>

@optional;
- (void)userProfileDetailView:(UMComUserProfileDetailView *)userProfileDetailView
                clickOnfocuse:(UIButton *)focuseButton;

- (void)userProfileDetailView:(UMComUserProfileDetailView *)userProfileDetailView
                 clickOnAlbum:(UIButton *)albumButton;

- (void)userProfileDetailView:(UMComUserProfileDetailView *)userProfileDetailView
                 clickOnFollowTopic:(UIButton *)topicButton;

- (void)userProfileDetailView:(UMComUserProfileDetailView *)userProfileDetailView
          clickOnScore:(UIButton *)letterButton;

- (void)userProfileDetailView:(UMComUserProfileDetailView *)userProfileDetailView
         clickOnAvatar:(UMComImageView *)avartar;

@end

@interface UMComUserProfileDetailView : UIView

@property (nonatomic, strong) UMComUser *user;

@property (nonatomic, strong) UMComImageView *avatarImageView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, weak) id<UMComUserProfileDetaiViewDelegate> deleagte;

- (instancetype)initWithFrame:(CGRect)frame user:(UMComUser *)user;

- (void)reloadSubViewsWithUser:(UMComUser *)user;


@end