//
//  UMComCollectionView.m
//  UMCommunity
//
//  Created by umeng on 15-4-27.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComShareCollectionView.h"
#import "UMComTools.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMComSession.h"
#import "UMComFeed.h"
#import "UMComLoginManager.h"

#define MaxShareLength 139
#define MaxLinkLength 10

@interface UMComShareCollectionView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UICollectionView *shareCollectionView;
@property (nonatomic, strong) NSArray *imageNameList;
@property (nonatomic, strong) NSArray *titleList;
@property (nonatomic, strong) NSArray *platformArray;
@property (nonatomic, strong) UIView *bgView;

@end

@implementation UMComShareCollectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        CGFloat titleLabelHeight = 30;
        CGFloat cellWidth = frame.size.width/4.61;
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, frame.size.width, titleLabelHeight)];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = UMComFontNotoSansLightWithSafeSize(17);
        self.titleLabel.textColor = [UMComTools colorWithHexString:FontColorGray];
        self.titleLabel.text = UMComLocalizedString(@"share_to", @"分享至");
        [self addSubview:self.titleLabel];
      
        UICollectionViewFlowLayout *myLayout  = [[UICollectionViewFlowLayout alloc]init];
        myLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
        myLayout.minimumInteritemSpacing = 2;
        myLayout.minimumLineSpacing = 2;
        myLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;;
        CGFloat shareViewOriginY = titleLabelHeight + (frame.size.height-titleLabelHeight)/2-cellWidth/2;
        self.shareCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, shareViewOriginY, frame.size.width, cellWidth) collectionViewLayout:myLayout];
        self.shareCollectionView.dataSource = self;
        self.shareCollectionView.delegate = self;
        self.shareCollectionView.backgroundColor  = [UIColor whiteColor];
        self.shareCollectionView.scrollsToTop = NO;
    
        [self.shareCollectionView registerClass:[UMComCollectionViewCell class] forCellWithReuseIdentifier:@"cellID"];
        [self addSubview:self.shareCollectionView];
        self.imageNameList = [NSArray arrayWithObjects:@"um_sina_logo",@"um_friend_logo",@"um_wechat_logo",@"um_qzone_logo",@"um_qq_logo", nil];
        
        self.platformArray = @[UMShareToSina,UMShareToWechatTimeline,UMShareToWechatSession,UMShareToQzone,UMShareToQQ];
        
        self.titleList = @[@"新浪微博",@"朋友圈",@"微信",@"Qzone",@"QQ"];

        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIApplication sharedApplication].keyWindow.frame.size.width, [UIApplication sharedApplication].keyWindow.frame.size.height)];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.2;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(shareViewViewHidden)];
        [bgView addGestureRecognizer:tap];
        self.bgView = bgView;
        
    }
    return self;
}


- (void)reloadData
{
    [self.shareCollectionView reloadData];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageNameList.count;

}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellID";
    UMComCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[UMComCollectionViewCell alloc]initWithFrame:CGRectMake(0, 0, collectionView.frame.size.height, collectionView.frame.size.height)];
    }
    cell.portrait.image = [UIImage imageNamed:self.imageNameList[indexPath.row]];
    cell.titleLabel.text = self.titleList[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *platformName = [self.platformArray objectAtIndex:indexPath.row] ;
    [[UMComLoginManager getLoginHandler] didSelectPlatform:platformName feed:self.feed viewController:self.shareViewController];
    [self shareViewViewHidden];
    if (self.didSelectedIndex) {
        self.didSelectedIndex(indexPath);
    }
}

- (void)shareViewShow
{
    CGFloat heigth = self.frame.size.height;
    [self removeFromSuperview];
    [self.bgView removeFromSuperview];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.bgView.hidden = NO;
    [window addSubview:self.bgView];
    [window addSubview:self];
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(self.frame.origin.x, window.frame.size.height-heigth, self.frame.size.width,heigth);
    }];
}

- (void)shareViewViewHidden
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [UIView animateWithDuration:0.2 animations:^{
        self.bgView.hidden = YES;
        self.frame = CGRectMake(self.frame.origin.x, window.frame.size.height, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.bgView removeFromSuperview];
    }];
}

@end




#pragma mark  -  cell init method
@implementation UMComCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat imageHeight = frame.size.height/3;
        CGFloat imageWidth = frame.size.height/3;

        CGFloat titleHeight = frame.size.height/3;
        CGFloat imageOriginY = (frame.size.height - imageWidth- titleHeight)/2-5;
        self.portrait = [[UIImageView alloc]initWithFrame:CGRectMake((frame.size.width-imageWidth)/2, imageOriginY, imageWidth, imageHeight)];
        [self.contentView addSubview:self.portrait];
        CGFloat imageBottomY = (frame.size.height-imageHeight-imageOriginY);
        CGFloat titleOriginY = (imageBottomY-titleHeight)/2+imageBottomY-3;
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, titleOriginY, frame.size.width, titleHeight)];
        self.titleLabel.font = UMComFontNotoSansLightWithSafeSize(14);
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UMComTools colorWithHexString:FontColorGray];
        [self.contentView addSubview:self.titleLabel];
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

@end
