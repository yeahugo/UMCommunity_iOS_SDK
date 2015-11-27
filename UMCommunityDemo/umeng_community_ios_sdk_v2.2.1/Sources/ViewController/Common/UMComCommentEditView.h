//
//  UMComCommentEditView.h
//  UMCommunity
//
//  Created by umeng on 15/7/22.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UMComComment;

@interface UMComCommentEditView : NSObject

@property (nonatomic, strong) UIView *view;

@property (nonatomic, strong) UITextField *commentTextField;

- (instancetype)initWithSuperView:(UIView *)view;

@property (nonatomic, copy) void (^SendCommentHandler)(NSString *comentContent);

- (void)presentEmoji;

-(void)presentEditView;

- (void)dismissAllEditView;

- (void)presentReplyView:(UMComComment *)comment;

@end
