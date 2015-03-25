//
//  UMComFilterTopicsViewController.h
//  UMCommunity
//
//  Created by Gavin Ye on 9/2/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComTableViewController.h"

#import "UMComFilterTopicsViewModel.h"

@interface UMComFilterTopicsViewController : UMComTableViewController <UISearchBarDelegate>

@property (nonatomic,strong) UMComFilterTopicsViewModel *filterTopicsViewModel;

@end
