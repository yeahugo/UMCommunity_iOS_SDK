//
//  UMComEditForwardView.h
//  UMCommunity
//
//  Created by umeng on 15/11/20.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>


@class UMComImageView, UMComEditTextView;
@interface UMComEditForwardView : UIImageView

@property (nonatomic, strong) UMComEditTextView *forwardEditTextView;

@property (nonatomic, strong) UMComImageView *forwardImageView;

@property (nonatomic, strong) NSMutableArray *forwardCheckWords;

- (void)reloadViewsWithText:(NSString *)text checkWords:(NSArray *)checkWords urlString:(NSString *)urlString;
@end