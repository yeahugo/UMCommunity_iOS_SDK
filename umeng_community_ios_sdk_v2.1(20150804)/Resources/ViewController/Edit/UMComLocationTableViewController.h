//
//  UMComLocationTableViewController.h
//  UMCommunity
//
//  Created by Gavin Ye on 9/9/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "UMComTableViewController.h"

@class UMComEditViewModel;
@interface UMComLocationTableViewController : UMComTableViewController<CLLocationManagerDelegate>

-(id)initWithEditViewModel:(UMComEditViewModel *)editViewModel;

@end
