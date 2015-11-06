//
//  UMComPhotoAlbumViewController.m
//  UMCommunity
//
//  Created by umeng on 15/7/7.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComPhotoAlbumViewController.h"
#import "UMComImageView.h"
#import "UMComPullRequest.h"
#import "UMComAlbum.h"
#import "UMComGridViewerController.h"
#import "UIViewController+UMComAddition.h"
#import "UMComRefreshView.h"

typedef void (^AlbumLoadCompletionHandler)(NSArray *data, NSError *error);

const CGFloat A_WEEK_SECONDES = 60*60*24*7;



@interface UMComPhotoAlbumViewController ()<UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UMComRefreshViewDelegate>

@property (nonatomic, strong) UICollectionView *albumCollectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) UMComUserAlbumRequest *albumRequest;

@property (nonatomic, strong) NSArray *imageUrlDicts;

@property (nonatomic, strong) UMComRefreshView *refreshViewController;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, assign) BOOL haveNextPage;


@end

@implementation UMComPhotoAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonWithImage];
    [self setTitleViewWithTitle:UMComLocalizedString(@"My_album", @"相册")];
    UMComUserAlbumRequest *albumRequest = [[UMComUserAlbumRequest alloc]initWithCount:BatchSize fuid:self.user.uid];
    self.albumRequest = albumRequest;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection =UICollectionViewScrollDirectionVertical;
    layout.minimumInteritemSpacing = 2;
    layout.minimumLineSpacing = 2;
    layout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, kUMComRefreshOffsetHeight);
    layout.footerReferenceSize = CGSizeMake(self.view.frame.size.width, kUMComLoadMoreOffsetHeight);
    self.layout = layout;
    self.albumCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, -kUMComRefreshOffsetHeight, self.view.frame.size.width, self.view.frame.size.height+kUMComRefreshOffsetHeight) collectionViewLayout:layout];
    self.albumCollectionView.backgroundColor = [UIColor whiteColor];
    self.albumCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    [self.albumCollectionView registerClass:[UMComPhotoAlbumCollectionCell class] forCellWithReuseIdentifier:@"PhotoAlbumCollectionCell"];
    [self.view addSubview:self.albumCollectionView];

    self.indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    self.indicatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.indicatorView];
    
    __weak typeof(self) weakSelf = self;
    [self fecthCoreDataImageUrlList:^(NSArray *data, NSError *error) {
        [weakSelf fecthRemoteImageUrlList:nil];
    }];

    self.refreshViewController = [[UMComRefreshView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kUMComRefreshOffsetHeight) ScrollView:self.albumCollectionView];
    self.refreshViewController.refreshDelegate = self;
    
    [self.albumCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];//注册header的view
    [self.albumCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footView"];//注册footView的view
    
    // Do any additional setup after loading the view from its nib.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.albumCollectionView.delegate = self;
    self.albumCollectionView.dataSource = self;
    CGFloat itemWidth = (self.view.frame.size.width-8)/3;
    self.layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    [self.albumCollectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)fecthCoreDataImageUrlList:(AlbumLoadCompletionHandler)handler
{
    [self.indicatorView startAnimating];
    __weak typeof(self) weakSelf = self;
    [self.albumRequest fetchRequestFromCoreData:^(NSArray *data, NSError *error) {
        if (!error && [data isKindOfClass:[NSArray class]]) {
            weakSelf.imageUrlDicts = [weakSelf imageUrlDictsWithData:data];
        }
        if (data.count > 0) {
            [weakSelf.indicatorView stopAnimating];
        }
        [weakSelf.albumCollectionView reloadData];
        if (handler) {
            handler(data, error);
        }
    }];
}

- (void)fecthRemoteImageUrlList:(AlbumLoadCompletionHandler)handler
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    __weak typeof(self) weakSelf = self;
    [self.albumRequest fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        [weakSelf.indicatorView stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        weakSelf.haveNextPage = haveNextPage;
        if (!error && [data isKindOfClass:[NSArray class]]) {
            weakSelf.imageUrlDicts = [weakSelf imageUrlDictsWithData:data];
        }
        [weakSelf.albumCollectionView reloadData];
        if (handler) {
            handler(data, error);
        }
    }];
}


