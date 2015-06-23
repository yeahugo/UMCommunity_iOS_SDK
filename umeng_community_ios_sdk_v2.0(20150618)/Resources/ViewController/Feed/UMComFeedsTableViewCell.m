//
//  UMComFeedsTableViewCell.m
//  UMCommunity
//
//  Created by Gavin Ye on 8/27/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComFeedsTableViewCell.h"
#import "UMComTopic.h"
#import "UMComSession.h"
#import "UMComFeedContentView.h"
#import "UMComFeed.h"
#import "UMComFeedStyle.h"


@interface UMComFeedsTableViewCell ()<UMComClickActionDelegate>

@property (nonatomic, assign) CGFloat cellSubviewCommonWidth;

@property (nonatomic, strong) UMComFeedStyle *feedStyle;
@property (nonatomic, strong) UMComFeed *feed;

@property (nonatomic, strong) UMComFeedContentView *feedContentView;


@end



@implementation UMComFeedsTableViewCell

-(void)awakeFromNib
{
    
    NSArray *feedDetailView = [[NSBundle mainBundle]loadNibNamed:@"UMComFeedContentView" owner:self options:nil];
    if (feedDetailView.count > 0) {
        self.feedContentView = [feedDetailView objectAtIndex:0];
    }
    self.feedContentView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    [self.contentView addSubview:self.feedContentView];
    
    UITapGestureRecognizer *tapSelfView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToFeedDetaiView)];
    [self addGestureRecognizer:tapSelfView];
    
    UITapGestureRecognizer *tapLike = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickLike:)];
    [self.likeBgView addGestureRecognizer:tapLike];
    UITapGestureRecognizer *tapForward = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickForward:)];
    [self.forwardBgView addGestureRecognizer:tapForward];
    UITapGestureRecognizer *tapComment = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickComment:)];
    [self.commentBgView addGestureRecognizer:tapComment];
    [self.feedContentView addSubview:self.bottomMenuBgView];
}


- (void)drawRect:(CGRect)rect
{
    UIColor *color = TableViewSeparatorRGBColor;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height - TableViewCellSpace, rect.size.width, TableViewCellSpace));
}

/****************************reload cell views start *****************************/
- (void)reloadFeedWithfeedStyle:(UMComFeedStyle *)feedStyle tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    self.feed = feedStyle.feed;
    self.indexPath = indexPath;
    self.feedContentView.delegate = self.delegate;
    self.cellSubviewCommonWidth = feedStyle.subViewWidth;
    [self.feedContentView reloadDetaiViewWithFeedStyle:feedStyle viewWidth:tableView.frame.size.width];
  
    if ([self.feed.liked boolValue]) {
        [self.likeImageView setImage:[UIImage imageNamed:@"um_like+"]];
    }else{
        [self.likeImageView setImage:[UIImage imageNamed:@"um_like"]];
    }
    [self reloadMenuBgViewWithFeed:self.feed originHeigt:self.feedContentView.dateLabel.frame.origin.y];
}

- (void)reloadMenuBgViewWithFeed:(UMComFeed *)feed originHeigt:(CGFloat)originHeigth
{
    self.likeCountLabel.text = [NSString stringWithFormat:@"%d",[self.feed.likes_count intValue]];
    self.commentCountLabel.text = [NSString stringWithFormat:@"%d",[self.feed.comments_count intValue]];
    self.forwardCountLabel.text = [NSString stringWithFormat:@"%d",[self.feed.forward_count intValue]];
    self.bottomMenuBgView.frame = CGRectMake(self.bottomMenuBgView.frame.origin.x, originHeigth, self.bottomMenuBgView.frame.size.width, self.bottomMenuBgView.frame.size.height);
}

- (void)goToFeedDetaiView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnFeedText:)]) {
        [self.delegate customObj:self clickOnFeedText:self.feed];
    }
}

-(void)onClickComment:(UITapGestureRecognizer *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnComment:feed:)]) {
        [self.delegate customObj:self clickOnComment:nil feed:self.feed];
    }
}

-(void)onClickLike:(UITapGestureRecognizer *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnLikeFeed:)]) {
        [self.delegate customObj:self  clickOnLikeFeed:self.feed];
    }
}
//
-(void)onClickForward:(UITapGestureRecognizer *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnForward:)]) {
        [self.delegate customObj:self clickOnForward:self.feed];
    }
}

@end
