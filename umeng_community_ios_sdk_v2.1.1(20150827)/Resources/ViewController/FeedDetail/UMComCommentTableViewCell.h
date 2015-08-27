//
//  UMComCommentTableViewCell.h
//  UMCommunity
//
//  Created by umeng on 15/5/22.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UMComClickActionDelegate;

@class UMComMutiStyleTextView,UMComImageView,UMComComment;


@interface UMComCommentTableViewCell : UITableViewCell

@property (nonatomic, strong) UMComImageView *portrait;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UMComMutiStyleTextView *commentTextView;

@property (nonatomic, copy) void (^clickOnUserportrait)(UMComComment *comment);
@property (nonatomic, copy) void (^clickOnCommentContent)(UMComComment *comment);

@property (nonatomic, weak) id<UMComClickActionDelegate> delegate;

- (void)reloadWithComment:(UMComComment *)comment commentStyleView:(UMComMutiStyleTextView *)stryleView;

@end