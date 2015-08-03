//
//  UMComFeedDetailViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 11/13/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComFeedDetailViewController.h"
#import "UMComFeed.h"
#import "UMComPullRequest.h"
#import "UMComCoreData.h"
#import "UMComComment.h"
#import "UMComBarButtonItem.h"
#import "UMComAction.h"
#import "UMComPullRequest.h"
#import "UIViewController+UMComAddition.h"
#import "UMComShowToast.h"
#import "UMComLike.h"
#import "UMComPushRequest.h"
#import "UMComCommentTableViewCell.h"
#import "UMComLikeUserViewController.h"
#import "UMComSession.h"
#import "UMComActionStyleTableView.h"
#import "UMComShareCollectionView.h"
#import "UMComFeedStyle.h"
#import "UMComFeedContentView.h"
#import "UMComLikeListView.h"
#import "UMComCommentTableView.h"
#import "UMComUserCenterCollectionView.h"
#import "UMComEditViewController.h"
#import "UMComNavigationController.h"
#import "UMComTopicFeedViewController.h"
#import "UMComCommentEditView.h"
#import "UMComUserCenterViewController.h"
#import "UMComScrollViewDelegate.h"
#import "UMComClickActionDelegate.h"

typedef enum {
    FeedType = 0,
    CommentType = 1
} OperationType;

//评论内容长度
//#define kCommentLenght 140

static const CGFloat kLikeViewHeight = 30;
static const NSString * Permission_delete_content = @"permission_delete_content";

@interface UMComFeedDetailViewController ()<UMComClickActionDelegate,UMComScrollViewDelegate>

#pragma mark - property
@property (nonatomic, copy) NSString *feedId;

@property (nonatomic, strong) UMComFeed *feed;

@property (nonatomic, copy) NSString *commentId;

@property (nonatomic, strong) UMComPullRequest *fetchFeedsController;

@property (nonatomic, strong) UMComPullRequest *fetchLikeRequest;

@property (nonatomic, strong) UMComFeedCommentsRequest *fecthCommentRequest;

@property (nonatomic, strong) UMComFeedStyle *feedStyle;

@property (nonatomic, strong) UMComFeedContentView *feedContentView;

@property (nonatomic, strong) UMComLikeListView *likeListView;

@property (nonatomic, strong) UMComCommentTableView *commentTableView;

@property (nonatomic, strong) UIView *feedDetaiView;

@property (nonatomic, strong) UMComActionStyleTableView *actionTableView;

@property (nonatomic, strong) UMComShareCollectionView *shareListView;

@property (nonatomic, strong) UIView *shadowBgView;

@property (nonatomic, strong) UMComCommentEditView *commentEditView;

@property (nonatomic, strong) NSString * viewExtra;

@end

@implementation UMComFeedDetailViewController
{
    BOOL isReply;
    BOOL isViewDidAppear;
    BOOL isrefreshLikeFinish;
    BOOL isrefreshCommentFinish;
    BOOL isHaveNextPage;
    OperationType operationType;
}
#pragma mark - UIViewController method
- (id)initWithFeed:(UMComFeed *)feed
{
    self = [super initWithNibName:@"UMComFeedDetailViewController" bundle:nil];
    if (self) {
        self.feed = feed;
        self.feedId = feed.feedID;
        isReply = NO;
        isViewDidAppear = NO;
        isrefreshLikeFinish = NO;
        isrefreshCommentFinish = NO;
        isHaveNextPage = NO;
    }
    return self;
}

- (id)initWithFeed:(NSString *)feedId
         commentId:(NSString *)commentId
         viewExtra:(NSString *)viewExtra
{
    self = [self initWithFeed:nil];
    if (self) {
        self.feedId = feedId;
        self.commentId = commentId;
        self.viewExtra = viewExtra;
    }
    return self;
}

- (id)initWithFeed:(UMComFeed *)feed showFeedDetailShowType:(UMComFeedDetailShowType)type
{
    self = [self initWithFeed:feed];
    if (self) {
        self.feedId = feed.feedID;
        self.showType = type;
    }
    return self;
}


