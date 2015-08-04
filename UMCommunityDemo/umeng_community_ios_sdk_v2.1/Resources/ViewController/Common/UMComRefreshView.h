//
//  RefreshTableView.h
//  DJXRefresh
//
//  Created by Founderbn on 14-7-18.
//  Copyright (c) 2014年 Umeng 董剑雄. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RefreshDataLoadFinishHandler)(NSError *error);

@class UMComRefreshView;

@protocol UMComRefreshViewDelegate <NSObject>

@optional

- (void)refreshData:(UMComRefreshView *)refreshView loadingFinishHandler:(RefreshDataLoadFinishHandler)handler;

- (void)loadMoreData:(UMComRefreshView *)refreshView loadingFinishHandler:(RefreshDataLoadFinishHandler)handler;

@end

@interface UMComRefreshView : UIView

@property (nonatomic, strong) UILabel *finishLabel;/*加载结束提示语*/

@property (nonatomic, weak) id <UMComRefreshViewDelegate>refreshDelegate;

@property (nonatomic, assign) CGFloat startLocation;

@property (nonatomic, assign) BOOL isPull;

@property (nonatomic, strong) UIView *lineSpace;

- (void)refreshScrollViewDidScroll:(UIScrollView *)refreshScrollView;

- (void)refreshScrollViewDidEndDragging:(UIScrollView *)refreshScrollView;

@end
