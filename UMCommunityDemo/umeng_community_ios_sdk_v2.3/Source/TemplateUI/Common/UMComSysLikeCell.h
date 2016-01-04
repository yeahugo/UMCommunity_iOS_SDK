//
//  UMComSysLikeCell.h
//  UMCommunity
//
//  Created by umeng on 15/11/30.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComTableViewCell.h"
#import "UMComTableViewCell.h"


@class UMComImageView, UMComLikeModel,UMComMutiStyleTextView,UMComLike, UMComMutiText;
@protocol UMComClickActionDelegate;

@interface UMComSysLikeCell : UMComTableViewCell

@property (nonatomic, strong) UMComImageView *portrait;

@property (nonatomic, strong) UILabel *userNameLabel;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, weak) id<UMComClickActionDelegate> delegate;

@property (nonatomic, strong) UMComMutiStyleTextView *feedTextView;

- (void)reloadCellWithLikeModel:(UMComLikeModel *)likeModel;

@end

@interface UMComLikeModel : NSObject

@property (nonatomic, copy) NSString *nameString;

@property (nonatomic, copy) NSString *timeString;

@property (nonatomic, copy) NSString *feedText;

@property (nonatomic, strong) NSArray *feedImages;

@property (nonatomic, copy) NSString *portraitUrlString;

@property (nonatomic, assign) float subViewsOriginX;

@property (nonatomic, assign) float subViewWidth;
@property (nonatomic, assign) float viewWidth;
@property (nonatomic, assign) float totalHeight;
@property (nonatomic, assign) CGPoint feedTextOrigin;

@property (nonatomic, strong) UMComMutiText *mutiText;

@property (nonatomic, strong) UMComLike *like;

+ (UMComLikeModel *)likeModelWithLike:(UMComLike *)like viewWidth:(float)viewWidth;

- (void)resetWithLike:(UMComLike *)like;

@end

