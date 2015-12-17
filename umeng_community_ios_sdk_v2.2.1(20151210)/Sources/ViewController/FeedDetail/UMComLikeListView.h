//
//  UMComLikeListView.h
//  UMCommunity
//
//  Created by umeng on 15/5/21.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UMComClickActionDelegate;

@class UMComImageView, UMComFeed;

@interface UMComLikeListView : UIView

@property (nonatomic, strong) UIButton *likeButton;

@property (nonatomic, strong) UILabel *likeCountLabel;

@property (nonatomic, strong) UICollectionView *likeUserListView;

@property (nonatomic, copy) void (^didSelectedIndex)(NSIndexPath *indexPath);

@property (nonatomic, copy) void (^clikeOnLikeButton)(UIButton *likeButton);

@property (nonatomic, strong) NSArray *likeList;

@property (nonatomic, strong) id<UMComClickActionDelegate> delegate;

- (void)reloadViewsWithfeed:(UMComFeed *)feed likeArray:(NSArray *)likeArr;

@end


@interface UMComLikeCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UMComImageView *portrait;

@property (nonatomic, assign) CGPoint portraitOrigin;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) void (^didSelectedAtIndexPath)(NSIndexPath *indexPath);

@end