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
    self.profileImageView.layer.cornerRadius =self.profileImageView.frame.size.width/2;
    self.profileImageView.layer.masksToBounds = YES;
//    self.profileImageView.layer.
    // Initialization code
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
