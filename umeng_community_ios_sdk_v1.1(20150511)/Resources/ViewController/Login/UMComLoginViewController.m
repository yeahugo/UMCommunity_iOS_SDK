//
//  UMComLoginViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 8/25/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComLoginViewController.h"
#import "UMComLoginViewModel.h"
#import "UMSocial.h"
#import "UMComHttpClient.h"
#import "UMComSession.h"
#import "UMComHttpManager.h"
#import "UMComShowToast.h"
#import "UMComBarButtonItem.h"
#import "WXApi.h"

@interface UMComLoginViewController ()

@end

@implementation UMComLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loginViewModel = [[UMComLoginViewModel alloc] initWithViewController:self];
    self.sinaLoginButton.tag = UMSocialSnsTypeSina;
    self.qqLoginButton.tag = UMSocialSnsTypeMobileQQ;
    self.wechatLoginButton.tag = UMSocialSnsTypeWechatSession;
    
    if ([UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ]) {
        [self.qqLoginButton setImage:[UIImage imageNamed:@"tencentx"] forState:UIControlStateNormal];
    }
    if ([UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession]) {
        [self.wechatLoginButton setImage:[UIImage imageNamed:@"wechatx"] forState:UIControlStateNormal];
    }
    
    [self.sinaLoginButton addTarget:self action:@selector(onClickLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.qqLoginButton addTarget:self action:@selector(onClickLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.wechatLoginButton addTarget:self action:@selector(onClickLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.closeButton addTarget:self action:@selector(onClickClose) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"Backx" target:self action:@selector(onClickClose)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeFont:UMComFontNotoSansDemiWithSafeSize(18)}];
    self.title = UMComLocalizedString(@"Login_Title", @"登录");
    // Do any additional setup after loading the view from its nib.
}

- (void)onClickClose
{
//    [UIView setAnimationsEnabled:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onClickLogin:(UIButton *)button
{
    NSString *snsName = nil;
    switch (button.tag) {
        case UMSocialSnsTypeSina:
            snsName = UMShareToSina;
            break;
        case UMSocialSnsTypeMobileQQ:
            snsName = UMShareToQQ;
            break;
        case UMSocialSnsTypeWechatSession:
            snsName = UMShareToWechatSession;
            break;
        default:
            break;
    }
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:snsName];
    if (!snsPlatform) {
        [UMComShowToast notSupportPlatform];
    } else if ([snsName isEqualToString:UMShareToWechatSession] && ![WXApi isWXAppInstalled]){
        [UMComShowToast showNotInstall];
    } else {
        snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity * response){
            if (response.responseCode == UMSResponseCodeSuccess) {
                [[UMSocialDataService defaultDataService] requestSnsInformation:snsPlatform.platformName completion:^(UMSocialResponseEntity *userInfoResponse) {
                    
                    UMComUserAccount *account = [[UMComUserAccount alloc] init];
                    UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:snsPlatform.platformName];
                    account.snsPlatformName = snsPlatform.platformName;
                    account.usid = snsAccount.usid;
                    account.token = snsAccount.accessToken;
                    
                    if (response.responseCode == UMSResponseCodeSuccess) {
                        if ([userInfoResponse.data valueForKey:@"screen_name"]) {
                            account.name = [userInfoResponse.data valueForKey:@"screen_name"];
                        }
                        if ([userInfoResponse.data valueForKey:@"profile_image_url"]) {
                            account.icon_url = [userInfoResponse.data valueForKey:@"profile_image_url"];
                        }
                        if ([userInfoResponse.data valueForKey:@"gender"]) {
                            account.gender = [userInfoResponse.data valueForKey:@"gender"] ;
                        }
                    }
                    [UMComLoginManager finishLoginWithAccount:account completion:^(NSArray *data, NSError *error) {
                        [self dismissViewControllerAnimated:YES completion:^{
                            [UMComLoginManager finishDismissViewController:self data:data error:error];
                        }];
                    }];
                }];
                
            } else {
                [UMComLoginManager finishLoginWithAccount:nil completion:^(NSArray *data, NSError *error) {
                    [self dismissViewControllerAnimated:YES completion:^{
                        NSError *loginError = [NSError errorWithDomain:@"loginError" code:response.responseCode userInfo:nil];
                        [UMComLoginManager finishDismissViewController:self data:data error:loginError];
                    }];
                }];
            }
        });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
