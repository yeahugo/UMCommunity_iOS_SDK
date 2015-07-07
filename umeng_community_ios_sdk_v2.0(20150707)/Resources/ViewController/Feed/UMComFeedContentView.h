//
//  UMComFeedDetailView.h
//  UMCommunity
//
//  Created by umeng on 15/5/20.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComClickActionDelegate.h"

@class UMComMutiStyleTextView, UMComImageView,UMComFeedStyle,UMComGridView;

@interface UMComFeedContentView : UIView

@property (weak, nonatomic) IBOutlet UILabel *acountType;


@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@property (nonatomic, strong)  UMComImageView *portrait;

@property (nonatomic, weak) IBOutlet UMComMutiStyleTextView *feedStyleView;
@property (nonatomic, weak) IBOutlet UIImageView *originFeedBackgroundView;

@property (nonatomic, weak) IBOutlet UMComMutiStyleTextView *originFeedStyleView;

@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UIView *locationBgView;
@property (weak, nonatomic) IBOutlet UMComGridView *iamgeGridView;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;



@property (nonatomic, weak) id<UMComClickActionDelegate> delegate;
- (IBAction)onClickOnShareButton:(UIButton *)sender;


- (void)reloadDetaiViewWithFeedStyle:(UMComFeedStyle *)feedStyle viewWidth:(CGFloat)viewWidth;

@end