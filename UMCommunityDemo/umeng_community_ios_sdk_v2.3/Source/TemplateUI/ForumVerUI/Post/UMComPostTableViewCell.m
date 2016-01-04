//
//  UMComPostTableViewCell.m
//  UMCommunity
//
//  Created by umeng on 11/27/15.
//  Copyright © 2015 Umeng. All rights reserved.
//

#import "UMComPostTableViewCell.h"
#import "UMComTools.h"
#import "UMComConfigFile.h"
#import "UMComGridView.h"
#import "UMComLocationModel.h"
#import "UMComFeed.h"
#import "UMComUser.h"
#import "UMComFeed+UMComManagedObject.h"
#import "UMComImageUrl.h"

#define scaleX 1
#define UMComPostCellPad 5
#define UMComPostCellIconWidth 14
#define UMComPostCellOriginX (7 * scaleX)
#define UMComPostCellOriginY (10 * scaleX)

#define UMComPostCellTitleHeight 17
#define UMComPostCellNickHeight 15
#define UMComPostCellImageHeight 110
#define UMComPostCellBottomLabelHeight 12

#define UMComPostCellContentOffsetX 5.f
#define UMComPostCellContentOffsetY 3.f

@interface UMComPostTableViewCell()

@property (nonatomic, strong) UIView *contentRootView;

@property (nonatomic, strong) UIView *highlightMarkIcon;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *nickNameLabel;
@property (nonatomic, strong) UILabel *postTimeLabel;

@property (nonatomic, strong) UMComGridView *previewImageView;;

@property (nonatomic, strong) UIView *locationIcon;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UIView *likeIcon;
@property (nonatomic, strong) UILabel *likeLabel;
@property (nonatomic, strong) UIView *commentIcon;
@property (nonatomic, strong) UILabel *commentLabel;

@property (nonatomic, strong) UIView *selectedView;

@property (nonatomic, strong) CALayer *bulletinIcon;

@end

@implementation UMComPostTableViewCell

+ (NSUInteger)cellHeightForPlainStyle
{
    return UMComPostCellOriginY
    + UMComPostCellTitleHeight + UMComPostCellPad
    + UMComPostCellNickHeight + UMComPostCellPad
    + UMComPostCellBottomLabelHeight + UMComPostCellOriginY
    + UMComPostCellContentOffsetY * 2;
}

+ (NSUInteger)cellHeightForImageStyle
{
    CGSize mainSize = [UIScreen mainScreen].bounds.size;
    NSUInteger imageHeight = (mainSize.width - UMComPostCellPad * 4) / 3;
    return [UMComPostTableViewCell cellHeightForPlainStyle] + imageHeight + UMComPostCellOriginY + UMComPostCellPad;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initViews];
    }
    return self;
}


- (void)initViews {
    
    CGFloat titleFontSize = 15.f;
    CGFloat grayTextFontSize = 12.f;
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    self.contentRootView = [[UIView alloc] initWithFrame:CGRectMake(UMComPostCellContentOffsetX, UMComPostCellContentOffsetY, self.frame.size.width, 100)];
    [self.contentView addSubview:_contentRootView];
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    self.selectedBackgroundView.backgroundColor = UMComRGBColor(238, 238, 238);
    self.selectedBackgroundView.layer.cornerRadius = 5.f;
    self.selectedBackgroundView.layer.masksToBounds = YES;
    
    _contentRootView.backgroundColor = [UIColor whiteColor];
    _contentRootView.layer.cornerRadius = 5.f;
    _contentRootView.layer.masksToBounds = YES;
    _contentRootView.layer.borderWidth = .3f;
    _contentRootView.layer.borderColor = UMComRGBColor(222, 222, 222).CGColor;
    
    self.topMarkIcon = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, UMComPostCellIconWidth, UMComPostCellIconWidth)];
    self.highlightMarkIcon = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, UMComPostCellIconWidth, UMComPostCellIconWidth)];
    self.titleLabel = [[UILabel alloc] init];
    self.nickNameLabel = [[UILabel alloc] init];
    
    __weak typeof(self) ws = self;
    self.previewImageView = [[UMComGridView alloc] init];
    _previewImageView.TapInImage = ^(UMComGridViewerController *viewerController, UIImageView *imageView) {
        if (ws.touchOnImage) {
            ws.touchOnImage(viewerController, imageView);
        }
    };
    self.locationIcon = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 9.f, 12.f)];
    self.likeIcon = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 13.f, 11.f)];
    self.commentIcon = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 12.f, 12.f)];
    self.locationLabel = [[UILabel alloc] init];
    self.likeLabel = [[UILabel alloc] init];
    self.commentLabel = [[UILabel alloc] init];
    
    _titleLabel.font = UMComFontNotoSansLightWithSafeSize(titleFontSize);
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    _nickNameLabel.font = UMComFontNotoSansLightWithSafeSize(grayTextFontSize);
    _nickNameLabel.textColor = UMComColorWithColorValueString(FontColorGray);
    
    _locationLabel.font = UMComFontNotoSansLightWithSafeSize(grayTextFontSize);
    _locationLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _locationLabel.textColor = UMComColorWithColorValueString(FontColorGray);
    
    _likeLabel.font = UMComFontNotoSansLightWithSafeSize(grayTextFontSize);
    _likeLabel.textColor = UMComColorWithColorValueString(FontColorGray);
    _likeLabel.textAlignment = NSTextAlignmentLeft;
    
    _commentLabel.font = UMComFontNotoSansLightWithSafeSize(grayTextFontSize);
    _commentLabel.textColor = UMComColorWithColorValueString(FontColorGray);
    _commentLabel.textAlignment = NSTextAlignmentLeft;
    
    UIImage *image = UMComImageWithImageName(@"um_top_forum");
