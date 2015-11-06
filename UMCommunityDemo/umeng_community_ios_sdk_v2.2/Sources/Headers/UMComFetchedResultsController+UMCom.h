//
//  UMComFetchedResultsController+UMCom.h
//  UMCommunity
//
//  Created by Gavin Ye on 1/14/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import "UMComPullRequest.h"

//@interface UMComPullRequest (UMCom)
//
//- (id)initWithFetchRequest:(UMComFetchRequest *)request;
//
//@end

@interface UMComLoginUserResultController : UMComPullRequest

@end

@interface UMComUserResultController : UMComPullRequest

- (id)initWithUid:(NSString *)uid;

@end
