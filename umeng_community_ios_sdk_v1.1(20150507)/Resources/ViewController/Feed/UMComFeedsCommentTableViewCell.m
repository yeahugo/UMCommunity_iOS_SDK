//
//  UMComFeedsCommentTableViewCell.m
//  UMCommunity
//
//  Created by Gavin Ye on 11/28/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComFeedsCommentTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation UMComFeedsCommentTableViewCell

- (void)awakeFromNib {
    UMComImageView *profileImageView = [[UMComImageView alloc] initWithFrame:CGRectMake(8, 0, 20, 20)];
    self.profileImageView = profileImageView;
    [self.contentView addSubview:self.profileImageView];

    self.profileImageView.layer.cornerRadius =self.profileImageView.frame.size.width/2;
    self.profileImageView.layer.masksToBounds = YES;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
