//
//  UMComForumTopicFocusedTableViewController.m
//  UMCommunity
//
//  Created by umeng on 15/12/21.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumTopicFocusedTableViewController.h"
#import "UMComAction.h"
#import "UMComSession.h"
#import "UMComTools.h"
#import "UMComPullRequest.h"

#define UMCom_Forum_FocuseTopic_LoginTextFont 18
#define UMCom_Forum_FocuseTopic_LoginTextColor @"#FFFFFF"
#define UMCom_Forum_FocuseTopic_LoginBgColor @"#008BEA"
#define UMCom_Forum_FocuseTopic_NoticeTextColor @"#A5A5A5"
#define UMCom_Forum_FocuseTopic_NoticeTextFont 15


@interface UMComForumTopicFocusedTableViewController ()

@property (nonatomic, strong) UIView *loginView;

@end

@implementation UMComForumTopicFocusedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.noDataTipLabel.text = @"您还没有关注任何话题哦~";
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self resetSubViews];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)resetSubViews
{
    if (![UMComSession sharedInstance].isLogin) {
        if (!self.loginView) {
            self.loginView = [self createNoLoginView];
        }else{
            if (self.loginView.superview != self.view) {
                [self.view addSubview:self.loginView];
            }
        }
        [self.view bringSubviewToFront:_loginView];
    }else{
        [self.loginView removeFromSuperview];
    }
}


- (UIView *)createNoLoginView
{
    UIView *nologinView = [[UIView alloc]initWithFrame:self.view.bounds];
    nologinView.backgroundColor = [UIColor whiteColor];
    
    UILabel *noticellabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, nologinView.frame.size.width, 40)];
    noticellabel.text = @"您登陆后，服务器君才知道您关注的话题哦~";
    noticellabel.center = CGPointMake(nologinView.frame.size.width/2, nologinView.frame.size.height/2 - 45);
    noticellabel.textAlignment = NSTextAlignmentCenter;
    noticellabel.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_FocuseTopic_NoticeTextFont);
    noticellabel.textColor = UMComColorWithColorValueString(UMCom_Forum_FocuseTopic_NoticeTextColor);
    [nologinView addSubview:noticellabel];
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(0, 0, 150, 45);
    loginButton.layer.cornerRadius = 5;
    loginButton.clipsToBounds = YES;
    loginButton.center = CGPointMake(nologinView.frame.size.width/2, nologinView.frame.size.height/2);
    [loginButton setTitle:@"立即登录" forState:UIControlStateNormal];
    [loginButton setTitleColor:UMComColorWithColorValueString(UMCom_Forum_FocuseTopic_LoginTextColor) forState:UIControlStateNormal];
    [loginButton setBackgroundColor:UMComColorWithColorValueString(UMCom_Forum_FocuseTopic_LoginBgColor)];
    loginButton.titleLabel.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_FocuseTopic_LoginTextFont);
    [loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [nologinView addSubview:loginButton];
    return nologinView;
}

- (void)login:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            [weakSelf.loginView removeFromSuperview];
        }
    }];
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
