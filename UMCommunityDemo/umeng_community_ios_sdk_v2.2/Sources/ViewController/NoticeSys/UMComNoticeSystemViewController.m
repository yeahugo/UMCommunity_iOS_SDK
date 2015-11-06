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
#import "UMComFeedTableView.h"
#import "UMComRefreshView.h"
#import "UMComClickActionDelegate.h"
#import "UMComSysCommentTableView.h"
#import "UMComUser.h"
#import "UMComComment.h"
#import "UMComUnReadNoticeModel.h"

@interface UMComNoticeSystemViewController ()<UMComClickActionDelegate>

@property (nonatomic, strong) UMComPageControlView *titlePageControl;

@property (nonatomic, strong) UIView *alertView;

@property (nonatomic, strong) UMComCommentControlView *commentView;

@property (nonatomic, strong) UMComSysLikeTableView *likeView;

@property (nonatomic, strong) UMComCommentEditView *commentEditView;

@end

@implementation UMComNoticeSystemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self creatNigationItemView];
    __weak typeof(self) weakSelf = self;
    
    __block UMComUnReadNoticeModel *unReadNotice = [UMComSession sharedInstance].unReadNoticeModel;
    
    //当网络请求成功时将@我的消息置为已读
    self.feedsTableView.loadSeverDataCompletionHandler = ^(NSArray *data, BOOL haveNextPage, NSError *error){
        if (!error) {            
            unReadNotice.notiByAtCount = 0;
            [weakSelf refreshNoticeItemViews];
        }
    };
    self.alertView = (UIView *)self.feedsTableView;
    //创建评论列表视图
    UMComCommentControlView *commentTableView = [[UMComCommentControlView alloc]initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
    commentTableView.delegate = self;
    [self.view addSubview:commentTableView];
    self.commentView = commentTableView;
    //当网络请求成功时将收到的评论消息置为已读
    self.commentView.commentReplyTableView.loadSeverDataCompletionHandler = ^(NSArray *data, BOOL haveNextPage, NSError *error){
        if (!error) {
            unReadNotice.notiByCommentCount = 0;
            [weakSelf refreshNoticeItemViews];
        }
    };
    //创建点赞列表视图
    UMComSysLikeTableView *likeView = [[UMComSysLikeTableView alloc]initWithFrame:CGRectMake(self.view.frame.size.width, -kUMComRefreshOffsetHeight, self.view.frame.size.width, self.view.frame.size.height+kUMComRefreshOffsetHeight) style:UITableViewStylePlain];
    likeView.cellActionDelegate = self;
    [self.view addSubview:likeView];
    self.likeView = likeView;
    //当网络请求成功时将收到的点赞消息置为已读
    self.likeView.loadSeverDataCompletionHandler = ^(NSArray *data, BOOL haveNextPage, NSError *error){
        if (!error) {
            unReadNotice.notiByLikeCount = 0;
            [weakSelf refreshNoticeItemViews];
        }
    };
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNoticeItemViews) name:kUMComUnreadNotificationRefreshNotification object:nil];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)creatNigationItemView
{
     //创建菜单栏
    UMComPageControlView *titlePageControl = [[UMComPageControlView alloc]initWithFrame:CGRectMake(0, 0, 200, 28) itemTitles:[NSArray arrayWithObjects:UMComLocalizedString(@"@Me", @"@我"),UMComLocalizedString(@"comment",@"评论"),UMComLocalizedString(@"like",@"点赞"), nil] currentPage:0];
    titlePageControl.currentPage = 0;
    titlePageControl.selectedColor = [UIColor whiteColor];
    titlePageControl.unselectedColor = [UIColor blackColor];
    [titlePageControl setItemImages:[NSArray arrayWithObjects:UMComImageWithImageName(@"left_frame"),UMComImageWithImageName(@"midle_frame"),UMComImageWithImageName(@"right_item"), nil]];
    __weak typeof(self) wealSelf = self;
    titlePageControl.didSelectedAtIndexBlock = ^(NSInteger index){
        [wealSelf transitionViews];
    };
    [titlePageControl reloadPages];
    [self.navigationItem setTitleView:titlePageControl];
    self.titlePageControl = titlePageControl;
    [self refreshNoticeItemViews];
    
}

- (void)refreshNoticeItemViews
{
    CGFloat rightDal = 0;
    if (self.view.frame.size.width > 320) {
        rightDal = 8.6*3/2;
    }
    NSMutableArray *tempArray = [NSMutableArray array];
    
    UMComUnReadNoticeModel *unReadNotice = [UMComSession sharedInstance].unReadNoticeModel;
    
    if (unReadNotice.notiByAtCount > 0) {
        [tempArray addObject:@0];
    }
    if (unReadNotice.notiByCommentCount > 0) {
        [tempArray addObject:@1];
    }
    if (unReadNotice.notiByLikeCount > 0) {
        [tempArray addObject:@2];
    }
    self.titlePageControl.indexesOfNotices = tempArray;
    [self.titlePageControl reloadPages];
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
            notiView.hidden = YES;
            weakSelf.commentView.hidden = YES;
            weakSelf.likeView.hidden = YES;
        }];
    }else if (self.titlePageControl.currentPage == 1){
     
        [self.commentView fecthAllCommentCommentData];
        self.commentView.hidden = NO;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            weakSelf.alertView.frame =  CGRectMake(-weakSelf.view.frame.size.width, weakSelf.alertView.frame.origin.y, weakSelf.alertView.frame.size.width, weakSelf.alertView.frame.size.height);
            weakSelf.commentView.frame = CGRectMake(0, weakSelf.commentView.frame.origin.y, weakSelf.commentView.frame.size.width, weakSelf.commentView.frame.size.height);
            weakSelf.likeView.frame = CGRectMake(weakSelf.view.frame.size.width, weakSelf.likeView.frame.origin.y, weakSelf.likeView.frame.size.width, weakSelf.likeView.frame.size.height);
        } completion:^(BOOL finished) {
            notiView.hidden = YES;
            weakSelf.alertView.hidden = YES;
            weakSelf.likeView.hidden = YES;
        }];
    }else{
        if (weakSelf.likeView.dataArray.count == 0) {
            [weakSelf.likeView loadAllData:nil fromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            }];
        }
        weakSelf.likeView.hidden = NO;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            weakSelf.alertView.frame = CGRectMake(-weakSelf.view.frame.size.width, weakSelf.alertView.frame.origin.y, weakSelf.alertView.frame.size.width, weakSelf.alertView.frame.size.height);
            weakSelf.commentView.frame = CGRectMake(-weakSelf.view.frame.size.width, weakSelf.commentView.frame.origin.y, weakSelf.commentView.frame.size.width, weakSelf.commentView.frame.size.height);
            weakSelf.likeView.frame = CGRectMake(0, weakSelf.likeView.frame.origin.y, weakSelf.likeView.frame.size.width, weakSelf.likeView.frame.size.height);
        } completion:^(BOOL finished) {
            notiView.hidden = YES;
            weakSelf.commentView.hidden = YES;
            weakSelf.alertView.hidden = YES;
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
    [UMComPushRequest postWithSourceFeed:feed
                          commentContent:content
                               replyUser:comment.creator
                    commentCustomContent:nil
                                  images:nil
                              completion:^(NSError *error) {
                                    if (error) {
                                        [UMComShowToast showFetchResultTipWithError:error];
                                    }else{
                                        [weakSelf.commentView refreshCommentData];
                                        [[NSNotificationCenter defaultCenter] postNotificationName:kUMComCommentOperationFinishNotification object:feed];
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