- (void)getFetchedResultsController
{
    UMComOneFeedRequest *oneFeedController = [[UMComOneFeedRequest alloc] initWithFeedId:self.feedId viewExtra:self.viewExtra];
    self.fetchFeedsController = oneFeedController;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadViewsWithFeed:self.feed];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGRect frame = window.frame;
    CGFloat height = self.menuView.frame.size.height;
    self.menuView.frame = CGRectMake(0, frame.size.height-height, frame.size.width, height);
    [window addSubview:self.menuView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postFeedCompleteSucceed:) name:kNotificationPostFeedResult object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    isViewDidAppear = YES;
    if (isrefreshLikeFinish == YES && isrefreshCommentFinish == YES && self.showType == UMComShowFromClickComment) {
        [self showCommentEditViewWithComment:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.commentEditView dismissAllEditView];
    [self.menuView removeFromSuperview];
    isrefreshLikeFinish = NO;
    isrefreshCommentFinish = NO;
    if (self.showType == UMComShowFromClickComment) {
        self.showType = UMComShowFromClickDefault;
    }
    [self.shadowBgView removeFromSuperview];
    [self.actionTableView removeFromSuperview];
     [[NSNotificationCenter defaultCenter] removeObserver:kNotificationPostFeedResult name:UIKeyboardWillShowNotification object:nil];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    UIFont *font = UMComFontNotoSansLightWithSafeSize(14);
     self.forwarTitleLabel.font = font;
     self.likeStatusLabel.font = font;
     self.commentTitleLabel.font = font;

    [self setTitleViewWithTitle:UMComLocalizedString(@"Feed_Detail_Title", @"正文内容")];
    [self setBackButtonWithImage];
    if (self.navigationController.viewControllers.count <= 1) {
        [self setLeftButtonWithImageName:@"Backx" action:@selector(goBack)];
    }
    [self setRightButtonWithImageName:@"um_diandiandian" action:@selector(onClickHandlButton:)];
    NSArray *feedDetailView = [[NSBundle mainBundle]loadNibNamed:@"UMComFeedContentView" owner:self options:nil];
    if (feedDetailView.count > 0) {
        self.feedContentView = [feedDetailView objectAtIndex:0];
    }
    self.feedContentView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.feedContentView.delegate = self;
    self.feedDetaiView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 330)];
    self.feedContentView.collectionButton.hidden = NO;
    [self.feedDetaiView addSubview:self.feedContentView];
    self.feedDetaiView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    self.likeListView = [[UMComLikeListView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kLikeViewHeight)];
    self.likeListView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.feedDetaiView addSubview:self.likeListView];
    self.likeListView.delegate = self;
    
    self.commentTableView = [[UMComCommentTableView alloc]initWithFrame:CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height-40) style:UITableViewStylePlain];
    self.commentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.commentTableView.scrollViewDelegate = self;
    [self.commentTableView addSubview:self.feedDetaiView];
    self.commentTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.commentTableView.clickActionDelegate = self;
    [self.view addSubview:self.commentTableView];
    
    self.bottomLine.frame = CGRectMake(0, self.tableControlView.frame.size.height-0.5, self.view.frame.size.width, 0.5);
    self.bottomLine.backgroundColor = TableViewSeparatorRGBColor;
    self.topLine.frame = CGRectMake(0, 0, self.view.frame.size.width, 0.5);
    self.topLine.backgroundColor = [UIColor clearColor];
    [self.view bringSubviewToFront:self.tableControlView];
    self.menuView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    if (!self.feed) {
        [self fetchOnFeedFromServer];
    }else{
        [self reloadLikeImageView:self.feed];
        [self refreshFeedsLike:self.feed.feedID];
        [self refreshFeedsComments:self.feed.feedID];
    }
}

- (void)reloadLikeImageView:(UMComFeed *)feed
{
    if (feed.liked.boolValue) {
        self.likeImageView.image = [UIImage imageNamed:@"um_like+"];
        self.likeStatusLabel.text = UMComLocalizedString(@"cancel", @"取消");
    } else {
        self.likeStatusLabel.text = UMComLocalizedString(@"like", @"点赞");
        self.likeImageView.image = [UIImage imageNamed:@"um_like"];
    }
}


