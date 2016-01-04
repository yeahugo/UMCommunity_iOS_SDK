//
//  UMComHorizonCollectionView.h
//  UMCommunity
//
//  Created by umeng on 15/11/26.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UMComHorizonCollectionCell,UMComHorizonCollectionView,UMComDropdownColumnCell;


@protocol UMComHorizonCollectionViewDelegate <NSObject>

@optional;
- (void)reloadCell:(UMComHorizonCollectionCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (void)horizonCollectionView:(UMComHorizonCollectionView *)collectionView reloadCell:(UMComHorizonCollectionCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (void)horizonCollectionView:(UMComHorizonCollectionView *)collectionView didSelectedColumn:(NSInteger)column;

- (BOOL)horizonCollectionView:(UMComHorizonCollectionView *)collectionView showDropDownMenuAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)horizonCollectionView:(UMComHorizonCollectionView *)collectionView numbersOfDropdownMenuRowsAtIndexPath:(NSIndexPath *)indexPath;

- (void)horizonCollectionView:(UMComHorizonCollectionView *)collectionView
       reloadDropdownMuneCell:(UMComDropdownColumnCell *)cell
                       column:(NSInteger)column
                          row:(NSInteger)row;

- (void)horizonCollectionView:(UMComHorizonCollectionView *)collectionView
            didSelectedColumn:(NSInteger)column
                          row:(NSInteger)row;


//- (void)dropDownTableView:(UMComHorizonCollectionView *)collectionView reloadCell:(UMComHorizonCollectionCell *)cell atIndexPath:(NSIndexPath *)indexPath


@end

@interface UMComHorizonCollectionView : UICollectionView

@property (nonatomic, assign) BOOL isHighLightWhenDidSelected;

@property (nonatomic, strong) UIView *bottomLine;

@property (nonatomic, assign) CGFloat itemSpace;

@property (nonatomic, assign) CGSize itemSize;

@property (nonatomic, readonly) NSInteger currentIndex;

@property (nonatomic, readonly) NSInteger previewsIndex;

@property (nonatomic, assign) CGFloat bottomLineHeight;

@property (nonatomic, assign) CGFloat indicatorLineHeight;

@property (nonatomic, assign) CGFloat indicatorLineWidth;

@property (nonatomic, assign) CGFloat indicatorLineLeftEdge;

@property (nonatomic, strong) UIImageView *scrollIndicatorView;

@property (nonatomic, assign) CGFloat dropMenuRowHeight;

@property (nonatomic, assign) CGFloat dropMenuViewWidth;

@property (nonatomic, assign) CGFloat dropMenuTopMargin;

@property (nonatomic, assign) CGFloat dropMenuLeftMargin;

@property (nonatomic, strong) UIView *dropMenuSuperView;


@property (nonatomic, weak) id<UMComHorizonCollectionViewDelegate> cellDelegate;

- (instancetype)initWithFrame:(CGRect)frame itemCount:(NSInteger)count;

- (instancetype)initWithFrame:(CGRect)frame itemSize:(CGSize)itemSize itemCount:(NSInteger)count;

- (void)hiddenDropMenuView;

@end


@interface UMComHorizonCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, assign) NSInteger index;


@end

@interface UMComDropdownColumnCell : UITableViewCell

@property (nonatomic, strong) UIImageView *customImageView;

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, assign) NSInteger row;

@property (nonatomic, assign) NSInteger column;

//@property (nonatomic, copy) void (^didSelected)(UMComDropDwonColumnCell *dropdownMenuCell);

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)size;

@end

