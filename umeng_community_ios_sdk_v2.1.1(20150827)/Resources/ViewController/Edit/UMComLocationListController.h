//
//  UMComViewController.h
//  UMCommunity
//
//  Created by umeng on 15/8/7.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UMComTableViewController.h"

@class UMComEditViewModel;

@interface UMComLocationListController : UMComTableViewController

-(id)initWithEditViewModel:(UMComEditViewModel *)editViewModel;


@end
