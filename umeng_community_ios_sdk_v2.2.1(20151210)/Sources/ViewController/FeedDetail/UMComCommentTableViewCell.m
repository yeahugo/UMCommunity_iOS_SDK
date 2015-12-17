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
#import "UMComUser+UMComManagedObject.h"

@interface UMComCommentTableViewCell ()

@property (nonatomic, strong) UMComComment *comment;

@end

@implementation UMComCommentTableViewCell

- (void)awakeFromNib
{
    self.portrait = [[[UMComImageView imageViewClassName] alloc]initWithFrame:CGRectMake(15, 11, 35, 35)];
    self.portrait.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapPortrait = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnUser:)];
    [self.portrait addGestureRecognizer:tapPortrait];
    [self.contentView addSubview:self.portrait];
    UITapGestureRecognizer *tapCommentContent = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnCommentContent)];
    [self.contentView addGestureRecognizer:tapCommentContent];
    [self.timeLabel setTextColor:[UMComTools colorWithHexString:FontColorGray]];
    self.commentTextView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor whiteColor];
}


- (void)reloadWithComment:(UMComComment *)comment commentStyleView:(UMComMutiStyleTextView *)styleView
{
    self.comment = comment;
    NSString *iconString = [comment.creator iconUrlStrWithType:UMComIconSmallType];
    self.portrait.layer.cornerRadius = self.portrait.frame.size.width/2;
    self.portrait.layer.masksToBounds = YES;
    UIImage *placeHolderImage = [UMComImageView placeHolderImageGender:[comment.creator.gender integerValue]];
    [self.portrait setImageURL:iconString placeHolderImage:placeHolderImage];
    
    if (comment.creator.name) {
        self.nameLabel.text = comment.creator.name;
    }

    self.timeLabel.text = createTimeString(comment.create_time);
//    CGSize textSize = [self.timeLabel.text sizeWithFont:self.timeLabel.font constrainedToSize:CGSizeMake(self.timeLabel.frame.size.width, self.timeLabel.frame.size.height) lineBreakMode:NSLineBreakByCharWrapping];
    if ([comment.liked boolValue]) {
        [self.likeButton setImage:UMComImageWithImageName(@"um_like+") forState:UIControlStateNormal];
    }else{
        [self.likeButton setImage:UMComImageWithImageName(@"um_like") forState:UIControlStateNormal];
    }
    self.nameLabel.frame = CGRectMake(self.nameLabel.frame.origin.x, self.nameLabel.frame.origin.y, self.contentView.frame.size.width-57-75, self.nameLabel.frame.size.height);
    self.timeLabel.frame = CGRectMake(self.nameLabel.frame.origin.x, self.timeLabel.frame.origin.y, self.contentView.frame.size.width-57-75, self.timeLabel.frame.size.height);
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.backgroundColor = [UIColor clearColor];
    
    self.likeCountLabel.text = [NSString stringWithFormat:@"%d",[comment.likes_count intValue]];
    if (comment.content) {
        [self.commentTextView setMutiStyleTextViewProperty:styleView];
        self.commentTextView.runType = UMComMutiTextRunCommentType;
        self.commentTextView.frame = CGRectMake(self.commentTextView.frame.origin.x,self.timeLabel.frame.origin.y+self.timeLabel.frame.size.height+5, self.commentTextView.frame.size.width, styleView.totalHeight-self.commentTextView.frame.origin.y/2);
        __weak UMComCommentTableViewCell *weakSelf = self;
        self.commentTextView.clickOnlinkText = ^(UMComMutiStyleTextView *styleView, UMComMutiTextRun *run){
            if ([run isKindOfClass:[UMComMutiTextRunClickUser class]]) {
                [weakSelf tapOnUser:comment.reply_user];
            }else if ([run isKindOfClass:[UMComMutiTextRunURL class]]){
                [self tapOnUrlString:run.text];
            }else{
                [weakSelf tapOnCommentContent];
            }
        };
    }
    [self setNeedsDisplay];
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

- (void)tapOnUrlString:(NSString *)urlString
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnURL:)]) {
        [self.delegate customObj:self clickOnURL:urlString];
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

- (IBAction)onClickLikeButton:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnLikeComment:)]) {
        [self.delegate customObj:self clickOnLikeComment:self.comment];
    }
}

@end