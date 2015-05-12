//
//  UMComUserCollectionViewCell.h
//  UMCommunity
//
//  Created by umeng on 15/5/6.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComUser.h"
#import "UMComImageView.h"


@interface UMComUserCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) UMComImageView *portrait;

@property (strong, nonatomic) UILabel *userNameLabel;

@property (nonatomic, strong) UMComUser *user;

@property (nonatomic, copy) void (^clickAtUser)(UMComUser *user);
- (void)showWithUser:(UMComUser *)user;
@end
