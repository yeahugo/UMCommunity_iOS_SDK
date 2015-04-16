//
//  UMComFriendTableViewCell.h
//  UMCommunity
//
//  Created by Gavin Ye on 12/18/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMImageView.h"

@interface UMComFriendTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UMImageView * profileImageView;

@property (nonatomic, weak) IBOutlet UILabel * nameLabel;


@end
