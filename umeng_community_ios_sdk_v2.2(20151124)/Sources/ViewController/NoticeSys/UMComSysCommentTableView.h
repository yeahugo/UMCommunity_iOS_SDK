//
//  UMComSysCommentTableView.h
//  UMCommunity
//
//  Created by umeng on 15/7/10.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComTableView.h"

@class UMComImageView, UMComMutiStyleTextView, UMComComment, UMComPullRequest, UMComRefreshView;
@protocol UMComClickActionDelegate;

@interface UMComSysCommentTableView : UMComTableView


@property (nonatomic, weak) id<UMComClickActionDelegate> cellActionDelegate;

//是否显示回复按钮
@property (nonatomic, assign) BOOL isShowReplyButton;

@end


@interface UMComCommentModle : NSObject

@property (nonatomic, copy) NSString *nameString;

@property (nonatomic, copy) NSString *timeString;

@property (nonatomic, copy) NSString *feedText;

@property (nonatomic, copy) NSString *commentText;

@property (nonatomic, copy) NSString *portraitUrlString;

@property (nonatomic, assign) float subViewsOriginX;
@property (nonatomic, assign) float subViewWidth;
@property (nonatomic, assign) float viewWidth;
@property (nonatomic, assign) float totalHeight;
@property (nonatomic, assign) CGPoint feedTextOrigin;
@property (nonatomic, assign) float commentTextViewDelta;

@property (nonatomic, strong) UMComMutiStyleTextView *commentTextView;

@property (nonatomic, strong) UMComMutiStyleTextView *feedStyleView;

@property (nonatomic, strong) UMComComment *comment;

+ (UMComCommentModle *)commentModelWithComment:(UMComComment *)comment viewWidth:(float)viewWidth commentTextViewDelta:(CGFloat)commentTextViewDelta;

- (void)resetWithComment:(UMComComment *)comment;

@end

@interface UMComSysCommentCell : UITableViewCell

@property (nonatomic, strong) UMComImageView *portrait;

@property (nonatomic, strong) UILabel *userNameLabel;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIButton *replyButton;

@property (nonatomic, weak) id<UMComClickActionDelegate> delegate;

@property (nonatomic, strong) UMComMutiStyleTextView *commentTextView;

@property (nonatomic, strong) UMComMutiStyleTextView *feedTextView;

- (void)reloadCellWithLikeModel:(UMComCommentModle *)commentModel;

@end