#pragma mark - private Method
- (void)reloadViewsWithFeed:(UMComFeed *)feed
{
    self.feedStyle = [UMComFeedStyle feedStyleWithFeed:feed viewWidth:self.view.frame.size.width feedType:feedDetailType];
    [self.feedContentView reloadDetaiViewWithFeedStyle:self.feedStyle viewWidth:self.view.frame.size.width];
    if (self.likeListView.likeList.count > 0) {
        self.likeListView.frame = CGRectMake(0, self.feedStyle.totalHeight+DeltaHeight, self.view.frame.size.width, kLikeViewHeight);
        self.likeListView.hidden = NO;
    }else{
        self.likeListView.frame = CGRectMake(0, self.feedStyle.totalHeight, self.view.frame.size.width, 0);
        self.likeListView.hidden = YES;
    }
    self.feedDetaiView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.feedStyle.totalHeight+ DeltaHeight+self.likeListView.frame.size.height);
    [self.forwarTitleLabel setText:[NSString stringWithFormat:@"转发(%d)",[self.feed.forward_count intValue]] ];
    [self.commentTitleLabel setText:[NSString stringWithFormat:@"评论(%d)",[self.feed.comments_count intValue]]];
    self.commentTableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.feedDetaiView.frame.size.height+self.tableControlView.frame.size.height)];
    [self.commentTableView.tableHeaderView addSubview:self.feedDetaiView];
    CGFloat contenSizeH = self.feedDetaiView.frame.size.height + self.view.frame.size.height - self.menuView.frame.size.height;
    if (contenSizeH< self.commentTableView.contentSize.height+ self.tableControlView.frame.size.height) {
        contenSizeH =  self.commentTableView.contentSize.height+ self.tableControlView.frame.size.height;
    }
    self.commentTableView.contentSize = CGSizeMake(self.view.frame.size.width, contenSizeH);
    [self resetSubViewWithScrollView:self.commentTableView];
    if (self.showType == UMComShowFromClickComment || self.showType == UMComShowFromClickRemoteNotice) {
        if (self.commentTableView.reloadComments.count > 0) {
            [self.commentTableView setContentOffset:CGPointMake(self.commentTableView.contentOffset.x, self.feedDetaiView.frame.size.height+1) animated:NO];
        }
        if (isViewDidAppear == YES ) {
            [self showCommentEditViewWithComment:nil];
        }
    }
}


- (void)fetchOnFeedFromServer
{
    if (!self.fetchFeedsController) {
        [self getFetchedResultsController];
    }
    __weak typeof(self) weakSelf = self;
    [self.fetchFeedsController fetchRequestFromCoreData:^(NSArray *data, NSError *error) {
        if ([data isKindOfClass:[NSArray class]] && data.count > 0) {
            weakSelf.feed = data[0];
            [weakSelf reloadViewsWithFeed:weakSelf.feed];
        }
        [self.fetchFeedsController fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            [self.commentTableView.refreshIndicatorView stopAnimating];
            [UIView animateWithDuration:0.5 animations:^{
                weakSelf.commentTableView.frame = CGRectMake(0, 0, weakSelf.commentTableView.frame.size.width, weakSelf.commentTableView.frame.size.height);
            } completion:^(BOOL finished) {
                [self.commentTableView.refreshIndicatorView stopAnimating];
            }];
            if ([data isKindOfClass:[NSArray class]] && data.count > 0) {
                weakSelf.feed = data[0];
                [weakSelf reloadViewsWithFeed:weakSelf.feed];
            }
            [weakSelf refreshFeedsLike:weakSelf.feed.feedID];
            [weakSelf refreshFeedsComments:weakSelf.feed.feedID];
            //如果是从接收消息通知进入详情页面， 则刷新未读消息数
            if (weakSelf.showType == UMComShowFromClickRemoteNotice) {
                [weakSelf refreshMessageData];
            }
        }];
    }];
    
}

- (void)refreshMessageData
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [UMComUserUnreadMeassageRequest requestUnreadMessageCountWithUid:[UMComSession sharedInstance].uid result:^(NSDictionary *responseObject, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (!error && [responseObject isKindOfClass:[NSDictionary class]]) {
            [UMComSession sharedInstance].unReadMessageDictionary = [NSMutableDictionary dictionaryWithDictionary:responseObject];
        }
    }];
}


- (void)refreshFeedsLike:(NSString *)feedId
{
    if (!self.fetchLikeRequest) {
         UMComFeedLikesRequest *feedLikesController = [[UMComFeedLikesRequest alloc] initWithFeedId:feedId count:TotalLikesSize];
        self.fetchLikeRequest = feedLikesController;
    }
    __weak typeof(self) weakSelf = self;

    [self.fetchLikeRequest fetchRequestFromCoreData:^(NSArray *data, NSError *error) {
        if (data.count > 0) {
            [weakSelf.likeListView reloadViewsWithfeed:weakSelf.feed likeArray:data];
            [weakSelf reloadViewsWithFeed:weakSelf.feed];
        }
        [self.fetchLikeRequest fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            if (!error) {
                [weakSelf.likeListView reloadViewsWithfeed:weakSelf.feed likeArray:data];
            }
            isrefreshLikeFinish = YES;
            [weakSelf reloadViewsWithFeed:weakSelf.feed];
        }];
    }];
}

