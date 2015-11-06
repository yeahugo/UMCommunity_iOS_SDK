//
//  UMComWebViewController.h
//  UMCommunity
//
//  Created by Gavin Ye on 8/19/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UMComWebViewController : UIViewController<UIWebViewDelegate,
NSURLConnectionDelegate,NSURLConnectionDataDelegate>

- (instancetype)initWithUrl:(NSString *)url;

@end
