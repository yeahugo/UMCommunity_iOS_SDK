//
//  UMComFriendsTableViewController.h
//  UMCommunity
//
//  Created by Gavin Ye on 9/9/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComTableViewController.h"

@class UMComEditViewModel;
@interface UMComFriendTableViewController : UMComTableViewController

-(id)initWithEditViewModel:(UMComEditViewModel *)editViewModel;

@property (nonatomic, assign) BOOL isShowFromAtButton;

@end
