//
//  UMComPostContentBaseCell.h
//  UMCommunity
//
//  Created by umeng on 12/8/15.
//  Copyright © 2015 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>


#define UMComScaleX 1
#define UMComPostPad 10
#define UMComPostIconWidth 15.f
#define UMComPostOriginX (10 * UMComScaleX)
#define UMComPostOriginY (10 * UMComScaleX)

#define UMComPostGrayTextFontSize 12

#define UMComPostContentAvatarSize 40.f

#define UMComPostColorGray @"#333333"
#define UMComPostColorLightGray @"#A5A5A5"
#define UMComPostColorLightL1Gray @"#CECECE" // more light

#define UMComPostColorInnerGray @"#7D7D7D"
#define UMComPostColorInnerLightGray @"#C0C0C0"
#define UMComPostColorInnerBgColor @"#F5F6FA"

#define UMComPostColorLineGray @"#EEEFF3"
#define UMComPostColorBlue @"#008BEA"
#define UMComPostColorBgColor @"#333333"

#define UMComPostColorOrange @"#FF9D0F"
#define UMComPostColorBlue @"#008BEA"

#define UMComPostColorBottomLine @"#DEDEDE"

//#define Double
#ifdef Double
#define UMComPostFontTitle (32 * 3 / 4)
#define UMComPostFontBody (30 * 3 / 4)
#define UMComPostFontInnerBody (28 * 3 / 4)
#define UMComPostFontPoster (26 * 3 / 4)
#define UMComPostFontCommon (24 * 3 / 4)
#else
#define UMComPostFontTitle 16
#define UMComPostFontBody 15
#define UMComPostFontInnerBody 14
#define UMComPostFontPoster 13
#define UMComPostFontCommon 12
#endif

typedef NS_ENUM(NSInteger, UMComPostContentActionType) {
    UMComPostContentActionAvatar,
    UMComPostContentActionLike,
    UMComPostContentActionReply,
    UMComPostContentActionMenu
};

@class UMComPostContentBaseCell, UMComUser, UMComImageUrl, UMComImageView, UMComComment, UMComFeed, UMComMutiText, UMComGridViewerController;

typedef void (^UMComPostContentActionBlock)(UMComPostContentBaseCell *cell, UMComPostContentActionType type);
typedef void (^UMComPostContentImageTouchBlock)(UIViewController *viewerViewController, UIImageView *imageView);
typedef void (^UMComPostContentTouchUrlBlock)(NSString *url);

@interface UMComPostContentBaseCell : UITableViewCell

@property (nonatomic, strong) UMComFeed *feed;
@property (nonatomic, strong) UMComUser *user;
@property (nonatomic, strong) UMComComment *comment;
@property (nonatomic, strong) NSArray<UMComImageUrl *> *imageUrls;

@property (nonatomic, assign) BOOL isComment;
@property (nonatomic, assign) NSUInteger drawOriginX;

@property (nonatomic, assign) NSUInteger cellHeight;

@property (nonatomic, strong) UMComPostContentActionBlock actionBlock;
@property (nonatomic, strong) UMComPostContentImageTouchBlock imageBlock;
@property (nonatomic, strong) UMComPostContentTouchUrlBlock urlBlock;

- (void)refreshLayoutWithCalculatedTextObj:(UMComMutiText *)textObj;

// Child rewrites method blow if needed
- (void)refreshHeaderLayout;
- (void)refreshImageLayout;
- (void)refreshFooterLayout;
- (void)registerCellActionBlock:(UMComPostContentActionBlock)block;
- (void)registerImageActionBlock:(UMComPostContentImageTouchBlock)block;

@end
