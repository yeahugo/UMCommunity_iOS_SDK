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

@interface UMComUserCenterCollectionView ()
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign) BOOL isHasNextPage;
@end


@implementation UMComUserCenterCollectionView
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    UICollectionViewFlowLayout *currentLayout = (UICollectionViewFlowLayout *)layout;
    if (!currentLayout) {
        currentLayout = [[UICollectionViewFlowLayout alloc]init];
        currentLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        currentLayout.minimumInteritemSpacing = 2;
        currentLayout.minimumLineSpacing = 2;
        CGFloat itemWidth = (frame.size.width-currentLayout.minimumInteritemSpacing*5)/4;
        currentLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    }
    self = [super initWithFrame:frame collectionViewLayout:currentLayout];
    if (self) {
        self.userList = [NSMutableArray array];
        self.delegate = self;
        self.dataSource = self;
        [self registerClass:[UMComUserCollectionViewCell class] forCellWithReuseIdentifier:@"UMComUserCollectionViewCell"];
        self.backgroundColor = [UIColor whiteColor];
        
        self.tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
        self.tipLabel.font = UMComFontNotoSansDemiWithSafeSize(15);
        self.tipLabel.backgroundColor = [UIColor clearColor];
        self.tipLabel.textAlignment = NSTextAlignmentCenter;
        self.tipLabel.hidden = YES;
        self.tipLabel.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        [self addSubview:self.tipLabel];
        
        self.indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:self.indicatorView];
        self.isHasNextPage = NO;
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   return self.userList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UMComUserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UMComUserCollectionViewCell" forIndexPath:indexPath];
    [cell showWithUser:[self.userList objectAtIndex:indexPath.row]];
    __weak UMComUserCenterCollectionView *weakSelf = self;
    cell.clickAtUser = ^(UMComUser *user){
        UMComUserCenterViewController *userCenterVc = [[UMComUserCenterViewController alloc]initWithUser:user];
        [weakSelf.viewController.navigationController pushViewController:userCenterVc animated:YES];
    };
    return cell;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float offset = scrollView.contentOffset.y;
    //下拉刷新
    if (offset < -65.0) {
        [self.indicatorView startAnimating];
        self.indicatorView.center = CGPointMake(self.frame.size.width/2, -40);
    } //上拉加载更多
    else if (offset > 0 && scrollView.contentOffset.y > scrollView.contentSize.height - (scrollView.superview.frame.size.height - 65)) {
        if (self.isHasNextPage == YES) {
            self.indicatorView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height-40);
            [self.indicatorView startAnimating];
        }
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    float offset = scrollView.contentOffset.y;
    //下拉刷新
    if (offset < -65.0) {
          self.indicatorView.center = CGPointMake(self.frame.size.width/2, -20);
        [self refreshAllData];
    } //上拉加载更多
    else if (offset > 0 && scrollView.contentOffset.y > scrollView.contentSize.height - (scrollView.superview.frame.size.height - 65)) {
        if (self.isHasNextPage == YES) {
            self.indicatorView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height+20);
            [self.indicatorView startAnimating];
            [self.fecthRequest fetchNextPageFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
                [self.indicatorView stopAnimating];
                self.isHasNextPage = haveNextPage;
                if (data.count > 0) {
                    [self.userList addObjectsFromArray:data];
                }
                [self reloadData];
            }];
        }
    }
}

- (void)refreshUsersList
{
    self.indicatorView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self.indicatorView startAnimating];
    [self refreshAllData];
}


- (void)refreshAllData
{
    [self.fecthRequest fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        [self.indicatorView stopAnimating];
        self.isHasNextPage = haveNextPage;
        if (error) {
            if ([self.fecthRequest isKindOfClass:[UMComFollowersRequest class]]) {
                if (self.user.followers.array.count > 0) {
                    self.userList = [NSMutableArray arrayWithArray:self.user.followers.array];
                }
            } else {
                if (self.user.fans.array.count > 0) {
                    self.userList = [NSMutableArray arrayWithArray:self.user.fans.array];
                }
            }
            self.tipLabel.hidden = YES;
        }else{
            if (data.count > 0) {
                self.userList = [NSMutableArray arrayWithArray:data];
                self.tipLabel.hidden = YES;
            }else{
                self.tipLabel.hidden = NO;
                [self showNoticeWithFecthClass:[self.fecthRequest class]];
            }
        }
        [self reloadData];
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
