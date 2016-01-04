//
//  UMComPostContentBodyCell.m
//  UMCommunity
//
//  Created by umeng on 12/8/15.
//  Copyright © 2015 Umeng. All rights reserved.
//

#import "UMComPostContentBodyCell.h"
#import "UMComFeed.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComTools.h"
#import "UMComConfigFile.h"
#import "UMImageView.h"
#import "UMComImageUrl.h"
#import "UMComGridViewerController.h"

#define UMComPostContentImageBaseTag 99901

@interface UMComPostContentCell()
<UMImageViewDelegate>

//@property (nonatomic, strong) UIView *topMarker;
@property (nonatomic, strong) UIView *highlightMarker;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, strong) UIView *separateLine;

@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIButton *commentButton;

@property (nonatomic, strong) UIView *bottomLine;

@property (nonatomic, strong) NSMutableArray<UMImageView *> *imagePreviewList;

@property (nonatomic, strong) NSMutableDictionary *imageLoadedMarkDictionary;

@end


#define UMComPostButtonWidth 100
#define UMComPostButtonHeight 30
#define UMComPostBodyTitleFontSize 32

@implementation UMComPostContentCell
{
    NSUInteger _imageDrawOriginY;
    BOOL _imageLayoutInitFinish;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Alloc object
        
        /* Remove marker blow
        self.topMarker = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UMComPostIconWidth, UMComPostIconWidth)];
        [self.contentView addSubview:_topMarker];
         */
        
        self.highlightMarker = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UMComPostIconWidth, UMComPostIconWidth)];
        [self.contentView addSubview:_highlightMarker];
        
        self.titleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_titleLabel];
        
        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(UMComPostOriginX, 0, self.frame.size.width, 20)];
        [self.contentView addSubview:_dateLabel];
        
        self.separateLine = [[UIView alloc] initWithFrame:CGRectMake(UMComPostOriginX, 0, self.frame.size.width - UMComPostOriginX * 2, 1)];
        [self.contentView addSubview:_separateLine];
        
        self.likeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 85.f, 30.f)];
        [self.contentView addSubview:_likeButton];
        self.commentButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 85.f, 30.f)];
        [self.contentView addSubview:_commentButton];
        
        self.bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
        [self.contentView addSubview:_bottomLine];
        
        self.imagePreviewList = [NSMutableArray arrayWithCapacity:9];
        self.imageLoadedMarkDictionary = [NSMutableDictionary dictionary];
        
        // Config basic attribute
        UIImage *image = nil;
        /* Remove marker blow
        image = UMComImageWithImageName(@"um_top_forum");
        _topMarker.layer.contents = (id)image.CGImage;
         */
        
        image = UMComImageWithImageName(@"um_essence_forum");
        _highlightMarker.layer.contents = (id)image.CGImage;
        
