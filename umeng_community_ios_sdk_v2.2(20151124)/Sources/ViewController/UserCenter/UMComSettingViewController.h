//
//  UMComSettingViewController.h
//  UMCommunity
//
//  Created by Gavin Ye on 11/19/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComViewController.h"

@interface UMComSettingViewController : UMComViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *settingTableView;

@property (nonatomic, weak) IBOutlet UIButton *logoutButton;

- (IBAction)userLogoutAction:(id)sender;


@end