- (void)refreshFeedsComments:(NSString *)feedId
{
    if (!self.fecthCommentRequest) {
        self.fecthCommentRequest = [[UMComFeedCommentsRequest alloc] initWithFeedId:feedId order:commentorderByTimeAsc count:BatchSize];
        
    }
    __weak typeof(self) weakSelf = self;
    [self.fecthCommentRequest fetchRequestFromCoreData:^(NSArray *data, NSError *error) {
        if (data.count > 0) {
            self.commentTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [weakSelf.commentTableView reloadCommentTableViewArrWithComments:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    int commentCount = [weakSelf.feed.comments_count intValue];
                    if (commentCount < data.count) {
                        commentCount = (int)data.count;
                    }
                    weakSelf.feed.comments_count = [NSNumber numberWithInt:commentCount];
                    [weakSelf.commentTableView reloadData];
                    [weakSelf reloadViewsWithFeed:weakSelf.feed];
                });
            });
        }
        [self.fecthCommentRequest fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            isHaveNextPage = haveNextPage;
            isrefreshCommentFinish = YES;
            if (!error) {
                if (data.count > 0) {
                    self.commentTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [weakSelf.commentTableView reloadCommentTableViewArrWithComments:data];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        int commentCount = [weakSelf.feed.comments_count intValue];
                        if (commentCount < data.count) {
                            commentCount = (int)data.count;
                        }
                        weakSelf.feed.comments_count = [NSNumber numberWithInt:commentCount];
                        [weakSelf.commentTableView reloadData];
                        [weakSelf reloadViewsWithFeed:weakSelf.feed];
                    });
                });
            }
        }];
    }];

}


- (IBAction)didClickOnLike:(UITapGestureRecognizer *)sender {
    [self.commentEditView dismissAllEditView];
    [self customObj:nil clickOnLikeFeed:self.feed];
}

- (IBAction)didClickOnForward:(UITapGestureRecognizer *)sender {
    [[UMComAction action] performActionAfterLogin:self.feed viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            UMComEditViewController *editViewController = [[UMComEditViewController alloc] initWithForwardFeed:self.feed];
            UMComNavigationController *editNaviController = [[UMComNavigationController alloc] initWithRootViewController:editViewController];
            [self presentViewController:editNaviController animated:YES completion:nil];
        }
    }];
}

- (IBAction)didClikeObComment:(UITapGestureRecognizer *)sender {
    [self.commentEditView dismissAllEditView];
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            [weakSelf showCommentEditViewWithComment:nil];
        }
    }];
}

- (void)turnToUserCenterViewWithUser:(UMComUser *)user
{
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            UMComUserCenterViewController *userCenterViewController = [[UMComUserCenterViewController alloc] initWithUser:user];
            [self.navigationController pushViewController:userCenterViewController animated:YES];
        }
    }];
    
}

- (void)hiddenShareListView
{
    [self hidenaActionTableView];
    [self hidenShareListView:self.shareListView bgView:self.shadowBgView];
}

- (void)resetSubViewWithScrollView:(UIScrollView *)scrollView
{
    [self.commentEditView dismissAllEditView];
    if (scrollView.contentOffset.y < self.feedDetaiView.frame.size.height) {
        self.tableControlView.frame = CGRectMake(self.tableControlView.frame.origin.x,self.feedDetaiView.frame.size.height-scrollView.contentOffset.y+scrollView.frame.origin.y, self.tableControlView.frame.size.width, self.tableControlView.frame.size.height);
    }else if (scrollView.contentOffset.y >= self.feedDetaiView.frame.size.height) {
        self.tableControlView.frame = CGRectMake(self.tableControlView.frame.origin.x, 0+scrollView.frame.origin.y, self.tableControlView.frame.size.width, self.tableControlView.frame.size.height);
    }
}
#pragma mark - UMComScrollViewDelegate

- (void)customScrollViewDidScroll:(UIScrollView *)scrollView lastPosition:(CGPoint)lastPosition
{
    [self resetSubViewWithScrollView:scrollView];
}

- (void)customScrollViewDidEnd:(UIScrollView *)scrollView lastPosition:(CGPoint)lastPosition
{
    [self resetSubViewWithScrollView:scrollView];
}

