//
//  UMComCommentEditView.m
//  UMCommunity
//
//  Created by umeng on 15/7/22.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComCommentEditView.h"
#import "UMComEmojiKeyBoardView.h"
#import "UMComTools.h"
#import "UMComComment.h"
#import "UMComUser.h"
#import "UMComFeedDetailViewController.h"
#import "UMComShowToast.h"

const NSInteger kCommentLenght = 140;


@interface UMComCommentEditView ()<UITextFieldDelegate,UMComEmojiKeyboardViewDelegate>

@property (nonatomic, strong) UIView *commentInputView;

@property (nonatomic, strong) UIButton *emojiButton;

@property (nonatomic, strong) UIButton *sendButton;

@property (nonatomic, strong) UMComEmojiKeyboardView *emojiKeyboardView;

@property (nonatomic, strong) UILabel *noticeLabel;

@property (nonatomic, strong) NSString *lastText;


@end


@implementation UMComCommentEditView

- (instancetype)initWithSuperView:(UIView *)view
{
    self = [super init];
    if (self) {
        self.view = view;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissAllEditView)];
        [self.view addGestureRecognizer:tap];
        [self creatCommentTextField];
    }
    return self;
}

- (void)creatCommentTextField
{
    NSArray *commentInputNibs = [[NSBundle mainBundle]loadNibNamed:@"UMComCommentInput" owner:self options:nil];
    //得到第一个UIView
    UIView *commentInputView = [commentInputNibs objectAtIndex:0];
    self.commentInputView = commentInputView;
    [self.commentInputView addSubview:[self creatSpaceLineWithWidth:self.view.frame.size.width]];
    self.commentTextField = [commentInputView.subviews objectAtIndex:2];
    self.emojiButton = [commentInputView.subviews objectAtIndex:0];
    self.sendButton = [commentInputView.subviews objectAtIndex:1];
    self.commentTextField.delegate = self;
    self.commentInputView.hidden = YES;
    self.commentTextField.hidden = YES;
    self.commentTextField.delegate = self;
    self.commentInputView.frame = CGRectMake(0,  self.view.frame.size.height, self.view.frame.size.width, self.commentInputView.frame.size.height);
    self.commentTextField.center = self.commentInputView.center;
    [self.view addSubview:self.commentInputView];
    [self.view addSubview:self.commentTextField];
    [self.emojiButton addTarget:self action:@selector(presentEmoji) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton addTarget:self action:@selector(sendCommend) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    UMComEmojiKeyboardView *emojiKeyboardView = [[UMComEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216) dataSource:nil];
    emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    emojiKeyboardView.delegate = self;
    self.emojiKeyboardView = emojiKeyboardView;
    
    [self.commentTextField addTarget:self action:@selector(onChangeTextField) forControlEvents:UIControlEventEditingChanged];
}

- (void)sendCommend
{
    if (self.commentTextField.text.length >= kCommentLenght) {
        [UMComShowToast commentMoreWord];
        return;
    }
    if (self.SendCommentHandler) {
        self.SendCommentHandler(self.commentTextField.text);
    }
    [self dismissAllEditView];
}

- (void)presentEmoji
{
    if (self.commentTextField.inputView == nil) {
        self.commentTextField.inputView = self.emojiKeyboardView;
        [self.commentTextField resignFirstResponder];
        [self.commentTextField becomeFirstResponder];
        [self.emojiButton setImage:[UIImage imageNamed:@"um_keyboard"] forState:UIControlStateNormal];
    } else {
        [self.emojiButton setImage:[UIImage imageNamed:@"um_emoji"] forState:UIControlStateNormal];
        self.commentTextField.inputView = nil;
        [self.commentTextField resignFirstResponder];
        [self.commentTextField becomeFirstResponder];
    }
}

- (void)emojiKeyBoardView:(UMComEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji
{
    NSString * commentString = [self.commentTextField.text stringByAppendingString:emoji];
    if (commentString.length >= kCommentLenght) {
        [UMComShowToast commentMoreWord];
        self.commentTextField.text = self.lastText;
        return;
    } else {
        self.commentTextField.text = commentString;
    }
    self.lastText = self.commentTextField.text;
}

- (void)emojiKeyBoardViewDidPressBackSpace:(UMComEmojiKeyboardView *)emojiKeyBoardView {
    [self.commentTextField deleteBackward];
}

- (UIColor *)randomColor {
    return [UIColor colorWithRed:drand48()
                           green:drand48()
                            blue:drand48()
                           alpha:drand48()];
}

- (UIImage *)randomImage {
    CGSize size = CGSizeMake(30, 10);
    UIGraphicsBeginImageContextWithOptions(size , NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *fillColor = [self randomColor];
    CGContextSetFillColorWithColor(context, [fillColor CGColor]);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextFillRect(context, rect);
    
    fillColor = [self randomColor];
    CGContextSetFillColorWithColor(context, [fillColor CGColor]);
    CGFloat xxx = 3;
    rect = CGRectMake(xxx, xxx, size.width - 2 * xxx, size.height - 2 * xxx);
    CGContextFillRect(context, rect);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)emojiKeyboardView:(UMComEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(UMComEmojiKeyboardViewCategoryImage)category {
    UIImage *img = [self randomImage];
    [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return img;
}

- (UIImage *)emojiKeyboardView:(UMComEmojiKeyboardView *)emojiKeyboardView imageForNonSelectedCategory:(UMComEmojiKeyboardViewCategoryImage)category {
    UIImage *img = [self randomImage];
    [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return img;
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(UMComEmojiKeyboardView *)emojiKeyboardView {
    //替换删除按钮
    UIImage *img = [UIImage imageNamed:@"um_emoji_delete"];
    return img;
}

- (UIView *)creatSpaceLineWithWidth:(CGFloat)width
{
    UIView *spaceLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 0.3)];
    spaceLine.backgroundColor = TableViewSeparatorRGBColor;
    spaceLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    return spaceLine;
}

-(void)presentEditView
{
    self.commentTextField.text = @"";
    [self.commentTextField becomeFirstResponder];
    NSString *chContent = [NSString stringWithFormat:@"评论内容不能超过%d个字符",140];
    NSString *key = [NSString stringWithFormat:@"Content must not exceed %d characters",140];
    self.commentTextField.placeholder = UMComLocalizedString(key,chContent);
    self.commentTextField.hidden = NO;
    self.commentInputView.hidden = NO;
}

- (void)dismissAllEditView
{
    self.commentTextField.hidden = YES;
    self.commentInputView.hidden = YES;
    if ([self.commentTextField becomeFirstResponder]) {
        [self.commentTextField resignFirstResponder];
    }
}


- (void)presentReplyView:(UMComComment *)comment;
{
    self.commentTextField.text = @"";
    self.commentTextField.placeholder = [NSString stringWithFormat:@"回复%@",[[comment creator] name]];
    self.commentTextField.hidden = NO;
    self.commentInputView.hidden = NO;
    [self.commentTextField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.commentTextField.text.length >= kCommentLenght) {
        [UMComShowToast commentMoreWord];
        return NO;
    }
    if (self.SendCommentHandler) {
        self.SendCommentHandler(textField.text);
    }
    [self dismissAllEditView];
    return YES;
}



- (void)onChangeTextField
{
    if (self.commentTextField.text.length >= kCommentLenght) {
        [UMComShowToast commentMoreWord];
        self.commentTextField.text = self.lastText;
        return;
    }
    self.lastText = self.commentTextField.text;
}


- (void)hidenNoticeLabel
{
    self.noticeLabel.hidden = YES;
    self.commentTextField.hidden = NO;
}

- (void)keyboardWillShow:(NSNotification*)notification {
    
    [self.view bringSubviewToFront:self.commentInputView];
    [self.view bringSubviewToFront:self.commentTextField];
    CGRect  keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.commentInputView.center = CGPointMake(self.view.frame.size.width/2, keyBoardFrame.origin.y - self.commentInputView.frame.size.height-41.5);
    self.commentTextField.center = self.commentInputView.center;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.commentInputView = nil;
    self.view = nil;
    self.commentTextField = nil;
    self.noticeLabel = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
