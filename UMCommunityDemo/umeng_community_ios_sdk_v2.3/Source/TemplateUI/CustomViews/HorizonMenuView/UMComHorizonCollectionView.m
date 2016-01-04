//
//  UMComHorizonCollectionView.m
//  UMCommunity
//
//  Created by umeng on 15/11/26.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComHorizonCollectionView.h"
#import "UMComTools.h"

@interface UMComHorizonCollectionView ()<UICollectionViewDataSource, UICollectionViewDelegate,UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) NSInteger itemCount;

@property (nonatomic, strong) UICollectionViewFlowLayout *currentLayout;

@property (nonatomic, strong) UIImageView *dropdownMenuView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@property (nonatomic, strong) NSMutableDictionary *indexPathsDict;

@property (nonatomic, assign) BOOL isTheFirstTime;

@end

@implementation UMComHorizonCollectionView

- (instancetype)initWithFrame:(CGRect)frame itemCount:(NSInteger)count
{
    CGFloat itemWidth = frame.size.width/count;
    CGSize itemSize = CGSizeMake(itemWidth, frame.size.height);
    self = [self initWithFrame:frame itemSize:itemSize itemCount:count];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame itemSize:(CGSize)itemSize itemCount:(NSInteger)count
{
    UICollectionViewFlowLayout *currentLayout = [[UICollectionViewFlowLayout alloc]init];
    currentLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    currentLayout.itemSize = itemSize;
    currentLayout.sectionInset = UIEdgeInsetsMake(0.5, 0.5, 0.5, 0.5);
    self.currentLayout = currentLayout;
    self = [super initWithFrame:frame collectionViewLayout:currentLayout];
    if (self) {
        _itemSize = itemSize;
        _dropMenuLeftMargin = 10;
        self.itemCount = count;
        self.itemSpace = 0.5;
        _indicatorLineWidth = itemSize.width;
        _indicatorLineHeight = 0.5;
        self.dropMenuRowHeight = 30;
        self.dropMenuViewWidth = 100;
        _isTheFirstTime = YES;
        _dropMenuSuperView = [UIApplication sharedApplication].keyWindow;
        _indexPathsDict = [NSMutableDictionary dictionary];
        self.dataSource = self;
        self.delegate = self;
        [self registerClass:[UMComHorizonCollectionCell class] forCellWithReuseIdentifier:@"UMComHorizonCollectionCell"];
        self.backgroundColor = [UIColor whiteColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.scrollIndicatorView = [[UIImageView alloc]initWithFrame:CGRectMake(_itemSpace, self.frame.size.height-0.5, self.itemSize.width, 0.5)];
        self.scrollIndicatorView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.scrollIndicatorView];
        _indicatorLineLeftEdge = 0;
        
    }
    return self;
}

- (void)setDropMenuSuperView:(UIView *)dropMenuSuperView
{
    _dropMenuSuperView = dropMenuSuperView;
}


- (void)setItemCount:(NSInteger)itemCount
{
    _itemCount = itemCount;
    [self reloadData];
}

- (void)setItemSpace:(CGFloat)itemSpace
{
    _itemSpace = itemSpace;
    self.currentLayout.minimumLineSpacing = itemSpace;
    CGFloat itemWidth = (self.frame.size.width-itemSpace*(self.itemCount+1))/self.itemCount;
    self.currentLayout.itemSize = CGSizeMake(itemWidth, self.frame.size.height-1);
    self.itemSize = self.currentLayout.itemSize;
    
}

- (void)setBottomLineHeight:(CGFloat)bottomLineHeight
{
    _bottomLineHeight = bottomLineHeight;
    if (!self.bottomLine) {
        self.bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-bottomLineHeight, self.frame.size.width, bottomLineHeight)];
        self.bottomLine.backgroundColor = self.backgroundColor;
        [self addSubview:self.bottomLine];
    }else{
        self.bottomLine.frame = CGRectMake(0, self.frame.size.height-bottomLineHeight, self.frame.size.width, bottomLineHeight);
    }
}

