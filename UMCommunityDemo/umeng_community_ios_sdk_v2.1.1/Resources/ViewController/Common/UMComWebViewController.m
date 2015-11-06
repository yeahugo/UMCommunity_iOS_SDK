//
//  UMComWebViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 8/19/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import "UMComWebViewController.h"
#import "UIViewController+UMComAddition.h"

@interface UMComWebViewController ()

@end

@implementation UMComWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (instancetype)initWithUrl:(NSString *)url
{
    self = [super init];
    if (self) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
        webView.delegate = self;
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [webView loadRequest:request];
        [self.view addSubview:webView];
        
        [self setBackButtonWithImage];
    }
    return self;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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
