//
//  UMComLocationTableViewController.h
//  UMCommunity
//
//  Created by Gavin Ye on 9/9/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "UMComEditViewModel.h"
#import "UMComTableViewController.h"


@interface UMComLocationTableViewController : UMComTableViewController<CLLocationManagerDelegate>

-(id)initWithEditViewModel:(UMComEditViewModel *)editViewModel;

@end
