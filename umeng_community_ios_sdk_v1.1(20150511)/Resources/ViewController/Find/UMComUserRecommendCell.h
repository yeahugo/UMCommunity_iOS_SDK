//
//  UMComUserRecommendCell.h
//  UMCommunity
//
//  Created by umeng on 15-3-31.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComTableViewCell.h"
#import "UMComImageView.h"
#import "UMComUser.h"
typedef enum {
    UMComReccommentUser = 0,
    UMComTopicHotUser = 1,
    UMComSearchUser = 2
}UMComUserType;
@interface UMComUserRecommendCell : UMComTableViewCell

@property (strong, nonatomic) UMComImageView *portrait;

@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLable;
@property (weak, nonatomic) IBOutlet UIButton *focusButton;
- (IBAction)onClickFocusButton:(id)sender;
@property (strong, nonatomic) UIImageView *genderImageView;

@property (nonatomic, strong) UMComUser *user;
@property (nonatomic, assign) UMComUserType userType;
@property (nonatomic, copy) void (^onClickAtCellViewAction)(UMComUser *user);
- (void)displayWithUser:(UMComUser *)user userType:(UMComUserType)userType;

@end
