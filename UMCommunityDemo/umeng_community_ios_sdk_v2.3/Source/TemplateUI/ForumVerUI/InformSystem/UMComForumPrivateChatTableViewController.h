//
//  UMComForumPrivateChatTableViewController.h
//  UMCommunity
//
//  Created by umeng on 15/12/1.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComRequestTableViewController.h"

@class UMComPrivateLetter, UMComImageView, UMComUser,UMComPrivateMessage,UMComMutiText,UMComMutiStyleTextView;

@interface UMComForumPrivateChatTableViewController : UMComRequestTableViewController

- (instancetype)initWithPrivateLetter:(UMComPrivateLetter *)privateLetter;
- (instancetype)initWithUser:(UMComUser *)user;

@end


@interface UMComChatRecodTableViewCell :UITableViewCell

@property (nonatomic, strong) UMComImageView *iconImaeView;

@property (nonatomic, strong) UMComMutiStyleTextView *chatContentView;

@property (nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, copy) void (^clickOnUser)();

@property (nonatomic, copy) void (^clickOnCell)();

- (void)reloadTabelViewCellWithMessage:(UMComPrivateMessage *)privateMessage mutiText:(UMComMutiText *)mutiText cellSize:(CGSize)size;


@end


@interface UMComChatReceivedTableViewCell : UMComChatRecodTableViewCell

@end

@interface UMComChatSendTableViewCell : UMComChatRecodTableViewCell

@end