//
//  UMComFeedDetailView.h
//  UMCommunity
//
//  Created by umeng on 15/5/20.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UMComClickActionDelegate;

@class UMComMutiStyleTextView, UMComImageView,UMComFeedStyle,UMComGridView;

@interface UMComFeedContentView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *topImage;

@property (weak, nonatomic) IBOutlet UIImageView *publicImage;

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@property (nonatomic, weak) IBOutlet UILabel *locationDistance;

@property (nonatomic, strong)  UMComImageView *portrait;

@property (nonatomic, weak) IBOutlet UMComMutiStyleTextView *feedStyleView;

@property (nonatomic, weak) IBOutlet UIImageView *originFeedBackgroundView;

@property (nonatomic, weak) IBOutlet UMComMutiStyleTextView *originFeedStyleView;

@property (nonatomic, weak) IBOutlet UILabel *locationLabel;

@property (nonatomic, weak) IBOutlet UIView *locationBgView;

@property (weak, nonatomic) IBOutlet UMComGridView *imageGridView;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UIButton *collectionButton;

@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (nonatomic, weak) id<UMComClickActionDelegate> delegate;

- (IBAction)onClickOnShareButton:(UIButton *)sender;

- (IBAction)onClickOnAddCollection:(id)sender;

- (IBAction)onClicLocation:(id)sender;

- (void)reloadDetaiViewWithFeedStyle:(UMComFeedStyle *)feedStyle viewWidth:(CGFloat)viewWidth;
@end