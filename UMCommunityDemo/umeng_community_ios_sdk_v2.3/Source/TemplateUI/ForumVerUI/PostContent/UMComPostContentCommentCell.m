//
//  UMComPostCommentCell.m
//  UMCommunity
//
//  Created by umeng on 12/3/15.
//  Copyright © 2015 Umeng. All rights reserved.
//

#import "UMComPostContentCommentCell.h"
#import "UMComComment.h"
#import "UMComFeed.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComTools.h"
#import "UMComConfigFile.h"

#import "UMComGridView.h"



@interface UMComPostContentCommentCell()

@property (nonatomic, strong) UILabel *repliedCommentHeader;
@property (nonatomic, strong) UILabel *repliedCommentSummary;

@property (nonatomic, strong) UIView *repliedCommentView;;

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UILabel *likeCountLabel;

@property (nonatomic, strong) UIView *bottomLine;

@property (nonatomic, strong) UMComGridView *imagePreviewView;

@end

@implementation UMComPostContentCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.isComment = YES;
        
        NSUInteger buttonWidth = UMComPostIconWidth * 1.5f;
        
        // Alloc object
        self.repliedCommentView = [[UIView alloc] init];
        [self.contentView addSubview:_repliedCommentView];
        _repliedCommentView.hidden = YES;
        
        self.repliedCommentHeader = [[UILabel alloc] init];
        [_repliedCommentView addSubview:_repliedCommentHeader];
        
        self.repliedCommentSummary = [[UILabel alloc] init];
        [_repliedCommentView addSubview:_repliedCommentSummary];
        
        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, 50, 20)];
        [self.contentView addSubview:_dateLabel];
        
        self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:_likeButton];
        
        self.likeCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 30.f, UMComPostIconWidth)];
        [self.contentView addSubview:_likeCountLabel];
        
        self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:_commentButton];
        
        self.bottomLine = [[UIView alloc] init];
        [self.contentView addSubview:_bottomLine];
        
        // Config basic attribute
        _repliedCommentView.backgroundColor = UMComColorWithColorValueString(UMComPostColorInnerBgColor);
        _repliedCommentView.layer.borderColor = UMComColorWithColorValueString(@"#E6E6E8").CGColor;
        _repliedCommentView.layer.borderWidth = 1.f;
        
        _repliedCommentHeader.font = UMComFontNotoSansLightWithSafeSize(UMComPostFontPoster);
        _repliedCommentHeader.textColor = UMComColorWithColorValueString(UMComPostColorInnerLightGray);
        _repliedCommentHeader.adjustsFontSizeToFitWidth = YES;
        
        _repliedCommentSummary.font = UMComFontNotoSansLightWithSafeSize(UMComPostFontInnerBody);
        _repliedCommentSummary.textColor = UMComColorWithColorValueString(UMComPostColorInnerGray);
        _repliedCommentSummary.lineBreakMode = NSLineBreakByWordWrapping;
        _repliedCommentSummary.numberOfLines = 3;
        
        _dateLabel.font = UMComFontNotoSansLightWithSafeSize(UMComPostFontCommon);
        _dateLabel.textColor = UMComColorWithColorValueString(UMComPostColorLightGray);
        
        _likeButton.titleLabel.font = UMComFontNotoSansLightWithSafeSize(UMComPostFontCommon);
        
        [_likeButton addTarget:self action:@selector(actionLike:) forControlEvents:UIControlEventTouchUpInside];
        [_commentButton addTarget:self action:@selector(actionComment:) forControlEvents:UIControlEventTouchUpInside];
        
        _likeButton.frame = CGRectMake(0.f, 0.f, buttonWidth, buttonWidth);
        
//        [_likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, UMComPostPad, 0, 0)];
//        [_likeButton setImageEdgeInsets:UIEdgeInsetsMake(0, _likeButton.frame.size.width / 4, 0, _likeButton.frame.size.width / 4 * 3 - _likeButton.frame.size.height)];
        
