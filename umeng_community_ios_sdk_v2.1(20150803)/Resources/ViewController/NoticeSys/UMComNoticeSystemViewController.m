//
//  UMComNoticeSystemViewController.m
//  UMCommunity
//
//  Created by umeng on 15/7/9.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComNoticeSystemViewController.h"
#import "UMComPageControlView.h"
#import "UMComTools.h"
#import "UMComBarButtonItem.h"
#import "UIViewController+UMComAddition.h"
#import "UMComFeedTableViewController.h"
#import "UMComPullRequest.h"
#import "UMComSession.h"
#import "UMComSysLikeTableView.h"
#import "UMComCommentControlView.h"
#import "UMComTopicFeedViewController.h"
#import "UMComUserCenterViewController.h"
#import "UMComCommentEditView.h"
#import "UMComPushRequest.h"
#import "UMComShowToast.h"
#import "UMComMenuControlView.h"
#import "UMComFeedsTableView.h"
#import "UMComRefreshView.h"
#import "UMComClickActionDelegate.h"

@interface UMComNoticeSystemViewController ()<UMComClickActionDelegate>

@property (nonatomic, strong) UMComPageControlView *titlePageControl;

@property (nonatomic, strong) UIView *alertView;

@property (nonatomic, strong) UMComCommentControlView *commentView;

@property (nonatomic, strong) UMComSysLikeTableView *likeView;

@property (nonatomic, strong) NSMutableArray *noticeItemList;

@property (nonatomic, strong) UMComCommentEditView *commentEditView;

@end

@implementation UMComNoticeSystemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.noticeItemList = [NSMutableArray arrayWithCapacity:3];
    [self refreshNoticeItemViews];
    [self creatNigationItemView];
    self.fetchFeedsController = [[UMComUserFeedBeAtRequest alloc]initWithUid:[UMComSession sharedInstance].uid count:BatchSize];
    [self refreshDataFromServer:nil];
    self.alertView = (UIView *)self.feedsTableView;
    //创建评论列表视图
    UMComCommentControlView *commentTableView = [[UMComCommentControlView alloc]initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
    commentTableView.delegate = self;
    [self.view addSubview:commentTableView];
    self.commentView = commentTableView;
    //创建点赞列表视图
    UMComSysLikeTableView *likeView = [[UMComSysLikeTableView alloc]initWithFrame:CGRectMake(self.view.frame.size.width, -kUMComRefreshOffsetHeight, self.view.frame.size.width, self.view.frame.size.height+kUMComRefreshOffsetHeight) style:UITableViewStylePlain];
    likeView.cellActionDelegate = self;
    [self.view addSubview:likeView];
    self.likeView = likeView;
    self.likeView.headView = [self headView];
    self.likeView.footView = [self footView];
    
    UISwipeGestureRecognizer *leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipToLeftDirection:)];
    leftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftGestureRecognizer];
    
    UISwipeGestureRecognizer *rightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipToRightDirection:)];
    rightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightGestureRecognizer];
    // Do any additional setup after loading the view.
}
- (void)swipToLeftDirection:(UISwipeGestureRecognizer *)swip
{
    if (self.titlePageControl.currentPage < 2) {
        self.titlePageControl.currentPage += 1;
        [self transitionViews];
    }
}

