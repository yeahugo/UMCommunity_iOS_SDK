//
//  UMComMessageSettingViewController.h
//  UMCommunity
//
//  Created by Gavin Ye on 11/19/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComViewController.h"

@interface UMComMessageSettingViewController : UMComViewController

@property (nonatomic, weak) IBOutlet UILabel *messageLabel;

@property (nonatomic, weak) IBOutlet UISwitch *messageSwitch;

@property (nonatomic, weak) IBOutlet UILabel *messageStatus;

@property (nonatomic, weak) IBOutlet UILabel *messageOpenDescription;

@property (weak, nonatomic) IBOutlet UIView *bottomLine;


@end
