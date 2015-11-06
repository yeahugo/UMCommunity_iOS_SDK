//
//  UMComSysLikeTableView.h
//  UMCommunity
//
//  Created by umeng on 15/7/10.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComTableView.h"


@class UMComImageView, UMComMutiStyleTextView, UMComLike, UMComRefreshView;

@protocol UMComClickActionDelegate;


@interface UMComSysLikeTableView : UMComTableView


@property (nonatomic, weak) id<UMComClickActionDelegate> cellActionDelegate;


@end


@interface UMComLikeModle : NSObject

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

@property (nonatomic, strong) UMComMutiStyleTextView *feedStyleView;

@property (nonatomic, strong) UMComLike *like;

+ (UMComLikeModle *)likeModelWithLike:(UMComLike *)like viewWidth:(float)viewWidth;

- (void)resetWithLike:(UMComLike *)like;

@end

@interface UMComSysLikeCell : UITableViewCell

@property (nonatomic, strong) UMComImageView *portrait;

@property (nonatomic, strong) UILabel *userNameLabel;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, weak) id<UMComClickActionDelegate> delegate;

@property (nonatomic, strong) UMComMutiStyleTextView *feedTextView;

- (void)reloadCellWithLikeModel:(UMComLikeModle *)likeModel;

@end