//        _topMarker.hidden = YES;
        _highlightMarker.hidden = YES;
        
        _titleLabel.font = [UIFont systemFontOfSize:UMComPostFontTitle];
        _titleLabel.textColor = UMComColorWithColorValueString(UMComPostColorGray);
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.numberOfLines = 3;
        
        _dateLabel.font = UMComFontNotoSansLightWithSafeSize(UMComPostFontCommon);
        _dateLabel.textColor = UMComColorWithColorValueString(UMComPostColorLightGray);
        
        _separateLine.backgroundColor = UMComColorWithColorValueString(UMComPostColorLineGray);
        
        _likeButton.titleLabel.font = UMComFontNotoSansLightWithSafeSize(UMComPostFontCommon);
        _commentButton.titleLabel.font = UMComFontNotoSansLightWithSafeSize(UMComPostFontCommon);
        [_likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, _likeButton.frame.size.width / 4, 0, UMComPostPad)];
        [_likeButton setImageEdgeInsets:UIEdgeInsetsMake(_likeButton.frame.size.height / 4, _likeButton.frame.size.width / 4, _likeButton.frame.size.height / 4, _likeButton.frame.size.width / 2)];
        [_commentButton setTitleEdgeInsets:UIEdgeInsetsMake(0, _commentButton.frame.size.width / 4, 0, UMComPostPad)];
        [_commentButton setImageEdgeInsets:UIEdgeInsetsMake(_commentButton.frame.size.height / 4, _likeButton.frame.size.width / 4, _commentButton.frame.size.height / 4, _commentButton.frame.size.width / 2)];
        
        
        [_likeButton setTitleColor:UMComColorWithColorValueString(UMComPostColorLightGray) forState:UIControlStateNormal];
        [_likeButton setImage:UMComImageWithImageName(@"um_forum_post_like_nomal") forState:UIControlStateNormal];
        [_likeButton setBackgroundImage:UMComImageWithImageName(@"um_forum_focuse_nomal") forState:UIControlStateNormal];
        
        [_likeButton setTitleColor:UMComColorWithColorValueString(UMComPostColorOrange) forState:UIControlStateSelected];
        [_likeButton setImage:UMComImageWithImageName(@"um_forum_post_like_highlight") forState:UIControlStateSelected];
        [_likeButton setBackgroundImage:UMComImageWithImageName(@"um_forum_focuse_highlight") forState:UIControlStateSelected];
        
        [_likeButton setTitleColor:UMComColorWithColorValueString(UMComPostColorOrange) forState:UIControlStateHighlighted];
        [_likeButton setImage:UMComImageWithImageName(@"um_forum_post_like_highlight") forState:UIControlStateHighlighted];
        [_likeButton setBackgroundImage:UMComImageWithImageName(@"um_forum_focuse_highlight") forState:UIControlStateHighlighted];
        
        [_commentButton setTitleColor:UMComColorWithColorValueString(UMComPostColorLightGray) forState:UIControlStateNormal];
        [_commentButton setImage:UMComImageWithImageName(@"um_forum_post_comment_nomal") forState:UIControlStateNormal];
        [_commentButton setBackgroundImage:UMComImageWithImageName(@"um_forum_focuse_nomal") forState:UIControlStateNormal];
        
        [_commentButton setTitleColor:UMComColorWithColorValueString(UMComPostColorOrange) forState:UIControlStateSelected];
        [_commentButton setImage:UMComImageWithImageName(@"um_forum_post_comment_highlight") forState:UIControlStateSelected];
        [_commentButton setBackgroundImage:UMComImageWithImageName(@"um_forum_focuse_highlight") forState:UIControlStateSelected];
        
        [_commentButton setTitleColor:UMComColorWithColorValueString(UMComPostColorOrange) forState:UIControlStateHighlighted];
        [_commentButton setImage:UMComImageWithImageName(@"um_forum_post_comment_highlight") forState:UIControlStateHighlighted];
        [_commentButton setBackgroundImage:UMComImageWithImageName(@"um_forum_focuse_highlight") forState:UIControlStateHighlighted];
        
        [_likeButton addTarget:self action:@selector(actionLike:) forControlEvents:UIControlEventTouchUpInside];
        [_commentButton addTarget:self action:@selector(actionComment:) forControlEvents:UIControlEventTouchUpInside];
        
        _bottomLine.backgroundColor = UMComColorWithColorValueString(UMComPostColorBottomLine);
    }
    return self;
}

- (void)refreshLayoutWithCalculatedTextObj:(UMComMutiText *)textObj
                                   andFeed:(UMComFeed *)feed
{
    self.feed = feed;
    self.user = feed.creator;
    self.imageUrls = feed.image_urls.array;
    
    [self refreshLayoutWithCalculatedTextObj:textObj];
}


