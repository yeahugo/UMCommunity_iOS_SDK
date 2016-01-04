//
//  UMComPostViewController.h
//  UMCommunity
//
//  Created by umeng on 15/11/17.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComRequestTableViewController.h"

static NSString * UMComPostTableViewCellIdentifier = @"UMComPostTableViewCellIdentifier";

@class UMComFeed;
@interface UMComPostTableViewController : UMComRequestTableViewController

@property (nonatomic, assign) BOOL showTopMark;

- (void)inserNewFeedInTabelView:(UMComFeed *)feed;

- (void)deleteNewFeedInTabelView:(UMComFeed *)feed;

@end