//        [_likeButton setTitleColor:UMComColorWithColorValueString(UMComPostColorLightGray) forState:UIControlStateNormal];
        [_likeButton setImage:UMComImageWithImageName(@"um_forum_comment_like_nomal") forState:UIControlStateNormal];
        
        //        [_likeButton setTitleColor:UMComColorWithColorValueString(UMComPostColorOrange) forState:UIControlStateSelected];
        [_likeButton setImage:UMComImageWithImageName(@"um_forum_comment_like_highlight") forState:UIControlStateSelected];
        [_likeButton setImage:UMComImageWithImageName(@"um_forum_comment_like_highlight") forState:UIControlStateHighlighted];
        
        _likeCountLabel.textAlignment = NSTextAlignmentLeft;
        _likeCountLabel.font = UMComFontNotoSansLightWithSafeSize(UMComPostFontCommon);
        
        _commentButton.frame = CGRectMake(0.f, 0.f, buttonWidth, buttonWidth);
        
        [_commentButton setImage:UMComImageWithImageName(@"um_forum_comment_nomal") forState:UIControlStateNormal];
        [_commentButton setImage:UMComImageWithImageName(@"um_forum_comment_highlight") forState:UIControlStateSelected];
        [_commentButton setImage:UMComImageWithImageName(@"um_forum_comment_highlight") forState:UIControlStateHighlighted];
        
        _bottomLine.backgroundColor = UMComColorWithColorValueString(UMComPostColorBottomLine);
        
    }
    return self;
}
- (void)refreshLayoutWithCalculatedTextObj:(UMComMutiText *)textObj
                                andComment:(UMComComment *)comment
{
    self.comment = comment;
    self.user = comment.creator;
    self.feed = comment.feed;
    self.imageUrls = comment.image_urls.array;
    
    [self refreshLayoutWithCalculatedTextObj:textObj];
}

- (void)refreshImageLayout
{
    if (self.imageUrls.count > 0) {
        if (!_imagePreviewView) {
            _imagePreviewView = [[UMComGridView alloc] init];
            [self.contentView addSubview:_imagePreviewView];
            __weak typeof(self) ws = self;
            _imagePreviewView.TapInImage = ^(UMComGridViewerController *viewerViewController,
                                             UIImageView *imageView) {
                if (ws.imageBlock) {
                    ws.imageBlock(viewerViewController, imageView);
                }
            };
        }
        NSUInteger imageFrameWidth = self.frame.size.width - self.drawOriginX - UMComPostOriginX * 2;
        _imagePreviewView.frame = CGRectMake(self.drawOriginX, self.cellHeight, imageFrameWidth, 0);
        [_imagePreviewView setImages:self.imageUrls placeholder:UMComImageWithImageName(@"um_forum_post_default") cellPad:UMComPostPad];
        
        self.cellHeight += _imagePreviewView.frame.size.height + UMComPostPad;
    } else {
        _imagePreviewView.hidden = YES;
    }
}

