//
//  UMComFeedsTableView.h
//  UMCommunity
//
//  Created by Gavin Ye on 12/5/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^LoadCoreDataCompletionHandler)(NSArray *data, NSError *error);
typedef void (^LoadSeverDataCompletionHandler)(NSArray *data, BOOL haveNextPage,NSError *error);


@class UMComPullRequest, UMComRefreshView;
@protocol UMComClickActionDelegate, UMComScrollViewDelegate;


@interface UMComFeedsTableView : UITableView<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) id<UMComClickActionDelegate> clickActionDelegate;//tableViewCell上的一些点击事件的delegate
@property (nonatomic, strong) id <UMComScrollViewDelegate> scrollViewDelegate;

@property (nonatomic, strong) UMComPullRequest *fetchFeedsController;

@property (nonatomic, strong) NSMutableArray *resultArray;

@property (nonatomic, strong) UMComRefreshView *headView;

@property (nonatomic, strong) UMComRefreshView *footView;

@property (nonatomic, assign, readonly) CGPoint lastPosition;

@property (nonatomic, copy) void (^scrollViewDidScroll)(UIScrollView *scrollView, CGPoint lastPosition);

//@property (nonatomic, copy) void (^RefreshTableViewFinish)(NSArray *data, NSError *error);

@property (nonatomic, copy) LoadSeverDataCompletionHandler loadSeverDataCompletionHandler;

- (void)refreshAllFeedsData:(LoadCoreDataCompletionHandler)coreDataHandler fromServer:(LoadSeverDataCompletionHandler)serverDataHandler;

- (void)fetchFeedsFromCoreData:(LoadCoreDataCompletionHandler)coreDataHandler;

- (void)fetchFeedsFromServer:(LoadSeverDataCompletionHandler)serverDataHandler;

- (void)reloadRowAtIndex:(NSIndexPath *)indexPath;


@end
