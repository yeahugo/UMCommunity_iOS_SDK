//
//  UMComForumSysCommentCell.h
//  UMCommunity
//
//  Created by umeng on 15/12/27.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComSysCommonTableViewCell.h"

@interface UMComForumSysCommentCell : UMComSysCommonTableViewCell

@property (nonatomic, strong) UIButton *replyButton;

@property (nonatomic, strong) UMComMutiStyleTextView *commentTextView;

@end