- (void)refreshFooterLayout
{
    if (self.comment.reply_comment.commentID) {
        UMComComment *repliedComment = self.comment.reply_comment;
        NSUInteger startPointY = UMComPostOriginY;
        NSUInteger originX = UMComPostOriginX;
        
        CGRect backgroundframe = CGRectMake(self.drawOriginX, self.cellHeight, self.frame.size.width - self.drawOriginX - UMComPostOriginX, 10);
        
        // Header bar
        NSString *repliedHeaderString = [NSString stringWithFormat:@"%@ 于 %@ 发表在 %ld楼", repliedComment.creator.name, repliedComment.create_time, [repliedComment.floor integerValue]];
        CGSize textSize = [repliedHeaderString sizeWithFont:_repliedCommentHeader.font];
        _repliedCommentHeader.frame = CGRectMake(originX, startPointY, backgroundframe.size.width - UMComPostOriginX * 2, textSize.height);
        
        startPointY += _repliedCommentHeader.frame.size.height + UMComPostPad;
        
        _repliedCommentHeader.text = repliedHeaderString;
        
        // Summary
        NSString *summaryText = nil;
        NSString *originRepliedComment = repliedComment.content;
        NSUInteger calculatedLength = [UMComTools getStringLengthWithString:originRepliedComment];
        if ([repliedComment.status integerValue] > 1) {
            // Invalid comment (deleted or reported)
            summaryText = @"[该楼内容已被删除]";
        } else if (calculatedLength > 0) {
            NSUInteger cutTextCount = 30;
            if (calculatedLength > cutTextCount) {
                if (calculatedLength != originRepliedComment.length) {
                    NSUInteger charCount = 0;
                    NSRange range;
                    for (int i = 0; i < originRepliedComment.length; i += range.length) {
                        range = [originRepliedComment rangeOfComposedCharacterSequenceAtIndex:i];
                        if (charCount >= cutTextCount) {
                            cutTextCount = i;
                            break;
                        }
                        charCount++;
                    }
                }
                summaryText = [originRepliedComment substringToIndex:cutTextCount];
            } else {
                summaryText = originRepliedComment;
            }
        } else if (repliedComment.image_urls.array.count > 0) {
            summaryText = @"[图片]";
        }else{
            NSLog(@"error replied comment: invalid comment data.");
        }
        textSize = [summaryText sizeWithFont:_repliedCommentSummary.font
                           constrainedToSize:CGSizeMake(backgroundframe.size.width - UMComPostOriginX * 2, INT_MAX)
                               lineBreakMode:_repliedCommentSummary.lineBreakMode];
        _repliedCommentSummary.frame = CGRectMake(originX, startPointY, textSize.width, textSize.height + 3);
        
        _repliedCommentSummary.text = summaryText;
        
        startPointY += _repliedCommentSummary.frame.size.height + UMComPostPad;
        
        // Background view
        backgroundframe.size.height = startPointY;
        
        _repliedCommentView.frame = backgroundframe;
        
        self.cellHeight += _repliedCommentView.frame.size.height + UMComPostPad * 1.5;
        
        _repliedCommentView.hidden = NO;
    } else {
        _repliedCommentView.hidden = YES;
    }
    
    // Date label
    _dateLabel.frame = CGRectMake(self.drawOriginX, self.cellHeight, self.frame.size.width / 2, 20);
    _dateLabel.text = self.comment.create_time;
    
    // Bottom button
    CGRect frame  = _commentButton.frame;
    frame.origin.x = self.frame.size.width - frame.size.width - UMComPostPad * 2;
    frame.origin.y = self.cellHeight;
    _commentButton.frame = frame;
    
    frame = _likeCountLabel.frame;
    frame.origin.x = _commentButton.frame.origin.x - frame.size.width - 5.f;
    frame.origin.y = self.cellHeight + 3.f;
    _likeCountLabel.frame = frame;
    
    frame  = _likeButton.frame;
    frame.origin.x = _likeCountLabel.frame.origin.x - frame.size.width - 5.f;
    frame.origin.y = self.cellHeight;
    _likeButton.frame = frame;
    [self updateActionButtonStatus];
    
    
    self.cellHeight += _commentButton.frame.size.height + UMComPostPad / 2.f;
    
    _bottomLine.frame = CGRectMake(self.drawOriginX, self.cellHeight, self.frame.size.width - self.drawOriginX, 1);
    
    self.cellHeight += UMComPostPad * 0.5;
}

- (void)updateActionButtonStatus
{
    _likeButton.selected = [self.comment.liked boolValue];
    if ([self.comment.liked boolValue]) {
        _likeCountLabel.textColor = UMComColorWithColorValueString(UMComPostColorOrange);
    } else {
        _likeCountLabel.textColor = UMComColorWithColorValueString(UMComPostColorLightGray);
    }
    _likeCountLabel.text = [NSString stringWithFormat:@"%@", self.comment.likes_count];
}

- (void)actionLike:(id)sender
{
    if (self.actionBlock) {
        self.actionBlock(self, UMComPostContentActionLike);
    }
}

- (void)actionComment:(id)sender
{
    if (self.actionBlock) {
        self.actionBlock(self, UMComPostContentActionReply);
    }
}
@end