- (void)refreshHeaderLayout
{
    NSUInteger originX = UMComPostOriginX;
    self.cellHeight = UMComPostOriginY * 2;
    
    NSString *feedTitle = self.feed.title;
    NSMutableString *prefixSpace = [NSMutableString stringWithString:@""];
    
    // Post marker
    NSString *spaceStr = @"     ";
    /* Remove marker blow
    if ([self.feed.is_top boolValue]) {
        CGRect frame = _topMarker.frame;
        frame.origin = CGPointMake(originX, self.cellHeight);
        _topMarker.frame = frame;
        
        _topMarker.hidden = NO;
        [prefixSpace appendString:spaceStr];
    } else {
        _topMarker.hidden = YES;
    }
     */
    
    if ([self.feed.tag boolValue]) {
        CGRect frame = _highlightMarker.frame;
//        frame.origin = CGPointMake(originX + ([self.feed.is_top boolValue] ? (_topMarker.frame.size.width + UMComPostPad / 2) : 0), self.cellHeight);
        frame.origin = CGPointMake(originX, self.cellHeight);
        _highlightMarker.frame = frame;
        
        _highlightMarker.hidden = NO;
        [prefixSpace appendString:spaceStr];
    } else {
        _highlightMarker.hidden = YES;
    }
    
    // Title
    if (prefixSpace.length > 0) {
        feedTitle = [prefixSpace stringByAppendingString:feedTitle];
    }
    CGSize titleSize = [feedTitle sizeWithFont:_titleLabel.font
                             constrainedToSize:CGSizeMake(self.frame.size.width - UMComPostOriginX * 2, INT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
    _titleLabel.frame = CGRectMake(originX, self.cellHeight, titleSize.width, titleSize.height);
    self.cellHeight += _titleLabel.frame.size.height + UMComPostPad * 1.5;
    
    _titleLabel.text = feedTitle;
    
    // Date
    CGRect frame = _dateLabel.frame;
    frame.origin.y = self.cellHeight;
    _dateLabel.frame = frame;
    self.cellHeight += _dateLabel.frame.size.height + UMComPostPad;
    
    _dateLabel.text = self.feed.create_time;
    
    // Line
    _separateLine.center = CGPointMake(self.frame.size.width / 2, self.cellHeight);
    
    self.cellHeight += UMComPostPad;
}

- (void)refreshImageLayout
{
    _imageDrawOriginY = self.cellHeight;
    
    for (UMImageView *v in _imagePreviewList) {
        [v removeFromSuperview];
    }
    [_imageLoadedMarkDictionary removeAllObjects];
    
    NSInteger diffCount = _imagePreviewList.count - self.imageUrls.count;
    if (diffCount < 0) {
        while (diffCount++ < 0) {
            UMImageView *iv = [[UMImageView alloc] initWithFrame:CGRectMake(UMComPostOriginX, 0, 165.f, 165.f)];
            [_imagePreviewList addObject:iv];
        }
    } else if (diffCount > 0) {
        [_imagePreviewList removeObjectsInRange:NSMakeRange(_imagePreviewList.count, diffCount)];
    }
    
    if (self.imageUrls.count == 0) {
        return;
    }
    
    _imageLayoutInitFinish = NO;
    for (UMImageView *iv in _imagePreviewList) {
        UMComImageUrl *imageModel = self.imageUrls[[_imagePreviewList indexOfObject:iv]];
        iv.isCacheImage = YES;
        iv.imageURL = [NSURL URLWithString:imageModel.large_url_string];
        iv.delegate = self;
        
        // Tap
        iv.tag = UMComPostContentImageBaseTag + [_imagePreviewList indexOfObject:iv];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchImage:)];
        [iv addGestureRecognizer:tap];
        iv.userInteractionEnabled = YES;
        
        [self.contentView addSubview:iv];
        
        // Rect
        CGRect frame;
        if (iv.image) {
            frame.size = [self getScaledSizeInContainer:iv.image.size];
            [_imageLoadedMarkDictionary setObject:@YES forKey:iv.imageURL];
        } else {
            frame = iv.frame;
        }
        frame.origin = CGPointMake(UMComPostOriginX, self.cellHeight);
        iv.frame = frame;
        
        self.cellHeight += iv.frame.size.height + UMComPostPad;
    }
    self.cellHeight += UMComPostPad;
    
    _imageLayoutInitFinish = YES;
    for (UMImageView *iv in _imagePreviewList) {
        iv.placeholderImage = UMComImageWithImageName(@"image-placeholder");
        [iv startImageLoad];
    }
}
- (void)imageViewLoadedImage:(UMImageView*)imageView
{
    [self refreshLoadedImageLayout];
}

