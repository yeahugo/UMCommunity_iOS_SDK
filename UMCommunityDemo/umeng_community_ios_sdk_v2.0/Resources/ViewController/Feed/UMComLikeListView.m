//
//  UMComLikeListView.m
//  UMCommunity
//
//  Created by umeng on 15/5/21.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComLikeListView.h"
#import "UMComTools.h"
#import "UMComUser.h"
#import "UMComLike.h"
#import "UMComImageView.h"
#import "UMComFeed.h"

static const CGFloat ButtonHeight = 12;
static const CGFloat ItemWidth = 34;

@interface UMComLikeListView ()<UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UMComFeed *feed;

@property (nonatomic, assign) NSInteger itemCount;

@property (nonatomic, assign) CGSize itemSize;

@end

@implementation UMComLikeListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        CGFloat buttonHeight = 12;
        CGFloat likeButtonOriginY = (frame.size.height-ButtonHeight)/2;
        CGFloat likeButtonOriginX = 15;
        self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.likeButton.frame = CGRectMake(likeButtonOriginX, likeButtonOriginY+0.5, ButtonHeight+2, ButtonHeight);
        [self.likeButton setBackgroundImage:[UIImage imageNamed:@"um_like-"] forState:UIControlStateNormal];
        [self addSubview:self.likeButton];
        
        self.likeCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(likeButtonOriginX+ButtonHeight+3, likeButtonOriginY, ButtonHeight+4, ButtonHeight)];
        self.likeCountLabel.textColor = [UMComTools colorWithHexString:FontColorGray];
        self.likeCountLabel.textAlignment = NSTextAlignmentCenter;
        self.likeCountLabel.text = @"0";
        self.likeCountLabel.font = UMComFontNotoSansLightWithSafeSize(12);
        [self addSubview:self.likeCountLabel];

        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];

        CGFloat likeViewOriginX = self.likeCountLabel.frame.size.width+self.likeCountLabel.frame.origin.x;
        CGFloat likeUserViewWidth = frame.size.width-likeButtonOriginX-likeViewOriginX+4;
    
        CGFloat itemWidth = ItemWidth;//likeUserViewWidth/frame.size.height;
        CGFloat itemHeight = frame.size.height;
        if (itemWidth < itemHeight) {
            itemWidth = itemHeight;
        }
        self.itemCount = likeUserViewWidth/ItemWidth + 1;
        CGFloat itemInterval = (likeUserViewWidth - self.itemCount*itemWidth)/(self.itemCount+1);
        layout.itemSize = CGSizeMake(itemWidth, itemHeight);
        self.itemSize = layout.itemSize;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = itemInterval;
        
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.likeUserListView = [[UICollectionView alloc]initWithFrame:CGRectMake(likeViewOriginX, 0, likeUserViewWidth, frame.size.height) collectionViewLayout:layout];
        self.likeUserListView.scrollsToTop = NO;
        self.likeUserListView.dataSource = self;
        self.likeUserListView.delegate = self;
        self.likeUserListView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        self.likeUserListView.backgroundColor = [UIColor clearColor];
        [self.likeUserListView registerClass:[UMComLikeCollectionViewCell class] forCellWithReuseIdentifier:@"cellID"];
        [self addSubview:self.likeUserListView];
    
    }
    return self;
}


- (void)reloadViewsWithfeed:(UMComFeed *)feed likeArray:(NSArray *)likeArr;
{
    self.likeCountLabel.text = [NSString stringWithFormat:@"%d",(int)[feed.likes_count intValue]];
    self.likeList = likeArr;
    [self.likeUserListView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.likeList.count > 0) {
        if (self.likeList.count >= self.itemCount) {
            return self.itemCount;
        }
        return self.likeList.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellID";
    UMComLikeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.indexPath = indexPath;
    __weak UMComLikeListView *weakSelf = self;
    cell.didSelectedAtIndexPath = ^(NSIndexPath *indexPath){
        [weakSelf didSelectItemAtIndexPath:indexPath];
    };
    if (indexPath.row < self.itemCount-1) {
        UMComLike *like = self.likeList[indexPath.row];
        NSString *iconUrl = [like.creator.icon_url valueForKey:@"240"];
        cell.portrait.layer.cornerRadius = cell.portrait.frame.size.width/2;
        cell.portrait.clipsToBounds = YES;
        [cell.portrait setImageURL:iconUrl placeHolderImage:[UMComImageView placeHolderImageGender:like.creator.gender.integerValue]];
    }else{
        cell.portrait.image = [UIImage imageNamed:@"um_more"];
    }
    return cell;
}

- (void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.itemCount-1) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnUser:)]) {
            UMComLike *like = self.likeList[indexPath.row];
            [self.delegate customObj:self clickOnUser:like.creator];
        }
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clikeOnMoreButton:)]) {
            [self.delegate customObj:self clikeOnMoreButton:nil];
        }
    }

    if (self.didSelectedIndex) {
        self.didSelectedIndex(indexPath);
    }
}

- (void)didClickOnLikeButton:(UIButton *)sender
{
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
@end

@implementation UMComLikeCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat imageWidth = 20;
        self.portrait = [[[UMComImageView imageViewClassName] alloc]initWithFrame:CGRectMake((frame.size.width-imageWidth)/2, (frame.size.height-imageWidth)/2, imageWidth, imageWidth)];
        self.portrait.image = [UIImage imageNamed:@"fale"];
        [self.contentView addSubview:self.portrait];
        self.contentView.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didSelectedIndex)];
        [self addGestureRecognizer:tap];

    }
    return self;
}

- (void)didSelectedIndex
{
    if (self.didSelectedAtIndexPath) {
        self.didSelectedAtIndexPath(self.indexPath);
    }
}

@end
