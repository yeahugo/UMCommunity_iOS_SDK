//
//  UMComSearchPostViewController.h
//  UMCommunity
//
//  Created by umeng on 15/12/16.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComPostTableViewController.h"

@interface UMComSearchPostViewController : UMComPostTableViewController

@property (nonatomic, copy) void (^dismissBlock)();

@end
