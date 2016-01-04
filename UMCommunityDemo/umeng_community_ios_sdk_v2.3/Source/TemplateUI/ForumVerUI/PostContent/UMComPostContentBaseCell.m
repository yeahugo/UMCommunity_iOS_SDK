//
//  UMComPostContentBaseCell.m
//  UMCommunity
//
//  Created by umeng on 12/8/15.
//  Copyright © 2015 Umeng. All rights reserved.
//

#import "UMComPostContentBaseCell.h"

#import "UMComUser.h"
#import "UMComFeed.h"
#import "UMComComment.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComImageView.h"
#import "UMComMutiStyleTextView.h"
#import "UMComTools.h"
#import "UMComMedal+CoreDataProperties.h"

#define UMComPostBodyTextFontSize 30


@interface UMComPostContentBaseCell()


@property (nonatomic, strong) UMComImageView *avatar;
@property (nonatomic, strong) UILabel *nickLabel;
@property (nonatomic, strong) UILabel *creatorLabel;
@property (nonatomic, strong) UILabel *floorLabel;

@property (nonatomic, strong) UMComMutiStyleTextView *bodyTextView;

/* Cache */
@property (nonatomic, strong) NSMutableArray *medalViews;

@end

@implementation UMComPostContentBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // TODO:
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
        
        self.backgroundColor = [UIColor clearColor];
        
        _cellHeight = UMComPostOriginY;
        
        [self createBaseViews];
    }
    return self;
}

- (void)registerCellActionBlock:(UMComPostContentActionBlock)block;
{
    self.actionBlock = block;
}

- (void)registerImageActionBlock:(UMComPostContentImageTouchBlock)block
{
    self.imageBlock = block;
}

- (void)createBaseViews
{
    // Alloc object
    self.avatar = [[UMComImageView alloc] initWithFrame:CGRectMake(0, 0, UMComPostContentAvatarSize, UMComPostContentAvatarSize)];
    [self.contentView addSubview:_avatar];
    
    self.nickLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_nickLabel];
    
    self.creatorLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_creatorLabel];
    
    self.floorLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_floorLabel];
    
    self.bodyTextView = [[UMComMutiStyleTextView alloc] init];
    _bodyTextView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_bodyTextView];
    
    self.medalViews = [NSMutableArray array];
    
    // Config basic attribute
    _avatar.layer.cornerRadius = _avatar.frame.size.width / 2;
    _avatar.layer.masksToBounds = YES;
    _avatar.userInteractionEnabled = YES;
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionToUser)];
    [_avatar addGestureRecognizer:avatarTap];
    
    _nickLabel.font = UMComFontNotoSansLightWithSafeSize(UMComPostFontPoster);
    _nickLabel.textColor = UMComColorWithColorValueString(UMComPostColorLightGray);
    _nickLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    _creatorLabel.text = @"楼主";
    _creatorLabel.textColor = UMComColorWithColorValueString(UMComPostColorBlue);
    _creatorLabel.font = UMComFontNotoSansLightWithSafeSize(UMComPostFontCommon);
    _creatorLabel.hidden = YES;
    CGSize size = [_creatorLabel.text sizeWithFont:_creatorLabel.font];
    _creatorLabel.frame = CGRectMake(0, 0, size.width, size.height);
    
    _floorLabel.textColor = UMComColorWithColorValueString(UMComPostColorLightL1Gray);
    _floorLabel.font = UMComFontNotoSansLightWithSafeSize(UMComPostFontCommon);
    
    __weak typeof(self) ws = self;
    _bodyTextView.clickOnlinkText = ^(UMComMutiStyleTextView *mutiStyleTextView,UMComMutiTextRun *run) {
        __strong typeof(self) ss = ws;
        if ([run isKindOfClass:[UMComMutiTextRunClickUser class]]) {
//            [weakSelf tapOnUser:comment.reply_user];
        }else if ([run isKindOfClass:[UMComMutiTextRunURL class]]){
            if (ws.urlBlock) {
                ws.urlBlock(run.text);
            }
        }else{
            if (ws.actionBlock) {
                ws.actionBlock(ss, UMComPostContentActionMenu);
            }
        }
    };
}


