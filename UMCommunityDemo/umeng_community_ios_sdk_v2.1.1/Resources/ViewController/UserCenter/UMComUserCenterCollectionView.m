//
//  UMComUserCenterCollectionView.m
//  UMCommunity
//
//  Created by umeng on 15/5/6.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComUserCenterCollectionView.h"
#import "UMComUserCollectionViewCell.h"
#import "UMComUserCenterViewController.h"
#import "UMComShowToast.h"
#import "UMComPullRequest.h"
#import "UMComUser.h"
#import "UMComRefreshView.h"
#import "UMComClickActionDelegate.h"
#import "UMComScrollViewDelegate.h"


@interface UMComUserCenterCollectionView ()<UMComRefreshViewDelegate>

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign) BOOL haveNextPage;
@property (nonatomic, assign) CGFloat headerViewHeight;
@property (nonatomic, assign) CGPoint indicatorCenter;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) CGFloat originY;

@end


@implementation UMComUserCenterCollectionView
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    UICollectionViewFlowLayout *currentLayout = layout;
    currentLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    currentLayout.minimumInteritemSpacing = 2;
    currentLayout.minimumLineSpacing = 2;
    CGFloat itemWidth = (frame.size.width-currentLayout.minimumInteritemSpacing*5)/4;
    currentLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    self.itemSize = currentLayout.itemSize;
    self.headerViewHeight = currentLayout.headerReferenceSize.height;
    currentLayout.footerReferenceSize = CGSizeMake(frame.size.width, kUMComLoadMoreOffsetHeight);
    self = [super initWithFrame:frame collectionViewLayout:currentLayout];
    if (self) {
        self.userList = [NSMutableArray array];
        self.delegate = self;
        self.dataSource = self;
        [self registerClass:[UMComUserCollectionViewCell class] forCellWithReuseIdentifier:@"UMComUserCollectionViewCell"];
        self.backgroundColor = [UIColor whiteColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
        self.tipLabel.font = UMComFontNotoSansLightWithSafeSize(17);
        self.tipLabel.backgroundColor = [UIColor clearColor];
        self.tipLabel.textAlignment = NSTextAlignmentCenter;
        self.tipLabel.textColor = [UMComTools colorWithHexString:FontColorGray];
        self.tipLabel.hidden = YES;
        self.tipLabel.center = CGPointMake(frame.size.width/2, (frame.size.height - currentLayout.headerReferenceSize.height)/2+currentLayout.headerReferenceSize.height);
        self.tipLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:self.tipLabel];
        self.indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:self.indicatorView];
        self.haveNextPage = NO;
        [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];//注册header的view
        [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footView"];//注册footView的view
        self.originY = frame.origin.y;
    }
    
    self.refreshViewController = [[UMComRefreshView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, kUMComRefreshOffsetHeight) ScrollView:self];
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self getUserCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UMComUserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UMComUserCollectionViewCell" forIndexPath:indexPath];
    if (indexPath.row < self.userList.count) {
        [cell showWithUser:[self.userList objectAtIndex:indexPath.row]];
        __weak UMComUserCenterCollectionView *weakSelf = self;
        __weak UMComUserCollectionViewCell *weakCell = cell;
        cell.clickAtUser = ^(UMComUser *user){
            if (weakSelf.cellDelegate && [self.cellDelegate respondsToSelector:@selector(customObj:clickOnUser:)]) {
                __strong typeof(weakCell) strongCell = weakCell;
                if (weakCell.indexPath.row < weakSelf.userList.count) {
                    [weakSelf.cellDelegate customObj:strongCell clickOnUser:user];
                }
            }
        };
    }else{
        [cell showWithUser:nil];
    }
    cell.indexPath = indexPath;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemWidth = (collectionView.frame.size.width-2*5)/4;
     self.itemSize = CGSizeMake(itemWidth, itemWidth);
    return self.itemSize;
}


//显示header和footer的回调方法

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath

{
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        UICollectionReusableView *footView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footView" forIndexPath:indexPath];
        if (self.refreshViewController.footView.superview != footView) {
            [self.refreshViewController.footView removeFromSuperview];
            [footView addSubview:self.refreshViewController.footView];
        }
        self.refreshViewController.footView.frame = CGRectMake(0, 0, self.frame.size.width, self.refreshViewController.footView.frame.size.height);
        return footView;
    }else{
        UICollectionReusableView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        if (self.refreshViewController.headView.superview != headView) {
            [self.refreshViewController.headView removeFromSuperview];
            [headView addSubview:self.refreshViewController.headView];
        }
        self.refreshViewController.headView.frame = CGRectMake(0, headView.frame.size.height - self.refreshViewController.headView.frame.size.height, self.frame.size.width, self.refreshViewController.headView.frame.size.height);
        return headView;
    }
}


