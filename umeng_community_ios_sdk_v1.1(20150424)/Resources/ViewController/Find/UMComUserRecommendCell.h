//
//  UMComUserRecommendCell.h
//  UMCommunity
//
//  Created by umeng on 15-3-31.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComTableViewCell.h"
#import "UMImageView.h"
#import "UMComUser.h"

@interface UMComUserRecommendCell : UMComTableViewCell
@property (weak, nonatomic) IBOutlet UMImageView *portrait;


@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLable;
@property (weak, nonatomic) IBOutlet UIButton *focusButton;
- (IBAction)onClickFocusButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;

@property (nonatomic, strong) UMComUser *user;
@property (nonatomic, assign) BOOL isHotUser;
@property (nonatomic, copy) void (^onClickAtCellViewAction)(UMComUser *user);
- (void)displayWithUser:(UMComUser *)user isHotUser:(BOOL)isHotUser;

@end
