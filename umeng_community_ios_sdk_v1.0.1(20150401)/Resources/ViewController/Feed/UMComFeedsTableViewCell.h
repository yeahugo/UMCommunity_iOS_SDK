//
//  UMComFeedsTableViewCell.h
//  UMCommunity
//
//  Created by Gavin Ye on 8/27/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComFeed.h"
#import "UMComGridView.h"
#import "UMImageView.h"
#import "UMComMutiStyleTextView.h"

@interface UMComFeedsTableViewCell : UITableViewCell
<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;

@property (nonatomic, weak) IBOutlet UMComMutiStyleTextView *fakeTextView;

@property (nonatomic, weak) IBOutlet UMComMutiStyleTextView *fakeOriginTextView;

@property (nonatomic, weak) IBOutlet UMComGridView * gridView;

@property (nonatomic, copy) NSString *userName;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, weak) IBOutlet UIImageView *commentUserAvatar;

@property (nonatomic, weak) NSMutableArray *commentLabels;

@property (nonatomic, weak) NSMutableArray *commentImages;

@property (nonatomic, weak) IBOutlet UMComMutiStyleTextView *likeListTextView;

@property (weak, nonatomic) IBOutlet UIView *likeImageBgVIew;

@property (nonatomic, weak) IBOutlet UIImageView *imagesBackGroundView;

@property (nonatomic, strong) NSMutableArray * avatarImages;

@property (nonatomic, weak) IBOutlet UMImageView * avatarImageView;

@property (nonatomic, strong) UILabel * likeCountLabel;

@property (nonatomic, weak) IBOutlet UILabel * dateLabel;

@property (nonatomic, weak) IBOutlet UILabel * locationLabel;

@property (nonatomic, weak) IBOutlet UIView * locationBackground;

@property (nonatomic, weak) IBOutlet UIView *editBackGround;

@property (nonatomic, weak) IBOutlet UIButton *showEditBackGround;

@property (nonatomic, weak) IBOutlet UITableView *commentTableView;

@property (nonatomic, weak) IBOutlet UIButton *likeButton;

@property (nonatomic, strong) UIView *seperateView;

@property (nonatomic, strong) NSArray *reloadComments;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) UMComFeed *feed;

+ (UMComFeedsTableViewCell *)cell;

- (IBAction)onClickUserProfile:(id)sender;

- (IBAction)onClickEdit:(id)sender;

- (void)reload:(UMComFeed *)feed tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

+ (float)getCellHeightWithFeed:(UMComFeed *)feed isShowComment:(BOOL)isShowComment tableViewWidth:(float)viewWidth;

- (void)dissMissEditBackGround;

- (IBAction)onClickComment:(id)sender;

- (IBAction)onClickLike:(id)sender;

- (IBAction)onClickForward:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *acounTypeLabel;

@property (nonatomic, copy) void (^deleteFeedSucceedAction)(UMComFeed *feed);

- (void)showMoreComments;


@end
