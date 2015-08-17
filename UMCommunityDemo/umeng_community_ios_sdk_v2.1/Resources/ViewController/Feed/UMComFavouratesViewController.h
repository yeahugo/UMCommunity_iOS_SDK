//
//  UMComFavouratesViewController.h
//  UMCommunity
//
//  Created by Gavin Ye on 8/12/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import "UMComFeedTableViewController.h"
#import "UMComFavouratesTableView.h"

@interface UMComFavouratesViewController : UMComFeedTableViewController
//    UMComFavouratesTableView * favouratesTableView = [[UMComFavouratesTableView alloc] initWithFrame:self.feedsTableView.frame];
- (id)initWithFeedsTableView:(UMComFavouratesTableView *)feedsView;

@end