- (void)setIndicatorLineHeight:(CGFloat)indicatorLineHeight
{
    _indicatorLineHeight = indicatorLineHeight;
    CGRect frame = _scrollIndicatorView.frame;
    frame.size.height = indicatorLineHeight;
    frame.origin.y = self.frame.size.height - indicatorLineHeight;
    _scrollIndicatorView.frame = frame;
}

- (void)setIndicatorLineWidth:(CGFloat)indicatorLineWidth
{
    _indicatorLineWidth = indicatorLineWidth;
    CGRect frame = _scrollIndicatorView.frame;
    frame.size.width = indicatorLineWidth;
    _scrollIndicatorView.frame = frame;
}

- (void)setIndicatorLineLeftEdge:(CGFloat)indicatorLineLeftEdge
{
    _indicatorLineLeftEdge = indicatorLineLeftEdge;
    CGRect frame = _scrollIndicatorView.frame;
    frame.origin.x = indicatorLineLeftEdge;
    _scrollIndicatorView.frame = frame;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _itemCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UMComHorizonCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UMComHorizonCollectionCell" forIndexPath:indexPath];
    cell.index = indexPath.row;
    if (_isTheFirstTime == YES) {
        self.indexPath = indexPath;
        self.currentIndexPath = indexPath;
        _isTheFirstTime = NO;
    }
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(horizonCollectionView:reloadCell:atIndexPath:)]) {
        [self.cellDelegate horizonCollectionView:self reloadCell:cell atIndexPath:indexPath];
    }else if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(reloadCell:atIndexPath:)]) {
        [self.cellDelegate reloadCell:cell atIndexPath:indexPath];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UMComHorizonCollectionCell *cell = (UMComHorizonCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    self.currentIndexPath = indexPath;
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(horizonCollectionView:didSelectedColumn:)]) {
        if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(horizonCollectionView:numbersOfDropdownMenuRowsAtIndexPath:)]) {
            NSInteger numberOfRows = [self.cellDelegate horizonCollectionView:self numbersOfDropdownMenuRowsAtIndexPath:indexPath];
            if (numberOfRows == 0) {
                [UIView animateWithDuration:0.25 animations:^{
                    weakSelf.scrollIndicatorView.center = CGPointMake(cell.frame.origin.x+weakSelf.indicatorLineWidth/2 + _indicatorLineLeftEdge, weakSelf.scrollIndicatorView.center.y);
                }];
                _previewsIndex = _currentIndex;
                self.indexPath = indexPath;
                _currentIndex = indexPath.row;
            }
        }else if (self.cellDelegate && ![self.cellDelegate respondsToSelector:@selector(horizonCollectionView:numbersOfDropdownMenuRowsAtIndexPath:)]){
            _previewsIndex = _currentIndex;
            self.indexPath = indexPath;
            _currentIndex = indexPath.row;
            [UIView animateWithDuration:0.25 animations:^{
                weakSelf.scrollIndicatorView.center = CGPointMake(cell.frame.origin.x+weakSelf.indicatorLineWidth/2 + _indicatorLineLeftEdge, weakSelf.scrollIndicatorView.center.y);
            }];
        }
        
        [self.cellDelegate horizonCollectionView:self didSelectedColumn:indexPath.row];
    }else if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(horizonCollectionView:didSelectedColumn:row:)]) {
        _previewsIndex = _currentIndex;
        _currentIndex = indexPath.row;
        self.indexPath = indexPath;
        NSIndexPath *rowIndexPath = [self.indexPathsDict valueForKey:[NSString stringWithFormat:@"%d",(int)indexPath.row]];
        [self.cellDelegate horizonCollectionView:self didSelectedColumn:indexPath.row row:rowIndexPath.row];
    }
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(horizonCollectionView:showDropDownMenuAtIndexPath:)]) {
        if ([self.cellDelegate horizonCollectionView:self showDropDownMenuAtIndexPath:indexPath]) {
            [self showDropdownMenuViewBelowAtIndexPath:indexPath];
        }else{
            self.dropdownMenuView.hidden = YES;
        }
    }else{
        self.dropdownMenuView.hidden = YES;
    }
    [self reloadData];
}

