//
//  UMComFeedsCommentTableViewCell.h
//  UMCommunity
//
//  Created by Gavin Ye on 11/28/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMImageView.h"
#import "UMComMutiStyleTextView.h"

@interface UMComFeedsCommentTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UMComMutiStyleTextView * textView;

@property (nonatomic, weak) IBOutlet UMImageView * profileImageView;

@end