- (NSInteger)getUserCount
{
    CGFloat height = self.itemSize.height;
    NSInteger userCount = ((int)self.frame.size.height / (int)height)*4;
    if (self.userList.count > userCount) {
        userCount = self.userList.count;
    }
    return userCount;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.scrollViewDelegate && [self.scrollViewDelegate respondsToSelector:@selector(customScrollViewDidScroll:lastPosition:)]) {
        [self.scrollViewDelegate customScrollViewDidScroll:scrollView lastPosition:self.lastPosition];
    }
    [self.refreshViewController refreshScrollViewDidScroll:scrollView haveNextPage:_haveNextPage];
    self.lastPosition = scrollView.contentOffset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.scrollViewDelegate && [self.scrollViewDelegate respondsToSelector:@selector(customScrollViewDidEnd:lastPosition:)]) {
        [self.scrollViewDelegate customScrollViewDidEnd:scrollView lastPosition:self.lastPosition];
    }
    self.lastPosition = scrollView.contentOffset;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.refreshViewController refreshScrollViewDidEndDragging:scrollView haveNextPage:_haveNextPage];
}

#pragma UMComRefreshViewDelegate

- (void)refreshData:(UMComRefreshView *)refreshView loadingFinishHandler:(void (^)(NSError *))handler
{
    [self refreshDataFromServer:^(NSArray *data, NSError *error) {
        if (handler) {
            handler(error);
        }
    }];
}

- (void)loadMoreData:(UMComRefreshView *)refreshView loadingFinishHandler:(void (^)(NSError *))handler
{
    [self fecthNextPageFromServer:^(NSArray *data, NSError *error) {
        if (handler) {
            handler(error);
        }
    }];
}


- (void)refreshUsersList
{
    self.indicatorView.center = CGPointMake(self.frame.size.width/2, (self.frame.size.height - self.headerViewHeight)/2+self.headerViewHeight);
    [self.indicatorView startAnimating];
    [self refreshDataFromServer:nil];
}

- (void)refreshDataFromServer:(void(^)(NSArray *data, NSError *error))block
{
    if (!self.fecthRequest) {
        [self.indicatorView stopAnimating];
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    __weak typeof(self) weakSelf = self;
    [self.fecthRequest fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [weakSelf.indicatorView stopAnimating];
        weakSelf.haveNextPage = haveNextPage;
        if (block) {
            block(data, error);
        }
        if (error) {
            if ([weakSelf.fecthRequest isKindOfClass:[UMComFollowersRequest class]]) {
                if (weakSelf.user.followers.array.count > 0) {
                    weakSelf.userList = [NSMutableArray arrayWithArray:weakSelf.user.followers.array];
                }
            } else {
                if (weakSelf.user.fans.array.count > 0) {
                    weakSelf.userList = [NSMutableArray arrayWithArray:self.user.fans.array];
                }
            }
            [UMComShowToast showFetchResultTipWithError:error];
            weakSelf.tipLabel.hidden = YES;
        }else{
            if (data.count > 0) {
                weakSelf.userList = [NSMutableArray arrayWithArray:data];
                weakSelf.tipLabel.hidden = YES;
            }else{
                weakSelf.tipLabel.hidden = NO;
                [weakSelf showNoticeWithFecthClass:[weakSelf.fecthRequest class]];
            }
        }
        [weakSelf reloadData];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (weakSelf.ComplictionHandler) {
            weakSelf.ComplictionHandler(strongSelf);
        }
    }];
}


- (void)fecthNextPageFromServer:(void(^)(NSArray *data, NSError *error))block
{
    if (!self.fecthRequest) {
        [self.indicatorView stopAnimating];
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    __weak typeof(self) weakSelf = self;
    [self.fecthRequest fetchNextPageFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [weakSelf.indicatorView stopAnimating];
        weakSelf.haveNextPage = haveNextPage;
        if (block) {
            block(data, error);
        }
        if (data.count > 0) {
            [weakSelf.userList addObjectsFromArray:data];
        }
        [weakSelf reloadData];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (weakSelf.ComplictionHandler) {
            weakSelf.ComplictionHandler(strongSelf);
        }
    }];
}

- (void)showNoticeWithFecthClass:(Class)class
{
    if (class == [UMComFansRequest class]) {
        self.tipLabel.text = UMComLocalizedString(@"No_Followers", @"内容为空");
    }else if(class == [UMComFollowersRequest class]){
        self.tipLabel.text = UMComLocalizedString(@"No_FocusPeople", @"内容为空");
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
