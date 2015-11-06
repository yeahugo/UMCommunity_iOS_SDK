//
//  UMComLikeUserViewController.h
//  UMCommunity
//
//  Created by umeng on 15/5/27.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComTableViewController.h"
#import "UMComTableViewCell.h"

@class UMComPullRequest,UMComImageView,UMComFeed;

@interface UMComLikeUserViewController : UMComTableViewController

@property (nonatomic, strong) NSArray *likeUserList;

@property (nonatomic, strong) UMComFeed *feed;

@end


@interface UMComLikeUserTableViewCell : UMComTableViewCell

@property (nonatomic, strong) UMComImageView *portrait;

@property (nonatomic, strong) UILabel *nameLabel;

@end