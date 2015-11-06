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
    self.postImages = images;
    [UMComSession sharedInstance].editViewModel = self;    
    self.feedEntity = [[UMComFeedEntity alloc] init];
    if (self.editContent && self.editContent.length > 0) {
        self.feedEntity.text = self.editContent;
    }
    if (self.locationDescription) {
        self.feedEntity.locationDescription = self.locationDescription;
        self.feedEntity.location = self.location;
    }
    if (self.topics) {
        self.feedEntity.topics = self.topics;
    }
    if (self.followers) {
        self.feedEntity.atUsers = self.followers;
    }
    if (images && images.count > 0) {
        self.feedEntity.images = images;
    }

    __weak UMComEditViewModel *weakSelf = self;
    if ([self isPermission_bulletin]) {
        self.selectedFeedTypeBlock = ^(NSNumber *type){
            [UMComCreateFeedRequest postWithFeed:weakSelf.feedEntity completion:^(id responseObject, NSError *error) {
                
                if (response) {
                    response(responseObject, error);
                }
                UMComUser *user = [UMComSession sharedInstance].loginUser;
                if (error.code == 10004 && [user.permissions containsObject:Permission_bulletin]) {
                    [user.permissions removeObject:Permission_bulletin];
                    [weakSelf showResetFeedTypeNotice];
                }
                
                if (error) {
                    //一旦发送失败会保存到草稿箱
                    [UMComSession sharedInstance].draftFeed = weakSelf.feedEntity;
                } else {
                    [UMComSession sharedInstance].draftFeed = nil;
                }
            }];
        };
        [self showFeedTypeNotice];
    }else{
        [UMComCreateFeedRequest postWithFeed:self.feedEntity completion:^(id responeObject,NSError *error) {
            if (error) {
                //一旦发送失败会保存到草稿箱
                [UMComSession sharedInstance].draftFeed = weakSelf.feedEntity;
            } else {
                [UMComSession sharedInstance].draftFeed = nil;
            }
            
            if (response) {
                response(responeObject, error);
            }
        }];
    }
}


- (BOOL)isPermission_bulletin
{
    UMComUser *user = [UMComSession sharedInstance].loginUser;
    BOOL isPermission_bulletin = NO;
    if ([[UMComSession sharedInstance].loginUser.atype intValue] == 1 && [user.permissions containsObject:Permission_bulletin]) {
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
    NSMutableArray *atUsers = [NSMutableArray arrayWithCapacity:1];
    for (UMComUser *user in self.followers) {
        [atUsers addObject:user];
    }
    UMComFeed *originFeed = forwardFeed;
    while (originFeed.origin_feed) {
        if (![atUsers containsObject:originFeed.creator]) {
            [atUsers addObject:originFeed.creator];
        }
        originFeed = originFeed.origin_feed;
    }
    self.feedEntity = [[UMComFeedEntity alloc] init];
    
    self.feedEntity.atUsers = atUsers;
    self.feedEntity.text = self.editContent;
    [UMComForwardFeedReqeust forwardWithFeedId:forwardFeed.feedID newFeed:self.feedEntity completion:^(id responseObject, NSError *error) {
        if (response) {
            response(responseObject,error);
        }
    }];
}


@end
