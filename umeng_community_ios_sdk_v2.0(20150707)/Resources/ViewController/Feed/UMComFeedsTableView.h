//
//  UMComFeedsTableView.h
//  UMCommunity
//
//  Created by Gavin Ye on 12/5/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComPullRequest.h"
#import "UMComClickActionDelegate.h"


@class UMComFeedTableViewController,UMComFeedsTableView;

@protocol UMComFeedsTableViewDelegate <NSObject>

@required;
- (void)feedTableView:(UMComFeedsTableView *)feedTableView refreshData:(LoadServerDataCompletion)completion;
@optional;
- (void)feedTableView:(UMComFeedsTableView *)feedTableView loadMoreData:(LoadServerDataCompletion)completion;

@end

@interface UMComFeedsTableView : UITableView<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) id<UMComFeedsTableViewDelegate> feedsTableViewDelegate;

@property (nonatomic, weak) id<UMComClickActionDelegate> clickActionDelegate;//tableViewCell上的一些点击事件的delegate

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) UIActivityIndicatorView *footerIndicatorView;

@property (nonatomic, strong) NSMutableArray *resultArray;

@property (nonatomic, strong) UIView *footView;

@property (nonatomic, copy) void (^scrollViewDidScroll)(UIScrollView *scrollView, CGFloat lastPosition);

@property (nonatomic, copy) void (^loadDataFinishBlock)(NSArray *data, NSError *error);

- (void)dealWithFetchResult:(NSArray *)data error:(NSError *)error loadMore:(BOOL)loadeMore haveNextPage:(BOOL)haveNextPage;
- (void)reloadRowAtIndex:(NSIndexPath *)indexPath;

- (NSArray *)dealWithFeedData:(NSArray *)dataArr;

@end
