//
//  UMComRemoteNoticeViewController.h
//  UMCommunity
//
//  Created by umeng on 15/7/9.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComTableViewController.h"
#import "UMComTableViewCell.h"

@protocol UMComClickActionDelegate;

@class UMComImageView, UMComMutiStyleTextView, UMComNotification;

@interface UMComRemoteNoticeViewController : UMComTableViewController

@property (nonatomic, weak) id<UMComClickActionDelegate> cellActionDelegate;

@end



@interface UMComSysNotificationCell : UMComTableViewCell

@property (nonatomic, strong) UMComImageView *portrait;

@property (nonatomic, strong) UILabel *userNameLabel;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, weak) id<UMComClickActionDelegate> delegate;

@property (nonatomic, strong) UMComMutiStyleTextView *contentTextView;

- (void)reloadCellWithNotification:(UMComNotification *)notification styleView:(UMComMutiStyleTextView *)styleView viewWidth:(CGFloat)viewWidth;

@end