- (void)setDropMenuTopMargin:(CGFloat)dropMenuTopMargin
{
    _dropMenuTopMargin = dropMenuTopMargin;
    CGRect frame = self.dropdownMenuView.frame;
    frame.origin.y = dropMenuTopMargin;
    self.dropdownMenuView.frame = frame;
}

- (void)setDropMenuViewWidth:(CGFloat)dropMenuViewWidth
{
    _dropMenuViewWidth = dropMenuViewWidth;
    CGRect frame = self.dropdownMenuView.frame;
    frame.size.width = dropMenuViewWidth;
    self.dropdownMenuView.frame = frame;
}

- (void)showDropdownMenuViewBelowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(horizonCollectionView:numbersOfDropdownMenuRowsAtIndexPath:)]) {
        NSInteger numberOfRows = [self.cellDelegate horizonCollectionView:self numbersOfDropdownMenuRowsAtIndexPath:indexPath];
        UMComHorizonCollectionCell *cell = (UMComHorizonCollectionCell *)[self cellForItemAtIndexPath:indexPath];
        if (numberOfRows > 0) {
            CGFloat edge_top = 10;
            if (!self.dropdownMenuView) {
                self.dropdownMenuView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.dropMenuTopMargin, self.dropMenuViewWidth, 50)];
                self.dropdownMenuView.userInteractionEnabled = YES;
                UIImage *strechImage = [UMComImageWithImageName(@"um_dropdownbg_forum") resizableImageWithCapInsets:UIEdgeInsetsMake(10, 30, 0, 0) resizingMode:UIImageResizingModeStretch];
                self.dropdownMenuView.image = strechImage;
                [self.dropMenuSuperView addSubview:self.dropdownMenuView];
                self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, edge_top, self.dropdownMenuView.frame.size.width, 45) style:UITableViewStylePlain];
                self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                self.tableView.backgroundColor = [UIColor clearColor];
                self.tableView.delegate = self;
                self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                self.tableView.rowHeight = self.dropMenuRowHeight;
                self.tableView.dataSource = self;
                [self.dropdownMenuView addSubview:self.tableView];
                self.dropdownMenuView.hidden = YES;
            }
            if (self.dropdownMenuView.hidden == YES) {
                self.dropdownMenuView.hidden = NO;
                [self.dropMenuSuperView bringSubviewToFront:self.dropdownMenuView];
                [self.tableView reloadData];
                self.dropdownMenuView.frame = CGRectMake(self.dropdownMenuView.frame.origin.x, self.dropdownMenuView.frame.origin.y, self.dropdownMenuView.frame.size.width, self.dropMenuRowHeight * numberOfRows + edge_top+2);
                if (self.contentOffset.x > 0) {
                    self.dropdownMenuView.center = CGPointMake(self.contentOffset.x+self.frame.origin.x+_dropMenuLeftMargin, self.dropdownMenuView.center.y);
                }else{
                    self.dropdownMenuView.center = CGPointMake(cell.center.x+self.frame.origin.x+_dropMenuLeftMargin, self.dropdownMenuView.center.y);
                }
                [self.tableView reloadData];
            }else{
                self.dropdownMenuView.hidden = YES;
            }
            
        }else{
            self.dropdownMenuView.hidden = YES;
        }
    }else{
        self.dropdownMenuView.hidden = YES;
    }
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return _itemSize;
}


