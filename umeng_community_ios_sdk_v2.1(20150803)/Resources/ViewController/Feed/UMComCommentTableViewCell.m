//
//  UMComCommentTableViewCell.m
//  UMCommunity
//
//  Created by umeng on 15/5/22.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComCommentTableViewCell.h"
#import "UMComUser.h"
#import "UMComTools.h"
#import "UMComImageView.h"
#import "UMComComment.h"
#import "UMComMutiStyleTextView.h"
#import "UMComClickActionDelegate.h"

@interface UMComCommentTableViewCell ()

@property (nonatomic, strong) UMComComment *comment;

@end

@implementation UMComCommentTableViewCell

- (void)awakeFromNib
{
    self.portrait = [[[UMComImageView imageViewClassName] alloc]initWithFrame:CGRectMake(15, 7, 35, 35)];
    self.portrait.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapPortrait = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnUser:)];
    [self.portrait addGestureRecognizer:tapPortrait];
    [self.contentView addSubview:self.portrait];
    UITapGestureRecognizer *tapCommentContent = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnCommentContent)];
    [self.contentView addGestureRecognizer:tapCommentContent];
    [self.timeLabel setTextColor:[UMComTools colorWithHexString:FontColorGray]];
    self.commentTextView.backgroundColor = [UIColor clearColor];
}

- (void)reloadWithComment:(UMComComment *)comment commentStyleView:(UMComMutiStyleTextView *)styleView
{
    self.comment = comment;
    NSDictionary *iconUrl = [comment.creator icon_url];
    NSString *iconString = [iconUrl objectForKey:@"240"];
    self.portrait.layer.cornerRadius = self.portrait.frame.size.width/2;
    self.portrait.layer.masksToBounds = YES;
    UIImage *placeHolderImage = [UMComImageView placeHolderImageGender:[comment.creator.gender integerValue]];
    [self.portrait setImageURL:iconString placeHolderImage:placeHolderImage];
    
    if (comment.creator.name) {
        self.nameLabel.text = comment.creator.name;
    }
    if (comment.content) {
        [self.commentTextView setMutiStyleTextViewProperty:styleView];
        self.commentTextView.runType = UMComMutiTextRunCommentType;
        self.commentTextView.frame = CGRectMake(self.commentTextView.frame.origin.x,self.commentTextView.frame.origin.y, self.commentTextView.frame.size.width, styleView.totalHeight-self.commentTextView.frame.origin.y/2);
     
        __weak UMComCommentTableViewCell *weakSelf = self;
        self.commentTextView.clickOnlinkText = ^(UMComMutiStyleTextView *styleView, UMComMutiTextRun *run){
            if ([run isKindOfClass:[UMComMutiTextRunClickUser class]]) {
                [weakSelf tapOnUser:comment.reply_user];
            }else{
                [weakSelf tapOnCommentContent];
            }
        };
    }
    if (comment.create_time) {
        self.timeLabel.text = createTimeString(comment.create_time);
    }
}

- (void)tapOnUser:(id)sender
{
    UMComUser *user = nil;
    if ([sender isKindOfClass:[UMComUser class]]) {
        user = sender;
    }else{
        user = self.comment.creator;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnUser:)]) {
        [self.delegate customObj:self clickOnUser:user];
    }
    if (self.clickOnUserportrait) {
        self.clickOnUserportrait(self.comment);
    }
}
- (void)tapOnCommentContent
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnComment:feed:)]) {
        [self.delegate customObj:self clickOnComment:self.comment feed:nil];
    }
    if (self.clickOnCommentContent) {
        self.clickOnCommentContent(self.comment);
    }
}

@end