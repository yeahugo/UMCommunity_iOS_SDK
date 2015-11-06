//
//  UMComUserTableViewCell.h
//  UMCommunity
//
//  Created by umeng on 15-3-31.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComTableViewCell.h"

@protocol UMComClickActionDelegate;

@class UMComImageView, UMComUser;

@interface UMComUserTableViewCell : UMComTableViewCell

@property (strong, nonatomic) UMComImageView *portrait;

@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLable;
@property (weak, nonatomic) IBOutlet UIButton *focusButton;
- (IBAction)onClickFocusButton:(id)sender;
@property (strong, nonatomic) UIImageView *genderImageView;

@property (nonatomic, strong) UMComUser *user;

@property (nonatomic, copy) void (^onClickAtCellViewAction)(UMComUser *user);

@property (nonatomic, weak) id <UMComClickActionDelegate> delegate;

- (void)displayWithUser:(UMComUser *)user; 

- (void)focusUserAfterLoginSucceedWithResponse:(void (^)(NSError *error))response;

@end
