//
//  UMComCommentControlView.h
//  UMCommunity
//
//  Created by umeng on 15/7/12.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UMComClickActionDelegate;

@class UMComSysCommentTableView, UMComMenuControlView;

@interface UMComCommentControlView : UIView

@property (nonatomic, strong) UMComMenuControlView *menuControlView;

@property (nonatomic, strong) UMComSysCommentTableView *commentTableView;

@property (nonatomic, strong) UMComSysCommentTableView *commentReplyTableView;

@property (nonatomic, weak) id<UMComClickActionDelegate> delegate;

@property (nonatomic, assign) NSInteger index;

- (void)refreshCommentData;

- (void)fecthAllCommentCommentData;


@end