- (void)customScrollViewEndDrag:(UIScrollView *)scrollView lastPosition:(CGPoint)lastPosition
{
    
    CGFloat offset = scrollView.contentOffset.y;
    if (offset < -65) {
        [UIView animateWithDuration:0.3 animations:^{
            scrollView.frame = CGRectMake(0, kUMComRefreshOffsetHeight, scrollView.frame.size.width, scrollView.frame.size.height);
        }];
        [self fetchOnFeedFromServer];
    }else{
        [self.commentTableView.refreshIndicatorView stopAnimating];
    }
    if (offset > 0 && offset > scrollView.contentSize.height - (self.view.frame.size.height) && isHaveNextPage == YES){
        __weak typeof(self) weakSelf = self;
        [self.commentTableView.refreshIndicatorView stopAnimating];
        [self.fecthCommentRequest fetchNextPageFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            isHaveNextPage = haveNextPage;
            if (!error) {
                NSMutableArray *tempData = [NSMutableArray array];
                [tempData addObjectsFromArray:weakSelf.commentTableView.reloadComments];
                [tempData addObjectsFromArray:data];
                [weakSelf.commentTableView reloadCommentTableViewArrWithComments:tempData];
                int commentCount = [weakSelf.feed.comments_count intValue];
                if (commentCount < tempData.count) {
                    commentCount = (int)tempData.count;
                }
                if (weakSelf.showType == UMComShowFromClickComment) {
                    weakSelf.showType = UMComShowFromClickDefault;
                }
                weakSelf.feed.comments_count = [NSNumber numberWithInt:commentCount];
                [weakSelf.commentTableView reloadData];
                [weakSelf reloadViewsWithFeed:weakSelf.feed];
            }
        }];
    }
}

#pragma mark - showActionView
- (void)onClickHandlButton:(UIButton *)sender
{
    [self.commentEditView dismissAllEditView];
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            NSString *title = @"";
            NSString *imageName = @"";
            if ([weakSelf isPermission_delete_content]) {
                title = UMComLocalizedString(@"delete", @"删除");
                imageName = @"um_delete";
            } else {
                title = UMComLocalizedString(@"spam", @"举报");
                imageName = @"um_spam";
            }
            [weakSelf showActionTableViewWithImageNameList:[NSArray arrayWithObjects:imageName,@"um_copy", nil] titles:[NSArray arrayWithObjects:title,UMComLocalizedString(@"copy", @"复制"), nil] type:FeedType];
        }
    }];
}

- (BOOL)isPermission_delete_content
{
    BOOL isPermission_delete_content = NO;
    UMComUser *user = [UMComSession sharedInstance].loginUser;
    if ([user.permissions containsObject:Permission_delete_content] || [self.feed.creator.uid isEqualToString:user.uid]) {
        isPermission_delete_content = YES;
    }
    return isPermission_delete_content;
}

- (void)showActionTableViewWithImageNameList:(NSArray *)imageNameList titles:(NSArray *)titles type:(OperationType)type
{
    if (!self.actionTableView) {
        self.actionTableView = [[UMComActionStyleTableView alloc]initWithFrame:CGRectMake(15, self.view.frame.size.height, self.view.frame.size.width-30, 134) style:UITableViewStylePlain];
    }
    __weak UMComFeedDetailViewController *weakSelf = self;
    self.actionTableView.didSelectedAtIndexPath = ^(UMComActionStyleTableView *actionStyleView, NSIndexPath *indexPath){
        [weakSelf tableView:actionStyleView didSelectRowAtIndexPath:indexPath type:type];
    };
    [self.actionTableView setImageNameList:imageNameList titles:titles];
    self.actionTableView.feed = self.feed;
    if (!self.shadowBgView) {
        self.shadowBgView = [self createdShadowBgView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenShareListView)];
        [self.shadowBgView addGestureRecognizer:tap];
    }
    [self.view.window addSubview:self.shadowBgView];
    [self.view.window addSubview:self.actionTableView];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.actionTableView.frame = CGRectMake(self.actionTableView.frame.origin.x, self.view.window.frame.size.height-self.actionTableView.frame.size.height, self.actionTableView.frame.size.width, self.actionTableView.frame.size.height);
    } completion:nil];
}


- (void)tableView:(UMComActionStyleTableView *)actionStyleView didSelectRowAtIndexPath:(NSIndexPath *)indexPath type:(OperationType)type
{
    operationType = type;
    if (type == FeedType) {
        [self dealWithFeedActionWithIndex:indexPath.row];
    }else if (type == CommentType){
        [self dealWithCommentActionWithIndex:indexPath.row];
    }
}


