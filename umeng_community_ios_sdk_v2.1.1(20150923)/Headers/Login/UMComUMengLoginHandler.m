//
//  UMengLoginHandler.m
//  UMCommunity
//
//  Created by Gavin Ye on 8/25/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComUMengLoginHandler.h"
#import "UMSocial.h"
#import "UMSocialSinaHandler.h"
#import "UMComNavigationController.h"
#import "UMComLoginManager.h"
#import "UMComPushRequest.h"
#import "UMComFeed.h"
#import "UMComSession.h"

#define MaxShareLength 137
#define MaxLinkLength 10

@interface UMComUMengLoginHandler()<UMSocialUIDelegate>

@property (nonatomic, strong) UMComFeed *feed;

@end

@implementation UMComUMengLoginHandler

static UMComUMengLoginHandler *_instance = nil;
+ (UMComUMengLoginHandler *)shareInstance {
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}

- (void)setAppKey:(NSString *)appKey
{
    [UMSocialData setAppKey:appKey];
    
    [UMSocialConfig setFinishToastIsHidden:NO position:UMSocialiToastPositionBottom];
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    return [UMSocialSnsService handleOpenURL:url];
}

- (void)presentLoginViewController:(UIViewController *)viewController finishResponse:(LoadDataCompletion)loginCompletion
{
    UMComLoginViewController *loginViewController = [[UMComLoginViewController alloc] initWithNibName:@"UMComLoginViewController" bundle:nil];
    UMComNavigationController *navigationController = [[UMComNavigationController alloc] initWithRootViewController:loginViewController];
    [viewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)didSelectPlatform:(NSString *)platformName
                     feed:(UMComFeed *)feed
           viewController:(UIViewController *)viewControlller
{
    UMComFeed *shareFeed = nil;
    if (feed.origin_feed) {
        shareFeed = feed.origin_feed;
    } else{
        shareFeed = feed;
    }
    self.feed = feed;
    
    NSString *imageUrl = [[shareFeed.images firstObject] valueForKey:@"360"];
    
    //取转发的feed才有链接
    NSString *urlString = self.feed.share_link;
    urlString = [NSString stringWithFormat:@"%@?ak=%@&platform=%@",urlString,[UMComSession sharedInstance].appkey,platformName];
    [UMSocialData defaultData].extConfig.qqData.url = urlString;
    [UMSocialData defaultData].extConfig.qzoneData.url = urlString;
    [UMSocialData defaultData].extConfig.wechatSessionData.url = urlString;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = urlString;
    
    NSString *shareText = [NSString stringWithFormat:@"%@ %@",shareFeed.text,urlString];
    if (shareFeed.text.length > MaxShareLength+2 - MaxLinkLength) {
        NSString *feedString = [shareFeed.text substringToIndex:MaxShareLength - MaxLinkLength];
        shareText = [NSString stringWithFormat:@"%@…… %@",feedString,urlString];
    }
    [UMSocialData defaultData].extConfig.sinaData.shareText = shareText;
    
    [UMSocialData defaultData].title = shareFeed.text;
    
    UIImage *shareImage = nil;
    if (imageUrl) {
        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:imageUrl];
    } else{
        shareImage = [UIImage imageNamed:@"icon"];
        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeDefault];
    }
    [[UMSocialControllerService defaultControllerService] setShareText:shareFeed.text shareImage:shareImage socialUIDelegate:self];
    
    UMSocialSnsPlatform *socialPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:platformName];
    socialPlatform.snsClickHandler(viewControlller,[UMSocialControllerService defaultControllerService],YES);
}

- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    if (response.responseCode == UMSResponseCodeSuccess) {
        NSString *platform = [[response.data allKeys] objectAtIndex:0];
        [UMComShareStaticsRequest postShareStaticsWithPlatformName:platform feedId:self.feed.feedID completion:nil];
    }
}
@end
