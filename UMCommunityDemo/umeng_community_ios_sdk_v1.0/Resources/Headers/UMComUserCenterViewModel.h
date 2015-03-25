//
//  UMComUserCenterViewModel.h
//  UMCommunity
//
//  Created by Gavin Ye on 9/10/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMComAllFeedViewModel.h"
//#import "UMComFeedViewModel.h"

typedef enum  {
    UMComUserCenterDataFeeds,
    UMComUserCenterDataTopics,
    UMComUserCenterDataFollow,
    UMComUserCenterDataFans
} UMComUserCenterDataType;

@class UMComUserProfile;
@class UMComUser;

@interface UMComUserCenterViewModel : UMComViewModel

@property (nonatomic) BOOL isFocus;

- (id)initWithUser:(UMComUser *)user;

- (id)initWithUid:(NSString *)uid;

- (void)setFocusButton:(UIButton *)button;

- (void)setFocusButtonFromFollowers:(UIButton *)button;

- (void)requestFollowUser:(UIButton *)focusButton completion:(PostDataResponse)completion;

//- (void)loadFeedsData:(LoadDataCompletion)completion;

- (void)loadProfile:(LoadDataCompletion)completion;
- (void)loadDataWithType:(UMComUserCenterDataType)dataType completion:(LoadServerDataCompletion)completion;

//上啦加载更多
- (void)loadMoreDataWithType:(UMComUserCenterDataType)dataType completion:(LoadServerDataCompletion)completion;

@end
