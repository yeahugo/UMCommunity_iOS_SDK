//
//  UMComUsersTableCell.m
//  UMCommunity
//
//  Created by luyiyuan on 14/10/16.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComUsersTableCell.h"
#import "UMComUserCenterViewController.h"
#import "UMComUsersTableCellOne.h"
#import "UMComSession.h"
#import "UMComAction.h"

@implementation UMComUsersTableCell

+ (CGFloat)staticHeight
{
    return 85;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    [self registerCellClasser:[UMComUsersTableCell class] CellOneViewClasser:[UMComUsersTableCellOne class]];
    }
    return self;
}

- (void)handleTap:(id)dataOne
{
    [[UMComUserCenterAction action] performActionAfterLogin:dataOne viewController:self.viewController completion:nil];
}

@end
