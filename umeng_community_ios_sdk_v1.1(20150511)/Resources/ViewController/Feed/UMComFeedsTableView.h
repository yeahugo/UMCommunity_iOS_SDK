//
//  UMComFeedsTableView.h
//  UMCommunity
//
//  Created by Gavin Ye on 12/5/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComComment.h"
#import "UMComFeedsTableViewCell.h"

@class UMComFeedTableViewController;

@interface UMComFeedsTableView : UITableView<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIView * commentInputView;

@property (nonatomic, strong) UITextField *commentTextField;

@property (nonatomic, strong) UINib *postCellNib;

@property (nonatomic, copy) NSString *commentFeedId;

@property (nonatomic, copy) NSString *commentUserId;

@property (nonatomic, weak) UIViewController *viewController;

@property (nonatomic, strong) NSMutableDictionary *showCommentDictionary;

@property (nonatomic, strong) NSMutableDictionary *heightDictionary;

@property (nonatomic, strong) NSMutableDictionary *feedStyleDictionary;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) UIActivityIndicatorView *footerIndicatorView;

@property (nonatomic, strong) NSMutableArray *resultArray;

@property (nonatomic, strong) UMComFeedsTableViewCell *selectedCell;

@property (nonatomic, strong) UIView *footView;

@property (nonatomic, copy) void (^scrollViewDidScroll)(UIScrollView *scrollView, CGFloat lastPosition);

@property (nonatomic, copy) void (^deletedFeedSucceedAction)();

@property (nonatomic, copy) void (^loadDataFinishBlock)(NSArray *data, NSError *error);

- (BOOL)isShowAllComment:(int)indexRow;

- (void)setShowAllComment:(int)indexRow selectedCell:(UMComFeedsTableViewCell *)cell;

- (void)reloadRowAtIndex:(NSIndexPath *)indexPath;

- (void)refreshFeedsData;

- (void)refreshFeedsLike:(NSString *)feedId selectedCell:(UMComFeedsTableViewCell *)cell;

- (void)refreshFeedsComments:(NSString *)feedId selectedCell:(UMComFeedsTableViewCell *)cell;

- (void)dismissAllEditBackGround;

- (void)dismissAllEditView;

- (void)presentEditView:(NSString *)feedId;

- (void)presentEditView:(id)object selectedCell:(UMComFeedsTableViewCell *)cell;

- (void)presentReplyView:(UMComComment *)comment;

- (void)addFootView;

- (void)keyboardWillShow:(NSNotification*)notification;

- (void)keyboardHiden:(NSNotification*)notification;

@end
