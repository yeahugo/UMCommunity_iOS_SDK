//
//  UMComTableView.h
//  UMCommunity
//
//  Created by umeng on 15/8/5.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LoadCoreDataCompletionHandler)(NSArray *data, NSError *error);
typedef void (^LoadSeverDataCompletionHandler)(NSArray *data, BOOL haveNextPage,NSError *error);
typedef void (^DataHandleFinish)();


@protocol UMComTableViewHandleDataDelegate <NSObject>

- (void)handleCoreDataDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler;

- (void)handleServerDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler;

- (void)handleLoadMoreDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler;

@end

@protocol UMComScrollViewDelegate;

@class UMComRefreshView, UMComPullRequest;

@interface UMComTableView : UITableView

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) UMComRefreshView *refreshController;

@property (nonatomic, strong) UMComPullRequest *fetchRequest;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) UIView *bottomLine;

@property (nonatomic, assign) BOOL haveNextPage;

@property (nonatomic, strong) UILabel *noDataTipLabel;

@property (nonatomic, assign, readonly) CGPoint lastPosition;

@property (nonatomic, weak) id<UMComScrollViewDelegate> scrollViewDelegate;

@property (nonatomic, weak) id<UMComTableViewHandleDataDelegate> handleDataDelegate;


@property (nonatomic, copy) LoadSeverDataCompletionHandler loadSeverDataCompletionHandler;

- (void)loadAllData:(LoadCoreDataCompletionHandler)coreDataHandler fromServer:(LoadSeverDataCompletionHandler)serverDataHandler;

- (void)fetchDataFromCoreData:(LoadCoreDataCompletionHandler)coreDataHandler;

- (void)refreshNewDataFromServer:(LoadSeverDataCompletionHandler)complection;

- (void)loadNextPageDataFromServer:(LoadSeverDataCompletionHandler)complection;


@end
