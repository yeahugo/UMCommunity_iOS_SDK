//
//  UMComUserCollectionViewController.m
//  UMCommunity
//
//  Created by umeng on 15/12/21.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComUserCollectionViewController.h"
#import "UMComUserCollectionViewCell.h"
#import "UMComUserCenterViewController.h"
#import "UMComShowToast.h"
#import "UMComPullRequest.h"
#import "UMComUser.h"
#import "UMComRefreshView.h"
#import "UMComClickActionDelegate.h"
#import "UMComScrollViewDelegate.h"
#import "UMComSession.h"


@interface UMComUserCollectionViewController ()<UMComRefreshViewDelegate>

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign) BOOL haveNextPage;
@property (nonatomic, assign) CGPoint indicatorCenter;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) CGFloat originY;

@end

@implementation UMComUserCollectionViewController

- (instancetype)initWithFetchRequest:(UMComPullRequest *)request
{
    self = [super init];
    if (self) {
        _fecthRequest = request;
    }
    return self;
}

- (void)createCollectionView
{
    UICollectionViewFlowLayout *currentLayout = [[UICollectionViewFlowLayout alloc]init];
    currentLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    currentLayout.minimumInteritemSpacing = 2;
    currentLayout.minimumLineSpacing = 2;
    CGFloat itemWidth = (self.view.frame.size.width-currentLayout.minimumInteritemSpacing*5)/4;
    currentLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    self.itemSize = currentLayout.itemSize;
    currentLayout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, self.headerViewHeight);
    currentLayout.footerReferenceSize = CGSizeMake(self.view.frame.size.width, kUMComLoadMoreOffsetHeight);
    CGRect collectionViewFrame = self.view.bounds;
    self.collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:currentLayout];
    [self.collectionView addSubview:self.tipLabel];
    self.indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.collectionView addSubview:self.indicatorView];
    self.haveNextPage = NO;
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];//注册header的view
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footView"];//注册footView的view
    self.originY = self.collectionView.frame.origin.y;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[UMComUserCollectionViewCell class] forCellWithReuseIdentifier:@"UMComUserCollectionViewCell"];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.refreshViewController = [[UMComRefreshView alloc]initWithFrame:CGRectMake(0, 0, self.collectionView.frame.size.width, kUMComRefreshOffsetHeight) ScrollView:self.collectionView];
    self.refreshViewController.refreshDelegate = self;
    [self.view addSubview:self.collectionView];
    
    self.tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    self.tipLabel.font = UMComFontNotoSansLightWithSafeSize(17);
    self.tipLabel.backgroundColor = [UIColor clearColor];
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    self.tipLabel.textColor = [UMComTools colorWithHexString:FontColorGray];
    self.tipLabel.hidden = YES;
    self.tipLabel.center = CGPointMake(self.collectionView.frame.size.width/2, (self.collectionView.frame.size.height - currentLayout.headerReferenceSize.height)/2+currentLayout.headerReferenceSize.height);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userList = [NSMutableArray array];
    
    [self createCollectionView];
    
    __weak typeof (self) weakSelf = self;
    [self fecthDataFromCoreData:^(NSArray *data, NSError *error) {
        [weakSelf refreshDataFromServer:nil];
    }];
    // Do any additional setup after loading the view.
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
        __weak typeof(self) weakSelf = self;
        cell.clickAtUser = ^(UMComUser *user){
            UMComUserCenterViewController *userCenter = [[UMComUserCenterViewController alloc]initWithUser:user];
            [weakSelf.navigationController pushViewController:userCenter animated:YES];
        };
    }else{
        [cell showWithUser:nil];
    }
    cell.indexPath = indexPath;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemWidth ;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        itemWidth = 150;
    } else {
        itemWidth = (collectionView.frame.size.width-2*5)/4;
        self.itemSize = CGSizeMake(itemWidth, itemWidth);
    }
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
        self.refreshViewController.footView.frame = CGRectMake(0, 0, self.collectionView.frame.size.width, self.refreshViewController.footView.frame.size.height);
        return footView;
    }else{
        UICollectionReusableView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        if (self.refreshViewController.headView.superview != headView) {
            [self.refreshViewController.headView removeFromSuperview];
            [headView addSubview:self.refreshViewController.headView];
        }
        self.refreshViewController.headView.frame = CGRectMake(0, headView.frame.size.height - self.refreshViewController.headView.frame.size.height, self.collectionView.frame.size.width, self.refreshViewController.headView.frame.size.height);
        return headView;
    }
}


- (NSInteger)getUserCount
{
    CGFloat height = self.itemSize.height;
    NSInteger userCount = ((int)self.collectionView.frame.size.height / (int)height)*4;
    if (self.userList.count > userCount) {
        userCount = self.userList.count;
    }
    if (self.userList.count > 0) {
        self.tipLabel.hidden = YES;
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
    self.indicatorView.center = CGPointMake(self.collectionView.frame.size.width/2, (self.collectionView.frame.size.height - self.headerViewHeight)/2+self.headerViewHeight);
    [self.indicatorView startAnimating];
    [self refreshDataFromServer:nil];
}


- (void)fecthDataFromCoreData:(void(^)(NSArray *data, NSError *error))block
{
    if (!self.fecthRequest) {
        [self.indicatorView stopAnimating];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.fecthRequest fetchRequestFromCoreData:^(NSArray *data, NSError *error) {
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
        }else{
            if (data.count > 0) {
                weakSelf.userList = [NSMutableArray arrayWithArray:data];
                weakSelf.tipLabel.hidden = YES;
            }else{
                [weakSelf showNoticeWithFecthClass:[weakSelf.fecthRequest class]];
            }
        }
        [weakSelf.collectionView reloadData];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (weakSelf.ComplictionHandler) {
            weakSelf.ComplictionHandler(strongSelf.collectionView);
        }
        if (block) {
            block(data, error);
        }
    }];
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
        [weakSelf.collectionView reloadData];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (weakSelf.ComplictionHandler) {
            weakSelf.ComplictionHandler(strongSelf.collectionView);
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
        [weakSelf.collectionView reloadData];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (weakSelf.ComplictionHandler) {
            weakSelf.ComplictionHandler(strongSelf.collectionView);
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

- (void)inserUser:(UMComUser *)user atIndex:(NSInteger)index
{
    if (![self.userList containsObject:user]) {
        [self.userList insertObject:user atIndex:index];
        [self.collectionView reloadData];
    }
}

- (void)deleteUser:(UMComUser *)user
{
    if ([self.userList containsObject:user]) {
        
        [self.userList removeObject:user];
        [self.collectionView reloadData];
    }
}

//- (void)inserUserAtRow:(NSInteger)row
//{
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
//    [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
//}
//
//- (void)deleteUserAtRow:(NSInteger)row
//{
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
//    if (indexPath && [self.collectionView cellForItemAtIndexPath:indexPath]) {
//        [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
//    }
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
