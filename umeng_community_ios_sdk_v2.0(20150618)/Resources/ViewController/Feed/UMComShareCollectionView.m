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
#import "UMComHttpManager.h"
#import "UMComFeed.h"

#define MaxShareLength 140
#define MaxLinkLength 10

@interface UMComShareCollectionView ()<UMSocialUIDelegate>

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UICollectionView *shareCollectionView;

@property (nonatomic, strong) NSArray *imageNameList;
@property (nonatomic, strong) NSArray *titleList;
@property (nonatomic, strong) NSArray *platformArray;

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
        
        self.titleList = [NSArray arrayWithObjects:@"新浪微博",@"朋友圈",@"微信",@"Qzone",@"QQ", nil];
        
        UMSocialSnsPlatform *sinaSnsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
        UMSocialSnsPlatform *wechatTimelinePlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatTimeline];
        UMSocialSnsPlatform *wechatSessionPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
        UMSocialSnsPlatform *qzonePlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQzone];
        UMSocialSnsPlatform *qqPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
        self.platformArray = [NSArray arrayWithObjects:sinaSnsPlatform,wechatTimelinePlatform,wechatSessionPlatform,qzonePlatform,qqPlatform,nil];
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
    UMSocialSnsPlatform *socialPlatform = [self.platformArray objectAtIndex:indexPath.row];
    
    UMComFeed *shareFeed = nil;
    if (self.feed.origin_feed) {
        shareFeed = self.feed.origin_feed;
    } else{
        shareFeed = self.feed;
    }
    
    NSString *imageUrl = [[shareFeed.images firstObject] valueForKey:@"origin"];
    
    NSString *urlString = shareFeed.share_link;
    urlString = [NSString stringWithFormat:@"%@?ak=%@&platform=%@",urlString,[UMComSession sharedInstance].appkey,socialPlatform.platformName];
    [UMSocialData defaultData].extConfig.qqData.url = urlString;
    [UMSocialData defaultData].extConfig.qzoneData.url = urlString;
    [UMSocialData defaultData].extConfig.wechatSessionData.url = urlString;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = urlString;
    
    NSString *shareText = [NSString stringWithFormat:@"%@ %@",shareFeed.text,urlString];
    if (shareFeed.text.length > MaxShareLength - MaxLinkLength) {
        NSString *feedString = [shareFeed.text substringToIndex:MaxShareLength - MaxLinkLength];
        shareText = [NSString stringWithFormat:@"%@ %@",feedString,urlString];
    }
    [UMSocialData defaultData].extConfig.sinaData.shareText = shareText;
    
    [UMSocialData defaultData].title = shareFeed.text;
    if (imageUrl) {
        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:imageUrl];
    }
    [[UMSocialControllerService defaultControllerService] setShareText:shareFeed.text shareImage:[UIImage imageNamed:@"icon"] socialUIDelegate:nil];
    
    [UMSocialControllerService defaultControllerService].socialUIDelegate = self;
    socialPlatform.snsClickHandler(self.shareViewController,[UMSocialControllerService defaultControllerService],YES);

    if (self.didSelectedIndex) {
        self.didSelectedIndex(indexPath);
    }
}

- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    if (response.responseCode == UMSResponseCodeSuccess) {
        NSString *platform = [[response.data allKeys] objectAtIndex:0];
        if (self.feed.origin_feed) {
            [UMComHttpManager shareCallback:platform feedId:self.feed.origin_feed.feedID response:nil];
        } else {
            [UMComHttpManager shareCallback:platform feedId:self.feed.feedID response:nil];
        }
    }
}

@end




#pragma mark  -  cell init method
@implementation UMComCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat imageWidth = frame.size.height/3;
        CGFloat titleHeight = imageWidth/2;
        CGFloat imageOriginY = (frame.size.height - imageWidth- titleHeight)/2-5;
        self.portrait = [[UIImageView alloc]initWithFrame:CGRectMake((frame.size.width-imageWidth)/2, imageOriginY, imageWidth, imageWidth)];
        [self.contentView addSubview:self.portrait];
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, frame.size.height-titleHeight-imageOriginY, frame.size.width, titleHeight)];
        self.titleLabel.font = UMComFontNotoSansLightWithSafeSize(14);
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UMComTools colorWithHexString:FontColorGray];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

@end