- (void)dealWithCommentActionWithIndex:(NSInteger)index
{
    [self hiddenShareListView];
    if (index == 0) {
        UMComComment  *comment = self.commentTableView.selectedComment;
        if ([self isPermission_delete_content] || [comment.creator.uid isEqualToString:[UMComSession sharedInstance].loginUser.uid]) {
            [self showSureActionMessage:UMComLocalizedString(@"sure to deleted comment", @"确定要删除这条评论？")];
          
        }else{
            [self showSureActionMessage:UMComLocalizedString(@"sure to spam comment", @"确定要举报这条评论？")];
        }
    }else if (index == 1){
        [self showCommentEditViewWithComment:self.commentTableView.selectedComment];
    }
}


- (void)dealWithFeedActionWithIndex:(NSInteger)index
{
    [self hiddenShareListView];

    if (index == 0) {
        if ([self isPermission_delete_content]) {
            [self showSureActionMessage:UMComLocalizedString(@"sure to deleted comment", @"确定要删除这条消息？")];
        }else{
            [self showSureActionMessage:UMComLocalizedString(@"sure to spam comment", @"确定要举报这条消息？")];
        }
    }else if (index == 1){
        [self customObj:nil clickOnCopy:self.feed];
    }else{
        
    }
}

#pragma mark - UIAlertView
- (void)showSureActionMessage:(NSString *)message
{

    [[[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:UMComLocalizedString(@"cancel", @"取消") otherButtonTitles:UMComLocalizedString(@"YES", @"是"), nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (operationType == FeedType) {
            if ([self isPermission_delete_content]) {
                [self deletedFeed:self.feed];
            }else{
                [self hiddenShareListView];
                [self spamFeed:self.feed];
            }
        }else{
            UMComComment  *comment = self.commentTableView.selectedComment;
            if ([self isPermission_delete_content] || [comment.creator.uid isEqualToString:[UMComSession sharedInstance].loginUser.uid]) {
                [self deleteCommentWithCommentId:comment.commentID];
                
            }else{
                [self spamCommentWithCommentId:comment.commentID];
            }
        }
    }
}
- (void)deleteCommentWithCommentId:(NSString *)commentId
{
    [UMComCommentFeedRequest postDeleteWithComment:commentId feedId:self.feed.feedID completion:^(id responseObject, NSError *error) {
        if (!error) {
            int commentCount = [self.feed.comments_count intValue]-1;
            if (commentCount >= 0) {
                 self.feed.comments_count = [NSNumber numberWithInt:commentCount];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:CommentOperationFinish object:self.feed];
            [self refreshFeedsComments:self.feed.feedID];
        }else{
            UMComUser *user = [UMComSession sharedInstance].loginUser;
            if (error.code == 10004 && [user.permissions containsObject:Permission_delete_content]) {
                [user.permissions removeObject:Permission_delete_content];
            }
        }
    }];
}
- (void)spamCommentWithCommentId:(NSString *)commentId
{
    [UMComCommentFeedRequest postSpamWithComment:commentId completion:^(id responseObject, NSError *error) {
        [UMComShowToast spamComment:error];
    }];

}

- (void)spamFeed:(UMComFeed *)feed
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [UMComSpamFeedRequest spamWithFeedId:feed.feedID completion:^(NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        [UMComShowToast spamSuccess:error];
    }];
}
- (void)deletedFeed:(UMComFeed *)feed
{
    if (!feed) {
        return;
    }
    if (feed.isDeleted) {
        [[NSNotificationCenter defaultCenter] postNotificationName:FeedDeletedFinish object:self.feed];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [UMComDeleteFeedRequest deleteWithFeedId:feed.feedID completion:^(NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        feed.status = @(FeedStatusDeleted);
        [self hidenaActionTableView];
        [UMComShowToast deletedFail:error];
        if (!error) {
            [[UMComCoreData sharedInstance].incrementalStore updateObject:feed objectId:feed.feedID handler:^(NSManagedObject *object,NSManagedObjectContext *managedContext) {
                UMComFeed *backingFeedObject = (UMComFeed *)object;
                backingFeedObject.status = @(FeedStatusDeleted);
                [managedContext save:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:FeedDeletedFinish object:self.feed];
                [self.navigationController popViewControllerAnimated:YES];
                
            }];
        }else{
            UMComUser *user = [UMComSession sharedInstance].loginUser;
            if (error.code == 10004 && [user.permissions containsObject:Permission_delete_content]) {
                [user.permissions removeObject:Permission_delete_content];
            }
        }

    }];
}

- (void)hidenaActionTableView
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.actionTableView.frame = CGRectMake(self.actionTableView.frame.origin.x, self.view.window.frame.size.height+64, self.actionTableView.frame.size.width, self.actionTableView.frame.size.height);
        [self.shadowBgView removeFromSuperview];
    } completion:^(BOOL finished) {
        [self.actionTableView removeFromSuperview];
    }];
}