- (void)refreshLoadedImageLayout
{
    if (!_imageLayoutInitFinish) {
        return;
    }

    BOOL needRefresh = NO;
    self.cellHeight = _imageDrawOriginY;
    for (UMComImageView *iv in _imagePreviewList) {
        CGRect frame = iv.frame;
        if (![_imageLoadedMarkDictionary objectForKey:iv.imageURL] && iv.status == UMImageView_Success) {
            needRefresh = YES;
            
            frame.size = [self getScaledSizeInContainer:iv.image.size];
            
            [_imageLoadedMarkDictionary setObject:@YES forKey:iv.imageURL];
        }
        frame.origin = CGPointMake(UMComPostOriginX, self.cellHeight);
        iv.frame = frame;
        
        self.cellHeight += iv.frame.size.height + UMComPostPad;
    }
    
    if (needRefresh) {
        self.cellHeight += UMComPostPad;
        [self refreshFooterLayout];
        
        if (_refreshBlock) {
            _refreshBlock(self.cellHeight);
        }
        
        CGRect frame = self.frame;
        frame.size.height = self.cellHeight;
        self.frame = frame;
    }
}

- (void)refreshFooterLayout
{
    CGRect frame = _likeButton.frame;
    frame.origin.x = self.frame.size.width / 2 - frame.size.width - UMComPostPad;
    frame.origin.y = self.cellHeight;
    _likeButton.frame = frame;
    
    frame = _commentButton.frame;
    frame.origin.x = self.frame.size.width / 2 + UMComPostPad;
    frame.origin.y = self.cellHeight;
    _commentButton.frame = frame;
    
    [self updateActionButtonStatus];
    
    self.cellHeight += _likeButton.frame.size.height + UMComPostPad * 2;
    
    _bottomLine.center = CGPointMake(self.frame.size.width / 2, self.cellHeight);
    
    self.cellHeight += _bottomLine.frame.size.height + UMComPostPad;
}

- (void)updateActionButtonStatus
{
    [_likeButton setTitle:[NSString stringWithFormat:@"%@", self.feed.likes_count] forState:UIControlStateNormal];
    [_commentButton setTitle:[NSString stringWithFormat:@"%@", self.feed.comments_count] forState:UIControlStateNormal];
    _likeButton.selected = [self.feed.liked boolValue];
}

- (void)cleanImageView
{
    for (UMImageView *v in _imagePreviewList) {
        [v removeFromSuperview];
    }
    [_imageLoadedMarkDictionary removeAllObjects];
    [_imagePreviewList removeAllObjects];
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

- (void)registerRefreshActionBlock:(UMComRefreshCellEventCallback)block
{
    self.refreshBlock = block;
}

#pragma mark - actions
- (void)onTouchImage:(UITapGestureRecognizer *)gesture
{
    NSUInteger tagIndex = gesture.view.tag - UMComPostContentImageBaseTag;
    
    UMComGridViewerController *viewerController = [[UMComGridViewerController alloc] initWithArray:self.imageUrls index:tagIndex];
    [viewerController setCacheSecondes:604800];
    
    viewerController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    if (self.imageBlock) {
        self.imageBlock(viewerController, (UIImageView *)gesture.view);
    }
}

#pragma mark - utils
- (CGSize)getScaledSizeInContainer:(CGSize)size
{
    NSUInteger maxHeightMutipleTimeToWidth = 3;
    NSUInteger containerWidth = self.frame.size.width - UMComPostOriginX * 2;
    CGSize containerSize =CGSizeMake(containerWidth, containerWidth * maxHeightMutipleTimeToWidth);
    CGSize newSize;
    if (size.width <= containerSize.width) {
        newSize = size;
    } else {
        newSize.width = containerSize.width;
        newSize.height = size.height / (size.width / containerSize.width);
    }
    if (newSize.height > newSize.width * maxHeightMutipleTimeToWidth) {
        newSize.height = newSize.width * maxHeightMutipleTimeToWidth;
    }
    return newSize;
}



@end