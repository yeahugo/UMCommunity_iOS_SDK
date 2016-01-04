//
//  UMComPostTableViewCell.h
//  UMCommunity
//
//  Created by umeng on 11/27/15.
//  Copyright © 2015 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UMComFeed;
@class UMComGridViewerController;

@interface UMComPostTableViewCell : UITableViewCell

@property (nonatomic, strong) UIView *topMarkIcon;

@property (nonatomic, assign) BOOL showTopMark;

@property (nonatomic, strong) UMComFeed *postFeed;
@property (nonatomic, strong) void (^touchOnImage)(UMComGridViewerController *viewerController, UIImageView *imageView);

+ (NSUInteger)cellHeightForPlainStyle;
+ (NSUInteger)cellHeightForImageStyle;

- (void)refreshLayout;

@end
