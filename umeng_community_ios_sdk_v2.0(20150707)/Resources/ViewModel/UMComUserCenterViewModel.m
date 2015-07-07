//
//  UMComUserCenterViewModel.m
//  UMCommunity
//
//  Created by Gavin Ye on 9/10/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComUserCenterViewModel.h"
#import "UMComCoreData.h"
#import "UMComSession.h"
#import "UMComTopic.h"
#import "UMComFeed.h"
#import "UMComUser.h"
#import "UMComHttpManager.h"
#import "UMComHttpPagesManager.h"
#import "UMComPullRequest.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComTopic+UMComManagedObject.h"
#import "UMComFetchRequest.h"
#import "UMComPullRequest.h"
#import "UMComPushRequest.h"
#import "UMComFetchedResultsController+UMCom.h"
#import "UMUtils.h"

#define kFetchLimit 20


@interface UMComUserCenterViewModel()

@property (nonatomic) UMComUserCenterDataType curDataType;

@property (nonatomic, strong) UMComUser *user;
@property (nonatomic, copy) NSString *uid;

@property (nonatomic, strong) UMComUserProfile *userProfile;

@property (nonatomic, strong) UMComPullRequest * fetchedUserProfileController;

@property (nonatomic, strong) UMComPullRequest * fetchedTopicController;

@property (nonatomic, strong) UMComPullRequest * fetchedFollowersController;

@property (nonatomic, strong) UMComPullRequest * fetchedFansController;

@property (nonatomic, strong) UMComPullRequest *fetchedProfileController;

@property (nonatomic, strong) UMComPullRequest *fetchedFeedsController;

@end

@implementation UMComUserCenterViewModel

- (id)initWithUser:(UMComUser *)user
{
    self = [super init];
    if (self) {
        self.uid = user.uid;
        self.user = user;
        UMComUserFeedsRequest *userFeedsController = [[UMComUserFeedsRequest alloc] initWithUid:user.uid count:BatchSize];
        self.fetchedFeedsController = userFeedsController;
        
        UMComUserTopicsRequest *userTopicsController = [[UMComUserTopicsRequest alloc] initWithUid:user.uid count:FocusTopicNum];
        if ([user.uid isEqualToString:[UMComSession sharedInstance].uid]) {
            [UMComSession sharedInstance].isFocus = YES;
        }else{
            [UMComSession sharedInstance].isFocus = NO;
        }
        self.fetchedTopicController = userTopicsController;
        
        UMComUserResultController *userResultController = [[UMComUserResultController alloc] initWithUid:user.uid];
        [userResultController fetchRequestFromCoreData:^(NSArray *data, NSError *error) {
            self.user = data.firstObject;
        }];
        
        UMComFollowersRequest *followersController = [[UMComFollowersRequest alloc] initWithUid:user.uid count:BatchSize * 2];
        self.fetchedFollowersController = followersController;
        
        UMComFansRequest *fansController = [[UMComFansRequest alloc] initWithUid:user.uid count:BatchSize*2];
        self.fetchedFansController = fansController;
        
        UMComUserProfileRequest *profileController = [[UMComUserProfileRequest alloc] initWithUid:user.uid sourceUid:nil];
        self.fetchedProfileController = profileController;
    }
    return self;
}

-(id)initWithUid:(NSString *)uid{
    self = [super init];
    if (self) {
        self.uid = uid;
        UMComUserFeedsRequest *userFeedsController = [[UMComUserFeedsRequest alloc] initWithUid:uid count:BatchSize];
        self.fetchedFeedsController = userFeedsController;
        
        UMComUserTopicsRequest *userTopicsController = [[UMComUserTopicsRequest alloc] initWithUid:uid count:FocusTopicNum];
        if ([uid isEqualToString:[UMComSession sharedInstance].uid]) {
            [UMComSession sharedInstance].isFocus = YES;
        }else{
            [UMComSession sharedInstance].isFocus = NO;
        }
        self.fetchedTopicController = userTopicsController;

        UMComUserResultController *userResultController = [[UMComUserResultController alloc] initWithUid:uid];
        [userResultController fetchRequestFromCoreData:^(NSArray *data, NSError *error) {
            self.user = data.firstObject;
        }];
        
        UMComFollowersRequest *followersController = [[UMComFollowersRequest alloc] initWithUid:uid count:BatchSize*2];
        self.fetchedFollowersController = followersController;

        UMComFansRequest *fansController = [[UMComFansRequest alloc] initWithUid:uid count:BatchSize*2];
        self.fetchedFansController = fansController;
        
        UMComUserProfileRequest *profileController = [[UMComUserProfileRequest alloc] initWithUid:uid sourceUid:nil];
        self.fetchedProfileController = profileController;
    }
    return self;
}

