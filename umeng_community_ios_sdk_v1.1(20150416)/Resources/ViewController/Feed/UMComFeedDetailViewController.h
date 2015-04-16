//
//  UMComFeedDetailViewController.h
//  UMCommunity
//
//  Created by Gavin Ye on 11/13/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComFeedTableViewController.h"
#import "UMComAllFeedViewController.h"
//#import "UMComFeed.h"

@interface UMComFeedDetailViewController : UMComFeedTableViewController

- (id)initWithFeedId:(NSString *)feedId;

- (id)initWithFeedId:(NSString *)feedId commentId:(NSString *)commentId;

@end
