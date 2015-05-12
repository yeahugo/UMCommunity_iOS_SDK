//
//  UMComFindTableViewCell.m
//  UMCommunity
//
//  Created by umeng on 15-3-31.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComFindTableViewCell.h"

@implementation UMComFindTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


//- (void)drawRect:(CGRect)rect
//{
//    UIColor *color = TableViewSeparatorRGBColor;
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
//    CGContextFillRect(context, rect);
//    
//    CGContextSetStrokeColorWithColor(context, color.CGColor);
//    CGContextStrokeRect(context, CGRectMake(0, rect.size.height - TableViewCellSpace, rect.size.width, TableViewCellSpace));
//}

@end
