//
//  UMComEditTopicsViewController.h
//  UMCommunity
//
//  Created by luyiyuan on 14/9/22.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComTableViewController.h"


@class UMComEditViewModel;

@interface UMComEditTopicsViewController : UMComTableViewController

-(id)initWithEditViewModel:(UMComEditViewModel *)editViewModel;

@end
