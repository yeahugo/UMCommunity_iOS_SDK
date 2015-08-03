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

const CGFloat A_WEEK_SECONDES = 60*60*24*7;



@interface UMComPhotoAlbumViewController ()<UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *albumCollectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) UMComUserAlbumRequest *albumRequest;

@property (nonatomic, strong) NSArray *imageUrlDicts;



@end

@implementation UMComPhotoAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonWithImage];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection =UICollectionViewScrollDirectionVertical;
    layout.minimumInteritemSpacing = 2;
    layout.minimumLineSpacing = 2;
    layout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    self.layout = layout;
    self.albumCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:layout];
    self.albumCollectionView.delegate = self;
    self.albumCollectionView.dataSource = self;
    self.albumCollectionView.backgroundColor = [UIColor whiteColor];
    self.albumCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    [self.albumCollectionView registerClass:[UMComPhotoAlbumCollectionCell class] forCellWithReuseIdentifier:@"PhotoAlbumCollectionCell"];
    [self.view addSubview:self.albumCollectionView];
    
    [self requestRemoteImageUrlList];
    
    // Do any additional setup after loading the view from its nib.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGFloat itemWidth = (self.view.frame.size.width-8)/3;
    self.layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    [self.albumCollectionView reloadData];
}

- (void)requestRemoteImageUrlList
{
    if (!self.albumRequest) {
        UMComUserAlbumRequest *albumRequest = [[UMComUserAlbumRequest alloc]initWithCount:BatchSize fuid:self.user.uid];
        self.albumRequest = albumRequest;
    }
    [self.albumRequest fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
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
        self.imageUrlDicts = imageUrls;
        [self.albumCollectionView reloadData];
    }];
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageUrlDicts.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UMComPhotoAlbumCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoAlbumCollectionCell" forIndexPath:indexPath];
    NSArray *subImageUrls = self.imageUrlDicts[indexPath.row];
    [cell.imageView setImageURL:subImageUrls[0] placeHolderImage:[UIImage imageNamed:@"image-placeholder"]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    UMComGridViewerController *viewerController = [[UMComGridViewerController alloc] initWithArray:self.imageUrlDicts index:indexPath.row];
    [viewerController setCacheSecondes:A_WEEK_SECONDES];
    [self presentViewController:viewerController animated:YES completion:nil];
}


//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
//{
//
//    return self.layout.itemSize;
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




@implementation UMComPhotoAlbumCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat imageWidth = frame.size.width;
        self.imageView = [[[UMComImageView imageViewClassName] alloc] initWithFrame:CGRectMake(0, 0, imageWidth, imageWidth)];
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

@end
