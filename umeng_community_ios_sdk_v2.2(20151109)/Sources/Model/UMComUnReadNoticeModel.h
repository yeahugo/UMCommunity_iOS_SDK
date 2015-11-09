//
//  UMComMessageModel.h
//  UMCommunity
//
//  Created by umeng on 15/9/26.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UMComUnReadNoticeModel : NSObject

@property (nonatomic, copy) NSString *user_id;

@property (nonatomic, assign) NSInteger totalNotiCount;

@property (nonatomic, assign) NSInteger notiByAdministratorCount;

@property (nonatomic, assign) NSInteger notiByCommentCount;

@property (nonatomic, assign) NSInteger notiByAtCount;

@property (nonatomic, assign) NSInteger notiByLikeCount;

+(UMComUnReadNoticeModel *)unReadNoticeModelNoticeDict:(NSDictionary *)noticeDict;

@end
