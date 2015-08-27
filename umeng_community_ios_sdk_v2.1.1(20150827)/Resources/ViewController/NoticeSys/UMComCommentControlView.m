//
//  UMComCommentControlView.m
//  UMCommunity
//
//  Created by umeng on 15/7/12.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComCommentControlView.h"
#import "UMComPullRequest.h"
#import "UMComSysCommentTableView.h"
#import "UMComSession.h"
#import "UMComMenuControlView.h"
#import "UMComRefreshView.h"
#import "UMComClickActionDelegate.h"


@interface UMComCommentControlView ()


@property (nonatomic, strong) UMComPullRequest *commentFecthRequest;

@property (nonatomic, strong) UMComPullRequest *commentReplayFecthRequest;

@property (nonatomic, strong) UIView *menuBGView;


@end

@implementation UMComCommentControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.menuControlView = [[UMComMenuControlView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width*3/4, 50)];
        self.menuControlView.center = CGPointMake(frame.size.width/2, self.menuControlView.frame.size.height/2);
        __weak typeof(self) weakSelf = self;
        self.menuControlView.SelectedIndex = ^(NSInteger index){
            weakSelf.index = index;
            if (index == 0) {
                [weakSelf clikOnLeftButton];
            }else{
                [weakSelf clikOnRightButton];
            }
        };
        self.menuBGView = [[UIView alloc]initWithFrame:CGRectMake(0, self.menuControlView.frame.origin.y, frame.size.width, self.menuControlView.frame.size.height)];
        self.menuBGView.backgroundColor = self.menuControlView.backgroundColor;
        [self.menuBGView addSubview:self.menuControlView];
      
        self.menuControlView.bottomLineView.frame = CGRectMake(-self.menuControlView.frame.origin.x, self.menuControlView.bottomLineView.frame.origin.y, frame.size.width, self.menuControlView.bottomLineView.frame.size.height);
        [self.menuControlView.leftButton setTitle:@"收到的评论" forState:UIControlStateNormal];
        [self.menuControlView.rightButton setTitle:@"发出的评论" forState:UIControlStateNormal];
        
        self.commentReplyTableView = [[UMComSysCommentTableView alloc]initWithFrame:CGRectMake(0, self.menuControlView.frame.size.height-kUMComRefreshOffsetHeight, self.frame.size.width, self.frame.size.height-self.menuControlView.frame.size.height) style:UITableViewStylePlain];
        self.commentReplyTableView.fetchRequest = [[UMComUserCommentsReceivedRequest alloc]initWithCount:BatchSize];
        [self addSubview:self.commentReplyTableView];
        [self addSubview:self.menuBGView];
        [self clikOnLeftButton];
    }
    return self;
}

- (void)refreshCommentData
{
    if (self.index == 0) {
        [self.commentReplyTableView refreshNewDataFromServer:nil];
    }else{
        [self.commentTableView refreshNewDataFromServer:nil];
    }
}

- (void)fecthAllCommentCommentData
{
    if (self.index == 0) {
        if (self.commentReplyTableView.dataArray.count == 0) {
            [self.commentReplyTableView loadAllData:nil fromServer:nil];
        }
    }else{
        if (self.commentTableView.dataArray.count == 0) {
            [self.commentTableView loadAllData:nil fromServer:nil];
        }
    }
}

- (void)setDelegate:(id<UMComClickActionDelegate>)delegate
{
    _delegate = delegate;
    _commentTableView.cellActionDelegate = delegate;
    _commentReplyTableView.cellActionDelegate = delegate;
}


- (void)clikOnLeftButton
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.commentReplyTableView.frame = CGRectMake(0, self.commentReplyTableView.frame.origin.y, self.commentReplyTableView.frame.size.width, self.commentReplyTableView.frame.size.height);
        self.commentTableView.frame = CGRectMake(self.frame.size.width, self.commentTableView.frame.origin.y, self.commentTableView.frame.size.width, self.commentTableView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

- (void)clikOnRightButton
{
    if (!self.commentTableView) {
        self.commentTableView = [[UMComSysCommentTableView alloc]initWithFrame:CGRectMake(self.frame.size.width, self.menuControlView.frame.size.height - kUMComRefreshOffsetHeight, self.commentReplyTableView.frame.size.width, self.commentReplyTableView.frame.size.height) style:UITableViewStylePlain];
        self.commentTableView.isShowReplyButton = NO;
        self.commentTableView.fetchRequest = [[UMComUserCommentsSentRequest alloc]initWithCount:BatchSize];
        [self insertSubview:self.commentTableView belowSubview:self.menuBGView];
        [self.commentTableView loadAllData:nil fromServer:nil];
    }
    _commentTableView.cellActionDelegate = self.delegate;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.commentTableView.frame = CGRectMake(0, self.commentTableView.frame.origin.y, self.commentTableView.frame.size.width, self.commentTableView.frame.size.height);
        self.commentReplyTableView.frame = CGRectMake(-self.frame.size.width, self.commentReplyTableView.frame.origin.y, self.commentReplyTableView.frame.size.width, self.commentReplyTableView.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
