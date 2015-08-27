//
//  UMComFeedsTableViewCell.h
//  UMCommunity
//
//  Created by Gavin Ye on 8/27/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UMComFeedStyle,UMComFeed,UMComFeedContentView;

@protocol UMComClickActionDelegate;

@interface UMComFeedsTableViewCell : UITableViewCell

@property (nonatomic, weak) id<UMComClickActionDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;

//
@property (weak, nonatomic) IBOutlet UIImageView *likeImageView;


@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;

@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;

@property (weak, nonatomic) IBOutlet UILabel *forwardCountLabel;
//
@property (weak, nonatomic) IBOutlet UIView *bottomMenuBgView;

@property (nonatomic, strong) UMComFeedContentView *feedContentView;

- (void)reloadFeedWithfeedStyle:(UMComFeedStyle *)feedStyle tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@property (weak, nonatomic) IBOutlet UIView *likeBgView;
@property (weak, nonatomic) IBOutlet UIView *forwardBgView;
@property (weak, nonatomic) IBOutlet UIView *commentBgView;



@end
