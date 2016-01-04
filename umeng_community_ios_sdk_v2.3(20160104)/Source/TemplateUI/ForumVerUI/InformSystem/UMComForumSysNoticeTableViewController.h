//
//  UMComForumSystemNoticeTableViewController.h
//  UMCommunity
//
//  Created by umeng on 15/11/30.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComRequestTableViewController.h"
#import "UMComTableViewCell.h"

@class UMComImageView, UMComMutiStyleTextView, UMComNotification,UMComMutiText;
@protocol UMComClickActionDelegate;

@interface UMComForumSysNoticeTableViewController : UMComRequestTableViewController

@end



@interface UMComForumUserNotificationCell : UMComTableViewCell

@property (nonatomic, strong) UMComImageView *iconImageView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, copy) void (^clickOnUserIcon)();

@property (nonatomic, strong) UMComMutiStyleTextView *contentTextView;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)size;

- (void)reloadCellWithNotification:(UMComNotification *)notification styleView:(UMComMutiText *)styleView;


@end