/****************UMComClickActionDelegate**********************************/

#pragma mark - UMComClickActionDelegate
- (void)customObj:(id)obj clickOnUser:(UMComUser *)user
{
    [self turnToUserCenterViewWithUser:user];
}


- (void)customObj:(id)obj clickOnTopic:(UMComTopic *)topic
{
    if (!topic) {
        return;
    }
    UMComTopicFeedViewController *oneFeedViewController = [[UMComTopicFeedViewController alloc] initWithTopic:topic];
    [self.navigationController  pushViewController:oneFeedViewController animated:YES];
}

- (void)customObj:(id)obj clickOnImageView:(UIImageView *)feed complitionBlock:(void (^)(UIViewController *))block
{
    if (block) {
        block(self);
    }
}
- (void)customObj:(id)obj clickOnFeedText:(UMComFeed *)feed
{
    [self.commentEditView dismissAllEditView];
}

- (void)customObj:(id)obj clickOnOriginFeedText:(UMComFeed *)feed
{
    [self.commentEditView dismissAllEditView];
    if (feed.isDeleted || [feed.status intValue] >= FeedStatusDeleted) {
        return;
    }
    [self transitionToFeedDetailViewControllerWithFeed:feed showType:UMComShowFromClickFeedText];
}

- (void)customObj:(id)obj clickOnLikeFeed:(UMComFeed *)feed
{
    __weak typeof(self) weakSelf = self;
    if ([feed.liked boolValue] == YES) {
        [[UMComDisLikeAction action] performActionAfterLogin:feed viewController:self completion:^(NSArray *data, NSError *error) {
            if (!error) {
                weakSelf.feed.liked = @(0);
                weakSelf.feed.likes_count = [NSNumber numberWithInt:[weakSelf.feed.likes_count intValue]-1];
                [weakSelf refreshFeedsLike:weakSelf.feed.feedID];
                [weakSelf reloadLikeImageView:weakSelf.feed];
                [[NSNotificationCenter defaultCenter] postNotificationName:LikeOperationFinish object:weakSelf.feed];
            } else {
                [UMComShowToast deleteLikeFail:error];
            }
        }];
    }else{
        [[UMComLikeAction action] performActionAfterLogin:feed viewController:self completion:^(NSArray *data, NSError *error) {
            if (!error) {
                weakSelf.feed.liked = @(1);
                weakSelf.feed.likes_count = [NSNumber numberWithInt:[weakSelf.feed.likes_count intValue]+1];
                [weakSelf refreshFeedsLike:weakSelf.feed.feedID];
                [weakSelf reloadLikeImageView:weakSelf.feed];
                [[NSNotificationCenter defaultCenter] postNotificationName:LikeOperationFinish object:weakSelf.feed];
            } else {
                [UMComShowToast createLikeFail:error];
            }
        }];
    }
}

- (void)customObj:(id)obj clickOnForward:(UMComFeed *)feed
{
    [self.commentEditView dismissAllEditView];
    if (feed.isDeleted || [feed.status intValue] == 2) {
        return;
    }
    [[UMComAction action] performActionAfterLogin:self.feed viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            UMComEditViewController *editViewController = [[UMComEditViewController alloc] initWithForwardFeed:self.feed];
            UMComNavigationController *editNaviController = [[UMComNavigationController alloc] initWithRootViewController:editViewController];
            [self presentViewController:editNaviController animated:YES completion:nil];
        }
    }];
}

- (void)customObj:(id)obj clickOnComment:(UMComComment *)comment feed:(UMComFeed *)feed
{
    __weak typeof(self) weakSelf = self;

    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        [self.commentEditView dismissAllEditView];
        NSString *title = @"";
        NSString *imageName = @"";
        if ([weakSelf isPermission_delete_content] || [comment.creator.uid isEqualToString:[UMComSession sharedInstance].loginUser.uid]) {
            title = UMComLocalizedString(@"delete", @"删除");
            imageName = @"um_delete";
        } else {
            title = UMComLocalizedString(@"spam", @"举报");
            imageName = @"um_spam";
        }
        [weakSelf showActionTableViewWithImageNameList:[NSArray arrayWithObjects:imageName,@"um_reply", nil] titles:[NSArray arrayWithObjects:title,UMComLocalizedString(@"reply", @"回复"), nil] type:CommentType];
    }];

}