- (void)refreshUserInfoBar
{
    CGRect frame = _avatar.frame;
    frame.origin = CGPointMake(_drawOriginX, _cellHeight);
    
    // Avatar
    _avatar.frame = frame;
    frame.origin.x += _avatar.frame.size.width + UMComPostPad;
    
    [_avatar setImageURL:[_user iconUrlStrWithType:UMComIconSmallType] placeHolderImage:UMComImageWithImageName(@"um_forum_user_smile_gray")];
    
    // For difference between Comment & Body layout
    if (_isComment) {
        _drawOriginX = frame.origin.x;
    } else {
        frame.origin.y += UMComPostPad;
    }
    
    // Nick label
    CGSize nickSize = [_user.name sizeWithFont:_nickLabel.font];
    if (nickSize.width > self.frame.size.width / 2) {
        nickSize.width = self.frame.size.width / 2;
    }
    frame.size = nickSize;
    _nickLabel.frame = frame;
    frame.origin.x += _nickLabel.frame.size.width + UMComPostPad;
    
    _nickLabel.text = _user.name;
    
    frame.size = CGSizeMake(UMComPostIconWidth, UMComPostIconWidth);
    // User marker icon
    if (self.user.medal_list.array.count > 0) {
        // fill array
        NSInteger allocCount = self.user.medal_list.array.count - _medalViews.count;
        for (int i = 0; i < allocCount; ++i) {
            UMComImageView *v = [[UMComImageView alloc] init];
            [_medalViews addObject:v];
            [self.contentView addSubview:v];
        }
        
        for (UIView *v in _medalViews) {
            v.hidden = YES;
        }
        
        // set image
        for (int i = 0; i < self.user.medal_list.array.count; ++i) {
            UMComMedal *medal = self.user.medal_list.array[i];
            UMComImageView *imageView = _medalViews[i];
            [imageView setImageURL:medal.icon_url placeHolderImage:nil];
            
            imageView.hidden = NO;
            imageView.frame = frame;
            frame.origin.x += imageView.frame.size.width + UMComPostPad / 2.f;
        }
        
    } else {
        for (UIView *v in _medalViews) {
            v.hidden = YES;
        }
    }
    
    // Floor
    _floorLabel.text = [NSString stringWithFormat:@"%ld楼", _isComment ? [_comment.floor integerValue] : 1];
    frame.size = [_floorLabel.text sizeWithFont:_floorLabel.font];
    frame.origin.x = self.frame.size.width - frame.size.width - UMComPostOriginX;
    _floorLabel.frame = frame;
    
    // Creator mark
    if ([_user.uid isEqualToString:_feed.creator.uid]) {
        CGRect frameCreator = _creatorLabel.frame;
        frameCreator.origin.y = frame.origin.y;
        frameCreator.origin.x = _floorLabel.frame.origin.x - UMComPostPad - _creatorLabel.frame.size.width;
        _creatorLabel.frame = frameCreator;
        _creatorLabel.hidden = NO;
    } else {
        _creatorLabel.hidden = YES;
    }
    
    if (_isComment) {
        _cellHeight += _nickLabel.frame.size.height + UMComPostPad;
    } else {
        _cellHeight += _avatar.frame.size.height + UMComPostPad;
    }
}

- (void)refreshBodyWithMutiText:(UMComMutiText *)textObj
{
    CGRect frame = _bodyTextView.frame;
    frame.origin = CGPointMake(_drawOriginX, _cellHeight);
    frame.size = textObj.textSize;
    _bodyTextView.frame = frame;
    
    [_bodyTextView setMutiStyleTextViewWithMutiText:textObj];
    _cellHeight += _bodyTextView.frame.size.height + UMComPostPad * 1.5;
}

- (void)refreshLayoutWithCalculatedTextObj:(UMComMutiText *)textObj
{
    self.drawOriginX = UMComPostOriginX;
    _cellHeight = UMComPostOriginY;
    
    // Child implementation
    [self refreshHeaderLayout];
    
    // Common logic
    [self refreshUserInfoBar];
    [self refreshBodyWithMutiText:textObj];
    [self refreshImageLayout];
    
    // Child implementation
    [self refreshFooterLayout];
}

- (void)refreshHeaderLayout
{
    
}

- (void)refreshImageLayout
{
    
}

- (void)refreshFooterLayout
{
    
}

#pragma mark - Actions
- (void)actionToUser
{
    if (self.actionBlock) {
        self.actionBlock(self, UMComPostContentActionAvatar);
    }
}
@end
