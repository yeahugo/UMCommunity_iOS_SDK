//
//  UMComEditViewModel.m
//  UMCommunity
//
//  Created by Gavin Ye on 9/9/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComEditViewModel.h"
#import "UMComSession.h"
#import "UMComHttpManager.h"
#import "UMComPushRequest.h"
#import "UMComFeedEntity.h"
#import "UMComUser.h"
#import "UMComTopic.h"
#define Permission_bulletin @"permission_bulletin"


@interface UMComEditViewModel ()<UIAlertViewDelegate>
@property (nonatomic, strong) UMComFeedEntity *feedEntity;
@property (nonatomic, copy) void (^selectedFeedTypeBlock)(NSNumber *type);
@end

@implementation UMComEditViewModel

-(id)init
{
    self = [super init];
    if (self) {
        NSMutableString *editString = [[NSMutableString alloc] init];
        self.editContent = editString;
        self.followers = [[NSMutableArray alloc] init];
        self.topics = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addObserver:(id)observer forkeyPath:(NSString *)keyPath
{
    [self addObserver:observer forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)editContentAppendKvoString:(NSString *)appendString
{
    if(!self.editContent)
    {
        self.editContent = [[NSMutableString alloc] init];
    }
    
    NSMutableString *editString = self.editContent;
    if (editString.length >= self.seletedRange.location) {
        NSRange tempRange = self.seletedRange;
        [editString insertString:appendString atIndex:tempRange.location];
        self.seletedRange = NSMakeRange(tempRange.location+appendString.length, 0);
    }
    [self setValue:editString forKey:@"editContent"];
}


- (void)postEditContentWithImages:(NSArray *)images
                        response:(void (^)(id responseObject,NSError *error))response
{
    self.feedEntity = [[UMComFeedEntity alloc] init];
    if (self.editContent && self.editContent.length > 0) {
        self.feedEntity.text = self.editContent;
    }
    if (self.locationDescription) {
        self.feedEntity.locationDescription = self.locationDescription;
        self.feedEntity.location = self.location;
    }
    if (self.topics) {
        NSMutableArray *topicIds = [NSMutableArray array];
        for (UMComTopic * topic in self.topics) {
            [topicIds addObject:topic.topicID];
        }
        self.feedEntity.topicIDs = topicIds;
    }
    if (self.followers) {
        NSMutableArray *userIds = [NSMutableArray array];
        for (UMComUser * user in self.followers) {
            [userIds addObject:user.uid];
        }
        self.feedEntity.atUserIds = userIds;
    }
    if (images && images.count > 0) {
        self.feedEntity.images = images;
    }

    if ([self isPermission_bulletin]) {
        __weak UMComEditViewModel *weakSelf = self;
        self.selectedFeedTypeBlock = ^(NSNumber *type){
            [UMComCreateFeedRequest postWithFeed:weakSelf.feedEntity completion:^(NSError *error) {
                if (response) {
                    response(nil, error);
                }
                UMComUser *user = [UMComSession sharedInstance].loginUser;
                if (error.code == 10004 && [user.permissions containsObject:Permission_bulletin]) {
                    [user.permissions removeObject:Permission_bulletin];
                    [weakSelf showResetFeedTypeNotice];
                }
            }];
        };
        [self showFeedTypeNotice];
    }else{
        [UMComCreateFeedRequest postWithFeed:self.feedEntity completion:^(NSError *error) {
            if (response) {
                response(nil, error);
            }
        }];
    }
}


- (BOOL)isPermission_bulletin
{
    UMComUser *user = [UMComSession sharedInstance].loginUser;
    BOOL isPermission_bulletin = NO;
    if ([[UMComSession sharedInstance].loginUser.account_type intValue] == 1 && [user.permissions containsObject:Permission_bulletin]) {
        isPermission_bulletin = YES;
    }
    return isPermission_bulletin;
}

- (void)showFeedTypeNotice
{
   UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:UMComLocalizedString(@"public feed", @"是否需要将本条内容标记为公告？") delegate:self cancelButtonTitle:UMComLocalizedString(@"NO", @"否") otherButtonTitles:UMComLocalizedString(@"YES", @"是"), nil];
    alertView.tag = 10001;
    [alertView show];
}

- (void)showResetFeedTypeNotice
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:UMComLocalizedString(@"no privilege creat feed", @"你没有发公告的权限，是否标记为非公告重新发送？") delegate:self cancelButtonTitle:UMComLocalizedString(@"NO", @"否") otherButtonTitles:UMComLocalizedString(@"YES", @"是"), nil];
    alertView.tag = 10002;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSNumber *type = @0;
    if (alertView.tag == 10001) {
        type = [NSNumber numberWithInteger:buttonIndex];
        if (self.selectedFeedTypeBlock) {
            self.feedEntity.type = type;
            self.selectedFeedTypeBlock(type);
        }
    }else{
        if (buttonIndex == 1) {
            if (self.selectedFeedTypeBlock) {
                self.feedEntity.type = type;
                self.selectedFeedTypeBlock(type);
            }
        }
    }

}

- (void)postForwardFeed:(UMComFeed *)forwardFeed
               response:(void (^)(id responseObject,NSError *error))response
{
    NSMutableArray *uids = [NSMutableArray arrayWithCapacity:1];
    for (UMComUser *user in self.followers) {
        [uids addObject:user.uid];
    }
    for (UMComUser *user in forwardFeed.related_user) {
        if (![uids containsObject:user.uid]) {
            [uids addObject:user.uid];
        }
    }
    UMComFeed *originFeed = forwardFeed;
    while (originFeed.origin_feed) {
        if (![uids containsObject:originFeed.creator.uid]) {
            [uids addObject:originFeed.creator.uid];
        }
        originFeed = originFeed.origin_feed;
    }
    
    self.feedEntity = [[UMComFeedEntity alloc] init];
    self.feedEntity.atUserIds = uids;
    self.feedEntity.text = self.editContent;
    [UMComForwardFeedReqeust forwardWithFeedId:forwardFeed.feedID newFeed:self.feedEntity completion:^(id responseObject, NSError *error) {
        if (response) {
            response(responseObject,error);
        }
    }];
}


@end
