//
//  LoginViewController.h
//  UMCommunity_0318
//
//  Created by lixinsheng on 15-4-14.
//  Copyright (c) 2015年 lixinsheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMCommunity.h"

@interface LoginViewController : UIViewController<UMComLoginDelegate>

-(IBAction)didLoginBtn:(id)sender;
@end