#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(horizonCollectionView:numbersOfDropdownMenuRowsAtIndexPath:)]) {
        return [self.cellDelegate horizonCollectionView:self numbersOfDropdownMenuRowsAtIndexPath:self.currentIndexPath];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellID";
    UMComDropdownColumnCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UMComDropdownColumnCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId cellSize:CGSizeMake(tableView.frame.size.width, self.dropMenuRowHeight)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSIndexPath *rowIndexPath = [self.indexPathsDict valueForKey:[NSString stringWithFormat:@"%d",(int)_currentIndex]];
    
    if (indexPath.row == rowIndexPath.row) {
        cell.customImageView.backgroundColor = UMComColorWithColorValueString(@"F5F5F5");
        cell.label.textColor = UMComColorWithColorValueString(@"#008BEA");
    }else{
        cell.customImageView.backgroundColor = [UIColor clearColor];
        cell.label.textColor = UMComColorWithColorValueString(@"#999999");
    }
    cell.column = _currentIndex;
    cell.row = indexPath.row;
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(horizonCollectionView:reloadDropdownMuneCell:column:row:)]) {
        [self.cellDelegate horizonCollectionView:self reloadDropdownMuneCell:cell column:self.currentIndexPath.row row:indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    _previewsIndex = self.currentIndex;
    _currentIndex = self.currentIndexPath.row;
    
    UMComHorizonCollectionCell *preCell = (UMComHorizonCollectionCell *)[self cellForItemAtIndexPath:self.indexPath];
    
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(horizonCollectionView:reloadCell:atIndexPath:)]) {
        [self.cellDelegate horizonCollectionView:self reloadCell:preCell atIndexPath:self.indexPath];
    }
    self.indexPath = self.currentIndexPath;
    [self.indexPathsDict setValue:indexPath forKey:[NSString stringWithFormat:@"%d",(int)_currentIndex]];
    UMComHorizonCollectionCell *mainViewCell = (UMComHorizonCollectionCell *)[self cellForItemAtIndexPath:self.currentIndexPath];

    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(horizonCollectionView:reloadCell:atIndexPath:)]) {
        [self.cellDelegate horizonCollectionView:self reloadCell:mainViewCell atIndexPath:self.currentIndexPath];
    }
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.scrollIndicatorView.center = CGPointMake(mainViewCell.frame.origin.x+weakSelf.indicatorLineWidth/2 + _indicatorLineLeftEdge, weakSelf.scrollIndicatorView.center.y);
    }];
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(horizonCollectionView:didSelectedColumn:row:)]) {
        [self.cellDelegate horizonCollectionView:self didSelectedColumn:_currentIndex row:indexPath.row];
    }
    [tableView reloadData];
    self.dropdownMenuView.hidden = YES;
}

- (void)hiddenDropMenuView
{
    self.dropdownMenuView.hidden = YES;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

//- (void)drawRect:(CGRect)rect
//{
//    UIColor *color = [UIColor redColor];
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
//    CGContextFillRect(context, rect);
//    CGContextSetStrokeColorWithColor(context, color.CGColor);
//    CGFloat itemSpaceTopEdge = 6;
//    for (int index = 1; index < self.itemCount; index++) {
//          CGContextStrokeRect(context, CGRectMake(index * self.itemSize.width, itemSpaceTopEdge, self.itemSpace, rect.size.height - itemSpaceTopEdge*2));
//    }
//}

@end


@implementation UMComHorizonCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-1)];
        self.imageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.imageView];
        
        self.label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-1)];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.font = UMComFontNotoSansLightWithSafeSize(15);
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = [UIColor blackColor];
        self.label.numberOfLines = 0;
        [self.contentView addSubview:self.label];
    }
    return self;
}


@end


@implementation UMComDropdownColumnCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)size
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.customImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5 , 0, size.width-10, size.height)];
        self.customImageView.backgroundColor = [UIColor clearColor];
        self.customImageView.layer.cornerRadius = 5;
        self.customImageView.clipsToBounds = YES;
        self.customImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:self.customImageView];
        
        self.label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.font = UMComFontNotoSansLightWithSafeSize(15);
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = [UIColor blackColor];
        self.label.numberOfLines = 0;
        self.label.userInteractionEnabled = YES;
        [self.contentView addSubview:self.label];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)reloadCellWithTitle:(NSString *)title image:(UIImage *)image
{
    self.label.text = title;
    if (image) {
        self.customImageView.image = image;
    }
}


@end