- (void)swipToRightDirection:(UISwipeGestureRecognizer *)swip
{
    if (self.titlePageControl.currentPage > 0) {
        self.titlePageControl.currentPage -= 1;
        [self transitionViews];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    for (UIView *view  in self.noticeItemList) {
        view.hidden = YES;
    }
}

- (UMComRefreshView *)headView
{
    UMComRefreshView *headView = [[UMComRefreshView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kUMComRefreshOffsetHeight)];
    return headView;
}

- (UMComRefreshView *)footView
{
    UMComRefreshView *footView = [[UMComRefreshView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kUMComRefreshOffsetHeight)];
    footView.isPull = NO;
    return footView;
}

- (void)creatNigationItemView
{
     //创建菜单栏
    UMComPageControlView *titlePageControl = [[UMComPageControlView alloc]initWithFrame:CGRectMake(0, 0, 200, 28) itemTitles:[NSArray arrayWithObjects:UMComLocalizedString(@"@Me", @"@我"),UMComLocalizedString(@"comment",@"评论"),UMComLocalizedString(@"like",@"点赞"), nil] currentPage:0];
    titlePageControl.currentPage = 0;
    titlePageControl.selectedColor = [UIColor whiteColor];
    titlePageControl.unselectedColor = [UIColor blackColor];
    [titlePageControl setItemImages:[NSArray arrayWithObjects:[UIImage imageNamed:@"left_frame"],[UIImage imageNamed:@"midle_frame"],[UIImage imageNamed:@"right_item"], nil]];
    __weak typeof(self) wealSelf = self;
    titlePageControl.didSelectedAtIndexBlock = ^(NSInteger index){
        [wealSelf transitionViews];
    };
    [titlePageControl reloadPages];
    [self.navigationItem setTitleView:titlePageControl];
    self.titlePageControl = titlePageControl;
    
}

- (void)refreshNoticeItemViews
{
    CGFloat rightDal = 0;
    if (self.view.frame.size.width > 320) {
        rightDal = 8.6*3/2;
    }
    CGFloat titleViewWidth = self.titlePageControl.frame.size.width;
    CGFloat titlePageViewOriginX = (self.view.frame.size.width-titleViewWidth)/2;
    NSDictionary *unReadMessageDict = [UMComSession sharedInstance].unReadMessageDictionary;
    if (self.noticeItemList.count == 0) {
        for (int index = 1; index < 4; index ++) {
            UIView *notificationView = [self creatNoticeViewWithOriginX:titlePageViewOriginX+titleViewWidth/3*index-rightDal];
            notificationView.hidden = YES;
            [self.navigationController.navigationBar addSubview:notificationView];
            [self.noticeItemList addObject:notificationView];
        }
    }
    UIView *notiView = self.noticeItemList[0];
    if ([unReadMessageDict valueForKey:@"like"] && [[unReadMessageDict valueForKey:@"like"] integerValue]>0) {
        notiView.hidden = NO;
    }else{
        notiView.hidden = YES;
    }
    notiView = self.noticeItemList[1];
    if ([unReadMessageDict valueForKey:@"comment"] && [[unReadMessageDict valueForKey:@"comment"] integerValue]>0) {
        notiView.hidden = NO;
    }else{
        notiView.hidden = YES;
    }
    notiView = self.noticeItemList[2];
    if ([unReadMessageDict valueForKey:@"at"] && [[unReadMessageDict valueForKey:@"at"] integerValue]>0) {
        notiView.hidden = NO;
    }else{
        notiView.hidden = YES;
    }
}


- (UIView *)creatNoticeViewWithOriginX:(CGFloat)originX
{
    CGFloat noticeViewWidth = 8.6;
    UIView *itemNoticeView = [[UIView alloc]initWithFrame:CGRectMake(originX, noticeViewWidth/2, noticeViewWidth, noticeViewWidth)];
    itemNoticeView.backgroundColor = [UIColor redColor];
    itemNoticeView.layer.cornerRadius = noticeViewWidth/2;
    itemNoticeView.clipsToBounds = YES;
    itemNoticeView.hidden = YES;
    return itemNoticeView;
}

- (void)transitionViews
{
    __block UIView *notiView = nil;
    __weak typeof(self) weakSelf = self;
    if (self.titlePageControl.currentPage == 0) {
        self.alertView.hidden = NO;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            weakSelf.alertView.frame = CGRectMake(0, weakSelf.alertView.frame.origin.y, weakSelf.alertView.frame.size.width, weakSelf.alertView.frame.size.height);
            weakSelf.commentView.frame = CGRectMake(weakSelf.view.frame.size.width, weakSelf.commentView.frame.origin.y, weakSelf.commentView.frame.size.width, weakSelf.commentView.frame.size.height);
            weakSelf.likeView.frame = CGRectMake(weakSelf.view.frame.size.width, weakSelf.likeView.frame.origin.y, weakSelf.likeView.frame.size.width, weakSelf.likeView.frame.size.height);
        } completion:^(BOOL finished) {
            notiView = weakSelf.noticeItemList[0];
            notiView.hidden = YES;
            weakSelf.commentView.hidden = YES;
            weakSelf.likeView.hidden = YES;
        }];
    }else if (self.titlePageControl.currentPage == 1){
        self.commentView.hidden = NO;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            weakSelf.alertView.frame =  CGRectMake(-weakSelf.view.frame.size.width, weakSelf.alertView.frame.origin.y, weakSelf.alertView.frame.size.width, weakSelf.alertView.frame.size.height);
            weakSelf.commentView.frame = CGRectMake(0, weakSelf.commentView.frame.origin.y, weakSelf.commentView.frame.size.width, weakSelf.commentView.frame.size.height);
            weakSelf.likeView.frame = CGRectMake(weakSelf.view.frame.size.width, weakSelf.likeView.frame.origin.y, weakSelf.likeView.frame.size.width, weakSelf.likeView.frame.size.height);
        } completion:^(BOOL finished) {
            notiView = weakSelf.noticeItemList[1];
            notiView.hidden = YES;
            weakSelf.alertView.hidden = YES;
            weakSelf.likeView.hidden = YES;
        }];
    }else{
        self.likeView.hidden = NO;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            weakSelf.alertView.frame = CGRectMake(-weakSelf.view.frame.size.width, weakSelf.alertView.frame.origin.y, weakSelf.alertView.frame.size.width, weakSelf.alertView.frame.size.height);
            weakSelf.commentView.frame = CGRectMake(-weakSelf.view.frame.size.width, weakSelf.commentView.frame.origin.y, weakSelf.commentView.frame.size.width, weakSelf.commentView.frame.size.height);
            weakSelf.likeView.frame = CGRectMake(0, weakSelf.likeView.frame.origin.y, weakSelf.likeView.frame.size.width, weakSelf.likeView.frame.size.height);
        } completion:^(BOOL finished) {
            notiView = self.noticeItemList[2];
            notiView.hidden = YES;
            self.commentView.hidden = YES;
            self.alertView.hidden = YES;
        }];
    }
}


#pragma mark - UMComClickActionDelegate
- (void) customObj:(id)obj clickOnComment:(UMComComment *)comment feed:(UMComFeed *)feed
{
    if (!self.commentEditView) {
        self.commentEditView = [[UMComCommentEditView alloc]initWithSuperView:self.view];
        __weak typeof(self) weakSelf = self;
        self.commentEditView.SendCommentHandler = ^(NSString *commentText){
            [weakSelf postComment:commentText comment:comment feed:feed];
        };
    }
    [self.commentEditView presentReplyView:comment];
}


- (void)postComment:(NSString *)content comment:(UMComComment *)comment feed:(UMComFeed *)feed
{
    __weak typeof (self) weakSelf = self;
    [UMComCommentFeedRequest postWithSourceFeedId:feed.feedID commentContent:content replyUserId:comment.creator.uid completion:^(NSError *error) {
        if (error) {
            [UMComShowToast createCommentFail:error];
        }else{
            [weakSelf.commentView refreshCommentData];
            feed.comments_count = [NSNumber numberWithInt:[feed.comments_count intValue]+1];
            [[NSNotificationCenter defaultCenter] postNotificationName:CommentOperationFinish object:feed];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
