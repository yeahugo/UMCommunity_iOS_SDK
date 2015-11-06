//
//  UMComFriendTableViewCell.m
//  UMCommunity
//
//  Created by Gavin Ye on 12/18/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComFriendTableViewCell.h"
#import "UMComTools.h"
#import "UMComImageView.h"

@implementation UMComFriendTableViewCell

- (void)awakeFromNib {
    UMComImageView * profileImageView = [[[UMComImageView imageViewClassName] alloc] initWithFrame:CGRectMake(20, 5, 40, 40)];
    self.profileImageView = profileImageView;
    [self.contentView addSubview:self.profileImageView];
    self.nameLabel.font = UMComFontNotoSansLightWithSafeSize(17);
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
//
// 自绘分割线
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGContextSetStrokeColorWithColor(context, TableViewSeparatorRGBColor.CGColor);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height - TableViewCellSpace, rect.size.width, TableViewCellSpace));

}

@end