//    _topMarkIcon.backgroundColor = [UIColor colorWithPatternImage:image];
    _topMarkIcon.layer.contents = (id)image.CGImage;
    image = UMComImageWithImageName(@"um_essence_forum");
//    _highlightMarkIcon.backgroundColor = [UIColor colorWithPatternImage:image];
    _highlightMarkIcon.layer.contents = (id)image.CGImage;
    image = UMComImageWithImageName(@"um_forum_location");
    _locationIcon.layer.contents = (id)image.CGImage;
    image = UMComImageWithImageName(@"um_forum_post_like_nomal");
    _likeIcon.layer.contents = (id)image.CGImage;
    image = UMComImageWithImageName(@"um_forum_post_comment_nomal");
    _commentIcon.layer.contents = (id)image.CGImage;
    
    [_contentRootView addSubview:_topMarkIcon];
    [_contentRootView addSubview:_highlightMarkIcon];
    [_contentRootView addSubview:_titleLabel];
    [_contentRootView addSubview:_nickNameLabel];
    [_contentRootView addSubview:_previewImageView];
    [_contentRootView addSubview:_locationIcon];
    [_contentRootView addSubview:_locationLabel];
    [_contentRootView addSubview:_likeLabel];
    [_contentRootView addSubview:_commentLabel];
    [_contentRootView addSubview:_likeIcon];
    [_contentRootView addSubview:_commentIcon];
}

- (NSUInteger)refreshTop {
    NSUInteger originX = UMComPostCellOriginX;
    NSUInteger originY = UMComPostCellOriginY;
    
    if (_showTopMark) {
        CGRect frame = _topMarkIcon.frame;
        frame.origin = CGPointMake(originX, originY);
        _topMarkIcon.frame = frame;
        originX += _topMarkIcon.frame.size.width + UMComPostCellPad;
        _topMarkIcon.hidden = NO;
    } else {
        _topMarkIcon.hidden = YES;
    }
    
    if ([_postFeed.tag boolValue]) {
        CGRect frame = _highlightMarkIcon.frame;
        frame.origin = CGPointMake(originX, originY);
        _highlightMarkIcon.frame = frame;
        originX += _highlightMarkIcon.frame.size.width + UMComPostCellPad;
        _highlightMarkIcon.hidden = NO;
    } else {
        _highlightMarkIcon.hidden = YES;
    }
    
    _titleLabel.frame = CGRectMake(originX, originY, _contentRootView.frame.size.width - originX, UMComPostCellTitleHeight);
    
    originX = UMComPostCellOriginX;
    originY += _titleLabel.frame.size.height + UMComPostCellPad;
    _nickNameLabel.frame = CGRectMake(originX, originY, _contentRootView.frame.size.width - originX, UMComPostCellNickHeight);
    
    if (_postFeed.title.length == 0) {
        _postFeed.title = [_postFeed.text substringToIndex:_postFeed.text.length < 30 ? _postFeed.text.length : 30];
    }
    _titleLabel.text = _postFeed.title;
    _nickNameLabel.text = [NSString stringWithFormat:UMComLocalizedString(@"um_com_post_whom_at_time", @"%@ 发表于 %@"), _postFeed.creator.name, createTimeString(_postFeed.create_time)];
    originY += _nickNameLabel.frame.size.height + UMComPostCellPad;
    
    originY += UMComPostCellPad;
    return originY;
}

