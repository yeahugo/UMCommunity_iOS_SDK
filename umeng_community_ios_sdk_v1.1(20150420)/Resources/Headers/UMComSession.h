//
//  UMComSession.h
//  UMCommunity
//
//  Created by Gavin Ye on 9/11/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMComUser.h"

#define NSUserDefaultAppKey @"UMCommunityAppKey"
#define NSUserDefaultLoginKey @"UMCommunityLoginUid"
#define NSUserDefaultLoginToken @"UMCommunityLoginToken"

@class UMComUserProfile;
@class UMComUserAccount;

@interface UMComSession : NSObject

@property (nonatomic, copy) NSString *token;

@property (nonatomic, copy) NSString *uid;

@property (nonatomic, copy) NSString *open_id;

@property (nonatomic, copy) NSString *appkey;

@property (nonatomic, copy) NSString *user_profile_id;

@property (nonatomic, strong) NSDictionary *baseHeader;//含当前uid

@property (nonatomic, copy) NSString *feedID;

@property (nonatomic, strong) NSMutableArray *focus_topics;

@property (nonatomic, strong) NSArray *followers;

@property (nonatomic, strong) UMComUser *loginUser;

@property (nonatomic, assign) BOOL isFocus;

@property (nonatomic, strong) UMComFeed *commentFeed;

@property (nonatomic, assign) BOOL isNetworkAvaible;

@property (nonatomic, copy) NSString *currentUid;   //当前个人中心的用户uid

@property (nonatomic, strong) UMComUserAccount *currentUserAccount;

@property (nonatomic, strong) UIViewController *beforeLoginViewController;  //登录前的viewController

- (NSMutableDictionary *)basePathDictionary;

+ (UMComSession *)sharedInstance;

//用户注销
- (void)userLogout;

- (void)saveLoginUser:(NSDictionary *)loginUser completion:(void (^)(void))completion;

- (UMComUser *)userWithUid:(NSString *)uid;


@end
