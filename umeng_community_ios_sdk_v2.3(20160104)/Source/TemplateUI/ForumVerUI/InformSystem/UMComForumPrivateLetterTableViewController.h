//
//  UMComPrivateLetterTableViewController.h
//  UMCommunity
//
//  Created by umeng on 15/11/30.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComRequestTableViewController.h"
#import "UMComTableViewCell.h"

@class UMComImageView,UMComPrivateLetter;

@interface UMComForumPrivateLetterTableViewController : UMComRequestTableViewController

@end

@interface UMComForumSysNoticeCell : UMComTableViewCell

@property (nonatomic, strong) UMComImageView *iconImageView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, strong) UILabel *detailLabel;

@property (nonatomic, strong) UILabel *redDotLabel;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)size;

- (void)reloadCellWithPrivateLetter:(UMComPrivateLetter *)privateLetter;

@end