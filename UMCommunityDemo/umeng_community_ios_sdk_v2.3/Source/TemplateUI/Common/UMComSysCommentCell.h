//
//  UMComSysCommentCell.h
//  UMCommunity
//
//  Created by umeng on 15/11/30.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComTableViewCell.h"
#import "UMComTableViewCell.h"

@class UMComImageView,UMComMutiStyleTextView,UMComCommentModel,UMComComment,UMComMutiText;
@protocol UMComClickActionDelegate;

@interface UMComSysCommentCell : UMComTableViewCell

@property (nonatomic, strong) UMComImageView *portrait;

@property (nonatomic, strong) UILabel *userNameLabel;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIButton *replyButton;

@property (nonatomic, weak) id<UMComClickActionDelegate> delegate;

@property (nonatomic, strong) UMComMutiStyleTextView *commentTextView;

@property (nonatomic, strong) UMComMutiStyleTextView *feedTextView;

- (void)reloadCellWithLikeModel:(UMComCommentModel *)commentModel;

@end

@interface UMComCommentModel : NSObject

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

@property (nonatomic, strong) UMComMutiText *commentMutiText;

@property (nonatomic, strong) UMComMutiText *feedMutiText;

@property (nonatomic, strong) UMComComment *comment;

+ (UMComCommentModel *)commentModelWithComment:(UMComComment *)comment viewWidth:(float)viewWidth commentTextViewDelta:(CGFloat)commentTextViewDelta;

- (void)resetWithComment:(UMComComment *)comment;

@end