- (void)fecthNextPage:(AlbumLoadCompletionHandler)handler
{
    __weak typeof(self) weakSelf = self;
    [self.albumRequest fetchNextPageFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        weakSelf.haveNextPage = haveNextPage;
        if (!error) {
            NSMutableArray *tempArr = [NSMutableArray arrayWithArray:weakSelf.imageUrlDicts];
            [tempArr addObjectsFromArray:[weakSelf imageUrlDictsWithData:data]];
            weakSelf.imageUrlDicts = tempArr;
        }
        [weakSelf.albumCollectionView reloadData];
        if (handler) {
            handler(data, error);
        }
    }];
}

- (NSArray *)imageUrlDictsWithData:(NSArray *)data
{
    NSMutableArray *imageUrls = [NSMutableArray array];
    for (UMComAlbum *album in data) {
        if (album.image_urls) {
            for (NSDictionary * dict in album.image_urls) {
                NSString *thumImageUrl = [dict valueForKey:@"360"];
                NSString *originImageUrl = [dict valueForKey:@"origin"];
                NSArray *subImageUrls = [NSArray arrayWithObjects:thumImageUrl,originImageUrl, nil];
                [imageUrls addObject:subImageUrls];
            }
            //                [imageUrls addObjectsFromArray:album.image_urls];
        }
    }
    return imageUrls;
}

#pragma mark - UMComRefreshViewDelegate
- (void)refreshData:(UMComRefreshView *)refreshView loadingFinishHandler:(RefreshDataLoadFinishHandler)handler
{
    [self fecthRemoteImageUrlList:^(NSArray *data, NSError *error) {
        if (handler) {
            handler(error);
        }
    }];
}

- (void)loadMoreData:(UMComRefreshView *)refreshView loadingFinishHandler:(RefreshDataLoadFinishHandler)handler
{
    [self fecthNextPage:^(NSArray *data, NSError *error) {
        if (handler) {
            handler(error);
        }
    }];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.imageUrlDicts.count < 20) {
        return 20;
    }
    return self.imageUrlDicts.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UMComPhotoAlbumCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoAlbumCollectionCell" forIndexPath:indexPath];
    if (indexPath.row < self.imageUrlDicts.count) {
        NSArray *subImageUrls = self.imageUrlDicts[indexPath.row];
        [cell.imageView setImageURL:subImageUrls[0] placeHolderImage:[UIImage imageNamed:@"image-placeholder"]];
    }else{
        cell.imageView.image = nil;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    UMComGridViewerController *viewerController = [[UMComGridViewerController alloc] initWithArray:self.imageUrlDicts index:indexPath.row];
    [viewerController setCacheSecondes:A_WEEK_SECONDES];
    [self presentViewController:viewerController animated:YES completion:nil];
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
         self.refreshViewController.footView.frame = CGRectMake(0, 0, collectionView.frame.size.width, self.refreshViewController.footView.frame.size.height);
        return footView;
        
    }else{
        UICollectionReusableView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        if (self.refreshViewController.headView.superview != headView) {
            [self.refreshViewController.headView removeFromSuperview];
            [headView addSubview:self.refreshViewController.headView];
        }
        self.refreshViewController.headView.frame = CGRectMake(0, headView.frame.size.height - self.refreshViewController.headView.frame.size.height, self.view.frame.size.width, self.refreshViewController.headView.frame.size.height);
        return headView;
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.refreshViewController refreshScrollViewDidScroll:scrollView haveNextPage:self.haveNextPage];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.refreshViewController refreshScrollViewDidEndDragging:scrollView haveNextPage:_haveNextPage];
}

- (void)dealloc
{
    self.albumCollectionView.delegate = nil;
    self.albumCollectionView.dataSource = nil;
    self.albumCollectionView = nil;
}


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




@implementation UMComPhotoAlbumCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat imageWidth = frame.size.width;
        self.imageView = [[[UMComImageView imageViewClassName] alloc] initWithFrame:CGRectMake(0, 0, imageWidth, imageWidth)];
        self.imageView.needCutOff = YES;
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

@end