- (void)customObj:(id)obj clikeOnMoreButton:(id)param
{
    UMComLikeUserViewController *likeUserVc = [[UMComLikeUserViewController alloc]init];
    likeUserVc.fetchRequest = self.fetchLikeRequest;
    likeUserVc.feed = self.feed;
    NSMutableArray *userList = [NSMutableArray arrayWithCapacity:1];
    for (UMComLike *like in self.likeListView.likeList) {
        UMComUser *user = like.creator;
        if (user) {
            [userList addObject:user];
        }
    }
    likeUserVc.likeUserList = userList;
    [self.navigationController pushViewController:likeUserVc animated:YES];
}

- (void)customObj:(id)obj clickOnShare:(UMComFeed *)feed
{
    [self.commentEditView dismissAllEditView];
    if (!self.shareListView) {
        self.shareListView = [[UMComShareCollectionView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 120)];
    }
    if (!self.shadowBgView) {
        self.shadowBgView = [self createdShadowBgView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenShareListView)];
        [self.shadowBgView addGestureRecognizer:tap];
    }
    self.shareListView.feed = feed;
    [self showShareCollectionViewWithShareListView:self.shareListView bgView:self.shadowBgView];
}

- (void)customObj:(id)obj clickOnCopy:(UMComFeed *)feed
{
    NSMutableArray *strings = [NSMutableArray arrayWithCapacity:1];
    NSMutableString *string = [[NSMutableString alloc]init];
    if (feed.text) {
        [strings addObject:feed.text];
        [string appendString:feed.text];
    }
    if (feed.origin_feed.text) {
        [strings addObject:feed.origin_feed.text];
        [string appendString:feed.origin_feed.text];
    }
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.strings = strings;
    pboard.string = string;
}

- (void)customObj:(id)obj clickOnAddCollection:(UMComFeed *)feed
{
    __weak typeof(self) weakSelf = self;
    BOOL isFavourite = ![[feed has_collected] boolValue];
    [UMComFavouriteFeedRequest favouriteFeedWithFeedId:feed.feedID isFavourite:isFavourite completion:^(NSError *error) {
        if (!error) {
            if (isFavourite) {
                [feed setHas_collected:@1];
            }else{
                [feed setHas_collected:@0];
            }
        }
        [weakSelf reloadViewsWithFeed:self.feed];
        [UMComShowToast favouriteFeedFail:error isFavourite:isFavourite];
    }];
}


#pragma mark - 显示评论视图
///***************************显示评论视图*********************************/
- (void)showCommentEditViewWithComment:(UMComComment *)comment
{
    if (!self.commentEditView) {
        self.commentEditView = [[UMComCommentEditView alloc]initWithSuperView:self.view];
        __weak typeof(self) weakSelf = self;
        self.commentEditView.SendCommentHandler = ^(NSString *commentText){
            [weakSelf postComment:commentText];
        };
    }
    if (comment) {
        [self.commentEditView presentReplyView:comment];
    }else{
        [self.commentEditView presentEditView];
    }
    if (self.showType == UMComShowFromClickComment) {
        self.showType = UMComShowFromClickDefault;
    }
}

- (void)postComment:(NSString *)content
{
    if (self.showType == UMComShowFromClickComment) {
        self.showType = UMComShowFromClickDefault;
    }
    __weak typeof(self) weakSelf = self;
    [UMComCommentFeedRequest postWithSourceFeedId:self.feed.feedID commentContent:content replyUserId:self.commentTableView.replyUserId completion:^(NSError *error) {
        if (error) {
            [UMComShowToast createCommentFail:error];
        }else{
            weakSelf.feed.comments_count = [NSNumber numberWithInt:[weakSelf.feed.comments_count intValue]+1];
            [weakSelf refreshFeedsComments:weakSelf.feed.feedID];
            [[NSNotificationCenter defaultCenter] postNotificationName:CommentOperationFinish object:weakSelf.feed];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)postFeedCompleteSucceed:(NSNotification *)notification
{
    [self fetchOnFeedFromServer];
}

@end


