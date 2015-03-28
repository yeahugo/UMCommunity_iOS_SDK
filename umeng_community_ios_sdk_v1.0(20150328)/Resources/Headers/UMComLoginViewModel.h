//
//  UMComLoginViewModel.h
//  UMCommunity
//
//  Created by Gavin Ye on 8/25/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMComViewModel.h"
#import "UMComLoginManager.h"

@interface UMComLoginViewModel : UMComViewModel

@property (nonatomic, weak) UIViewController *viewController;

//@property (nonatomic, copy) UMComReturnLoginAccount returnLoginAccount;

//@property (nonatomic, copy) UMComLoginCompletion loginCompletion;

-(id)initWithViewController:(UIViewController *)viewController;

-(void)onClickLogin;

-(void)onClickClose;

@end