- (NSUInteger)refreshMiddleWithOriginY:(CGFloat)originY {
    
    NSUInteger originX = UMComPostCellOriginX;
    
    NSUInteger pad = originX;
    
    NSUInteger width = _contentRootView.frame.size.width - pad * 2;
    _previewImageView.frame = CGRectMake(pad, originY, width, (width - pad * 2) / 3);
    NSArray<UMComImageUrl *> *imageList = _postFeed.image_urls.array;
    if (imageList.count > 0) {
        NSRange imageRange = NSMakeRange(0, imageList.count > 3 ? 3 : imageList.count);
        NSArray *previewImageList = [imageList subarrayWithRange:imageRange];
        [_previewImageView setImages:previewImageList placeholder:UMComImageWithImageName(@"um_forum_post_default") cellPad:pad];
        [_previewImageView startDownload];
        
        _previewImageView.hidden = NO;
        originY += _previewImageView.frame.size.height;
    } else {
        _previewImageView.hidden = YES;
    }
    
    return originY;
}

- (NSUInteger)refreshBottomWithOriginY:(CGFloat)originY {
    NSUInteger pad = UMComPostCellPad;
    NSUInteger originX = UMComPostCellOriginX;
    
    _locationIcon.frame = CGRectMake(originX, originY, 9.f, 12.f);
    originX += _locationIcon.frame.size.width + UMComPostCellPad;

    _locationLabel.frame = CGRectMake(originX, originY, _contentRootView.frame.size.width / 2, UMComPostCellBottomLabelHeight);
    
    UMComLocationModel *location = [_postFeed locationModel];
    _locationLabel.hidden = location ? NO : YES;
    _locationIcon.hidden = location ? NO : YES;
    
    originX = _contentRootView.frame.size.width - 100;
    
    
    CGRect frame = _likeIcon.frame;
    frame.origin = CGPointMake(originX, originY);
    _likeIcon.frame = frame;
    originX+= _likeIcon.frame.size.width + pad;
    
    _likeLabel.frame = CGRectMake(originX, originY, 30, UMComPostCellBottomLabelHeight);
    originX += _likeLabel.frame.size.width + pad;
    
    frame = _commentIcon.frame;
    frame.origin = CGPointMake(originX, originY);
    _commentIcon.frame = frame;
    originX+= _commentIcon.frame.size.width + pad;
    
    _commentLabel.frame = CGRectMake(originX, originY, 50, UMComPostCellBottomLabelHeight);
    originY += _commentLabel.frame.size.height + UMComPostCellOriginY;
    
    return originY;
}

- (void)refreshLayout {
    CGRect frame = _contentRootView.frame;
    CGFloat cellHeight = 0;
    if (self.postFeed.image_urls.count > 0) {
        cellHeight = [[self class] cellHeightForImageStyle];
    }else{
        cellHeight = [[self class] cellHeightForPlainStyle];
        
    }
    frame.size.width = self.contentView.frame.size.width - frame.origin.x * 2;
    frame.size.height = cellHeight - frame.origin.y * 2;
    _contentRootView.frame = frame;
    
    NSUInteger originY = [self refreshTop];
    originY = [self refreshMiddleWithOriginY:originY];
    [self refreshBottomWithOriginY:originY];
    
    UMComLocationModel *location = [_postFeed locationModel];
    if (location) {
        _locationLabel.text = location.name;
    }
    _likeLabel.text = [NSString stringWithFormat:@"%@", _postFeed.likes_count];
    _commentLabel.text = [NSString stringWithFormat:@"%@", _postFeed.comments_count];
    
    [self updateBulletinStatus];
}

- (void)updateBulletinStatus
{
    if ([_postFeed.type integerValue] == 1) {
        if (!_bulletinIcon) {
            UIImage *icon = UMComImageWithImageName(@"um_forum_post_bulletin@2x.png");
            CGSize iconSize = CGSizeMake(29.f, 28.5f);
            CGSize rootSize = _contentRootView.frame.size;
            self.bulletinIcon = [CALayer layer];
            _bulletinIcon.frame = CGRectMake(rootSize.width - iconSize.width, 0.f, iconSize.width, iconSize.height);
            _bulletinIcon.contents = (id)icon.CGImage;
            
            [_contentRootView.layer addSublayer:_bulletinIcon];
        }
        _bulletinIcon.hidden = NO;
    } else {
        _bulletinIcon.hidden = YES;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.selectedBackgroundView.frame = _contentRootView.frame;
}
@end
