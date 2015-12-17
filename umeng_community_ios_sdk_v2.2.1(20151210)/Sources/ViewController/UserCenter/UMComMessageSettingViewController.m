//
//  UMComMessageSettingViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 11/19/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComMessageSettingViewController.h"
#import "UMComBarButtonItem.h"
#import "UMComTools.h"
#import "UMUtils.h"
#import "UIViewController+UMComAddition.h"

@interface UMComMessageSettingViewController ()

@end

@implementation UMComMessageSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonWithImage];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self.messageLabel setText:UMComLocalizedString(@"message_switch",@"推送开关")];
    self.messageOpenDescription.text = UMComLocalizedString(@"message_open_method", @"请在iOS设备的“设置”-“通知”中进行修改");
    self.bottomLine.backgroundColor = [UMComTools colorWithHexString:TableViewSeparatorColor];
    if ([UIDevice currentDevice].systemVersion.floatValue < 7.0) {
        self.bottomLine.frame = CGRectMake(0, self.bottomLine.frame.origin.y, self.view.frame.size.width, 0.5);
    }else{
        self.bottomLine.frame = CGRectMake(0, self.bottomLine.frame.origin.y, self.view.frame.size.width, BottomLineHeight);
    }
    self.messageLabel.font = UMComFontNotoSansLightWithSafeSize(17);
     self.messageStatus.font = UMComFontNotoSansLightWithSafeSize(16);
     self.messageOpenDescription.font = UMComFontNotoSansLightWithSafeSize(13);
    [self setTitleViewWithTitle:UMComLocalizedString(@"Message Setting",@"推送设置")];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL isOpen = NO;
    if(UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
        isOpen = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
#endif
    } else {
        UIRemoteNotificationType notificationType = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (notificationType != UIRemoteNotificationTypeNone) {
            isOpen = YES;
        } else {
            isOpen = NO;
        }
    }
    
    if (isOpen) {
        self.messageStatus.text = UMComLocalizedString(@"message_status_open",@"已开启");
    } else {
        self.messageStatus.text = UMComLocalizedString(@"message_status_close",@"已关闭");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