- (void)fetchFollosers:(UIButton *)focusButton completion:(PostDataResponse)completion
{
    [UMComHttpManager userFollow:self.uid isDelete:self.isFocus response:^(id responseObject, NSError *error) {
        if (!error && ![responseObject valueForKey:@"err_code"]) {
            
            self.isFocus = self.isFocus ? NO:YES;
            [self setFocusButton:focusButton];
            SafeCompletionAndError(completion,nil);

        } else if([[responseObject valueForKey:@"err_code"] intValue] == 10007){
            self.isFocus = YES;
        } else {
            SafeCompletionAndError(completion, error);
        }
    }];
}

- (void)requestFollowUser:(UIButton *)focusButton completion:(PostDataResponse)completion
{
    if(self.uid){
        [self fetchFollosers:focusButton completion:completion];
    }
}

- (void)setFocusButtonFromFollowers:(UIButton *)button
{
    self.isFocus = [self.user.has_followed boolValue];//[self.user isMyFollower];
    [self setFocusButton:button];
}

- (void)setFocusButton:(UIButton *)button
{
    if (self.isFocus == YES) {
        [button setTitle:@"取消关注" forState:UIControlStateNormal];
//        [button.titleLabel setText:@"取消关注"];
        
    } else {
        [button.titleLabel setText:@"关注"];
//        [button setTitle:@"关注" forState:UIControlStateNormal];
    }
}



- (void)loadDataWithType:(UMComUserCenterDataType)dataType completion:(LoadServerDataCompletion)completion
{
    self.curDataType = dataType;
    __weak typeof(self) weakSelf = self;
    if(dataType==UMComUserCenterDataTopics)
    {
        UMComUserTopicsRequest *userTopicsRequest = [[UMComUserTopicsRequest alloc] initWithUid:self.uid count:BatchSize];
        [userTopicsRequest fetchRequestFromCoreData:^(NSArray *data, NSError *error) {
            completion(data,NO,nil);
        }];
        [self.fetchedTopicController fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            completion(data, haveNextPage, error);
        }];

    }
    else if(dataType==UMComUserCenterDataFollow)
    {
        [self.fetchedFollowersController fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            if (error) {
                completion(weakSelf.user.followers.array ,NO ,nil);
            } else {
                completion(data, haveNextPage, error);
            }
        }];
    }
    else if(dataType==UMComUserCenterDataFans)
    {
        [self.fetchedFansController fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            if (error) {
                completion(weakSelf.user.fans.array, NO, nil);
            } else {
                completion( data, haveNextPage, error);
            }
        }];
    }
    else
    {
        UMLog(@"error,dataType[%d]",dataType);
    }
}


//上啦加载更多
- (void)loadMoreDataWithType:(UMComUserCenterDataType)dataType completion:(LoadServerDataCompletion)completion
{
    self.curDataType = dataType;
     if(dataType==UMComUserCenterDataFollow)
    {
        [self.fetchedFollowersController fetchNextPageFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            if (completion) {
                completion(data, haveNextPage, error);
            }
        }];
    }
    else if(dataType==UMComUserCenterDataFans)
    {
        [self.fetchedFansController fetchNextPageFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            if (completion) {
                completion(data, haveNextPage, error);
            }
        }];
    }
    else
    {
        UMLog(@"error,dataType[%d]",dataType);
    }
}

- (void)loadProfile:(LoadDataCompletion)completion
{
    if (self.user) {
        SafeCompletionDataAndError(completion, @[self.user], nil);
    }
    
    [self.fetchedProfileController fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        SafeCompletionDataAndError(completion, data, error);
    }];
}

@end
