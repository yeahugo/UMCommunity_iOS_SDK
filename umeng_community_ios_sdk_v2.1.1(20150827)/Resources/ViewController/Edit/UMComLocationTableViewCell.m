//
//  UMComLocationTableViewCell.m
//  UMCommunity
//
//  Created by Gavin Ye on 12/18/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComLocationTableViewCell.h"
#import "UMComTools.h"

@implementation UMComLocationTableViewCell

- (void)awakeFromNib {
    self.locationName.font = UMComFontNotoSansLightWithSafeSize(17);
     self.locationDetail.font = UMComFontNotoSansLightWithSafeSize(15);
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

- (void)reloadFromLocationDic:(NSDictionary *)locationDic
{
//    NSLog(@"locationDic is %@",locationDic);
    [self.locationName setText:[locationDic valueForKey:@"name"]];
    [self.locationDetail setText:[locationDic valueForKey:@"addr"]];
}

@end
