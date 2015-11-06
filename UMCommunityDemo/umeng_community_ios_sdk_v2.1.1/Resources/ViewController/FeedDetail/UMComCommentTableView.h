//
//  UMComCommentTableView.h
//  UMCommunity
//
//  Created by umeng on 15/5/20.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UMComCommentNamelabelHeght 20
#define UMComCommentTextFont UMComFontNotoSansLightWithSafeSize(15)
#define UMComCommentDeltalWidth 72

@protocol UMComScrollViewDelegate, UMComClickActionDelegate;

@class UMComCommentTableView,UMComTableViewCell,UMComImageView,UMComComment;

@interface UMComCommentTableView : UITableView

@property (nonatomic, weak) id<UMComClickActionDelegate> clickActionDelegate;

@property (nonatomic, weak) id<UMComScrollViewDelegate> scrollViewDelegate;

@property (nonatomic, strong) NSArray *reloadComments;

@property (nonatomic, strong) UMComComment *selectedComment;

@property (nonatomic, strong) NSString *replyUserId;

@property (nonatomic, strong) NSArray *commentStyleViewArray;

@property (nonatomic, assign, readonly) CGPoint lastPosition;

@property (nonatomic, strong) UIView *footView;

@property (nonatomic, strong) UIActivityIndicatorView *refreshIndicatorView;

- (void)reloadCommentTableViewArrWithComments:(NSArray *)reloadComments;

@end


