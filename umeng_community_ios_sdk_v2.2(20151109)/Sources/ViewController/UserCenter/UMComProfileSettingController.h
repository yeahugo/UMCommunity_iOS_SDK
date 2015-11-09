//
//  UMComProfileSettingController.h
//  UMCommunity
//
//  Created by luyiyuan on 14/10/27.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComTools.h"
#import "UMComViewController.h"

#define UpdateUserProfileSuccess @"update user profile success!"

@class UMComUser;

@interface UMComProfileSettingController : UMComViewController
<UIPickerViewDataSource,UIPickerViewDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate,UINavigationControllerDelegate>

@property (nonatomic, copy) LoadDataCompletion completion;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;

@property (nonatomic, weak) IBOutlet UITextField * nameField;
@property (weak, nonatomic) IBOutlet UIImageView *portraitImageView;

@property (nonatomic, weak) IBOutlet UIButton * genderSelector;

@property (nonatomic, weak) IBOutlet UIButton * genderButton;

@property (nonatomic, weak) IBOutlet UIPickerView *genderPicker;

@property (nonatomic, strong) NSError *registerError;
@property (weak, nonatomic) IBOutlet UIView *topLineView;
@property (weak, nonatomic) IBOutlet UIView *mindleLineView;
@property (weak, nonatomic) IBOutlet UIView *bottomLineView;

//- (id)initWithUser:(UMComUser *)user;
- (id)initWithUid:(NSString *)uid;
@end
