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

typedef enum {
    FeedType = 0,
    CommentType = 1
} OperationType;

//评论内容长度
//#define kCommentLenght 140

static const CGFloat kLikeViewHeight = 30;
static const CGFloat kCommentLenght = 140;
static const NSString * Permission_delete_content = @"permission_delete_content";

@interface UMComFeedDetailViewController ()<UITextFieldDelegate, UMComClickActionDelegate, UMComClickActionDelegate,UIScrollViewDelegate,UIAlertViewDelegate>

#pragma mark - property
@property (nonatomic, copy) NSString *feedId;

@property (nonatomic, strong) UMComFeed *feed;

@property (nonatomic, copy) NSString *commentId;

@property (nonatomic, strong) UMComPullRequest *fetchFeedsController;

@property (nonatomic, strong) UMComPullRequest *fetchLikeRequest;

@property (nonatomic, strong) UMComFeedCommentsRequest *fecthCommentRequest;

@property (nonatomic, strong) UMComFeedStyle *feedStyle;


@property (nonatomic, strong) UIView * commentInputView;

@property (nonatomic, strong) UITextField *commentTextField;

@property (nonatomic, strong) UILabel *noticeLabel;

@property (nonatomic, strong) UMComFeedContentView *feedContentView;
@property (nonatomic, strong) UMComLikeListView *likeListView;
@property (nonatomic, strong) UMComCommentTableView *commentTableView;
@property (nonatomic, strong) UIView *feedDetaiView;

@property (nonatomic, strong) UIScrollView *mainScrollView;

@property (nonatomic, strong) UMComActionStyleTableView *actionTableView;

@property (nonatomic, strong) UMComShareCollectionView *shareListView;

@property (nonatomic, strong) UIView *shadowBgView;

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

- (id)initWithFeed:(NSString *)feedId commentId:(NSString *)commentId
{
    self = [self initWithFeed:nil];
    if (self) {
        self.feedId = feedId;
        self.commentId = commentId;
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
    UMComOneFeedRequest *oneFeedController = [[UMComOneFeedRequest alloc] initWithFeedId:self.feedId];
    self.fetchFeedsController = oneFeedController;
    
}

- (void)fetchOnFeedFromServer
{
    if (!self.fetchFeedsController) {
        [self getFetchedResultsController];
    }
    [self.fetchFeedsController fetchRequestFromCoreData:^(NSArray *data, NSError *error) {
        if ([data isKindOfClass:[NSArray class]] && data.count > 0) {
            self.feed = data[0];
            [self reloadViewsWithFeed:self.feed];
        }
        [self.fetchFeedsController fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            if ([data isKindOfClass:[NSArray class]] && data.count > 0) {
                self.feed = data[0];
                [self reloadViewsWithFeed:self.feed];
            }
            [self refreshFeedsLike:self.feed.feedID];
            [self refreshFeedsComments:self.feed.feedID];

        }];
    }];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
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
        [self presentEditView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self dismissAllEditView];
    [self.menuView removeFromSuperview];
    isrefreshLikeFinish = NO;
    isrefreshCommentFinish = NO;
    self.showType = UMComShowFromClickDefault;
    [self.shadowBgView removeFromSuperview];
    [self.actionTableView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:kNotificationPostFeedResult name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self setTitleViewWithTitle:UMComLocalizedString(@"Feed_Detail_Title", @"正文内容")];
    [self setBackButtonWithImage];
    if (self.navigationController.viewControllers.count <= 1) {
        [self setLeftButtonWithImageName:@"Backx" action:@selector(goBack)];
    }
    [self setRightButtonWithImageName:@"um_diandiandian" action:@selector(onClickHandlButton:)];
    self.mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40)];
    self.mainScrollView.scrollsToTop = YES;
    self.mainScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mainScrollView];

    
    NSArray *feedDetailView = [[NSBundle mainBundle]loadNibNamed:@"UMComFeedContentView" owner:self options:nil];
    if (feedDetailView.count > 0) {
        self.feedContentView = [feedDetailView objectAtIndex:0];
    }
    self.feedContentView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.feedContentView.delegate = self;
    self.feedDetaiView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 330)];
    [self.feedDetaiView addSubview:self.feedContentView];
    [self.mainScrollView addSubview:self.feedDetaiView];
    self.feedDetaiView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    self.commentTableView = [[UMComCommentTableView alloc]initWithFrame:CGRectMake(0,self.tableControlView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-40) style:UITableViewStylePlain];
    self.commentTableView.scrollEnabled = NO;
    self.commentTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.commentTableView.clickActionDelegate = self;
    
    self.mainScrollView.delegate = self;
    [self.mainScrollView addSubview:self.commentTableView];

    [self creatCommentTextField];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAllEditView)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
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
    [self.feedContentView reloadDetaiViewWithFeedStyle:self.feedStyle viewWidth:self.mainScrollView.frame.size.width];

    if (self.likeListView.likeList.count > 0) {
        self.likeListView.frame = CGRectMake(0, self.feedStyle.totalHeight+10, self.mainScrollView.frame.size.width, kLikeViewHeight);
        self.likeListView.hidden = NO;
    }else{
        self.likeListView.frame = CGRectMake(0, self.feedStyle.totalHeight, self.mainScrollView.frame.size.width, 0);
        self.likeListView.hidden = YES;
    }
    self.feedDetaiView.frame = CGRectMake(0, 0, self.mainScrollView.frame.size.width, self.feedStyle.totalHeight+ DeltaHeight+self.likeListView.frame.size.height);
    
    [self.forwarTitleLabel setText:[NSString stringWithFormat:@"转发(%d)",[self.feed.forward_count intValue]] ];
    [self.commentTitleLabel setText:[NSString stringWithFormat:@"评论(%d)",[self.feed.comments_count intValue]]];
    
    self.commentTableView.frame = CGRectMake(0, self.feedDetaiView.frame.size.height+self.tableControlView.frame.size.height, self.mainScrollView.frame.size.width, self.commentTableView.contentSize.height);
    CGFloat contenSizeH = self.feedDetaiView.frame.size.height + self.view.frame.size.height - self.menuView.frame.size.height + self.tableControlView.frame.size.height;
    if (contenSizeH< self.feedDetaiView.frame.size.height + self.commentTableView.frame.size.height+self.tableControlView.frame.size.height) {
        contenSizeH = self.feedDetaiView.frame.size.height + self.commentTableView.frame.size.height+self.tableControlView.frame.size.height;
    }
    self.mainScrollView.contentSize = CGSizeMake(self.mainScrollView.frame.size.width, contenSizeH);
    [self scrollViewDidScroll:self.mainScrollView];
    if (self.showType == UMComShowFromClickComment || self.showType == UMComShowFromClickRemoteNotice) {
        if (self.commentTableView.reloadComments.count > 0) {
            [self.mainScrollView setContentOffset:CGPointMake(self.mainScrollView.contentOffset.x, self.feedDetaiView.frame.size.height+1) animated:NO];
        }
        if (isViewDidAppear == YES ) {
            [self presentEditView];
        }
    }
}



- (void)refreshFeedsLike:(NSString *)feedId
{
    if (!self.fetchLikeRequest) {
         UMComFeedLikesRequest *feedLikesController = [[UMComFeedLikesRequest alloc] initWithFeedId:feedId count:TotalLikesSize];
        self.fetchLikeRequest = feedLikesController;
    }

    [self.fetchLikeRequest fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        if (!error) {
            if (!self.likeListView) {
                self.likeListView = [[UMComLikeListView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kLikeViewHeight)];
                self.likeListView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                [self.feedDetaiView addSubview:self.likeListView];
                self.likeListView.delegate = self;
            }
            [self.likeListView reloadViewsWithfeed:self.feed likeArray:data];
        }
        isrefreshLikeFinish = YES;
        [self reloadViewsWithFeed:self.feed];

    }];
}

- (void)refreshFeedsComments:(NSString *)feedId
{
    if (!self.fecthCommentRequest) {
        self.fecthCommentRequest = [[UMComFeedCommentsRequest alloc] initWithFeedId:feedId order:commentorderByTimeAsc count:BatchSize];
        
    }
    [self.fecthCommentRequest fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        isHaveNextPage = haveNextPage;
        isrefreshCommentFinish = YES;
        if (!error) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.commentTableView reloadCommentTableViewArrWithComments:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    int commentCount = [self.feed.comments_count intValue];
                    if (commentCount < data.count) {
                        commentCount = (int)data.count;
                    }
                    self.feed.comments_count = [NSNumber numberWithInt:commentCount];
                    [self.commentTableView reloadData];
                    [self reloadViewsWithFeed:self.feed];
                });
            });
        }
    }];
}


- (IBAction)didClickOnLike:(UITapGestureRecognizer *)sender {
    [self dismissAllEditView];
    [self customObj:nil clickOnLikeFeed:self.feed];
}

- (IBAction)didClickOnForward:(UITapGestureRecognizer *)sender {
    [[UMComForwardAction action] performActionAfterLogin:self.feed viewController:self completion:nil];
}

- (IBAction)didClikeObComment:(UITapGestureRecognizer *)sender {
    [self dismissAllEditView];
    [[UMComCommentOperationAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            [self presentEditView];    
        }
    }];
}

- (void)turnToUserCenterViewWithUser:(UMComUser *)user
{
    [[UMComUserCenterAction action] performActionAfterLogin:user viewController:self completion:nil];
}

- (IBAction)didClickOnCommentTitleButton:(UIButton *)sender {
    
    [self refreshFeedsComments:self.feed.feedID];
}

#pragma mark - UISCrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self dismissAllEditView];
    if (scrollView.contentOffset.y < self.feedDetaiView.frame.size.height) {
        self.tableControlView.frame = CGRectMake(self.tableControlView.frame.origin.x,self.feedDetaiView.frame.size.height-scrollView.contentOffset.y, self.tableControlView.frame.size.width, self.tableControlView.frame.size.height);
    }else if (scrollView.contentOffset.y >= self.feedDetaiView.frame.size.height) {
        self.tableControlView.frame = CGRectMake(self.tableControlView.frame.origin.x, 0, self.tableControlView.frame.size.width, self.tableControlView.frame.size.height);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat offset = scrollView.contentOffset.y;
    if (offset > 0 && scrollView.contentOffset.y > scrollView.contentSize.height - (scrollView.frame.size.height - 65)){
        [[UMComCommentOperationAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
            [self.fecthCommentRequest fetchNextPageFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
                if (!error) {
                    isHaveNextPage = haveNextPage;
                    NSMutableArray *tempData = [NSMutableArray array];
                    [tempData addObjectsFromArray:self.commentTableView.reloadComments];
                    [tempData addObjectsFromArray:data];
                    [self.commentTableView reloadCommentTableViewArrWithComments:tempData];
                    int commentCount = [self.feed.comments_count intValue];
                    if (commentCount < tempData.count) {
                        commentCount = (int)tempData.count;
                    }
                    self.showType = UMComShowFromClickDefault;
                    self.feed.comments_count = [NSNumber numberWithInt:commentCount];
                    [self.commentTableView reloadData];
                    [self reloadViewsWithFeed:self.feed];
                }
            }];
        }];
    }
}

#pragma mark - showActionView
- (void)onClickHandlButton:(UIButton *)sender
{
    [self dismissAllEditView];
    
    [[UMComFeedOperationAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        NSString *title = @"";
        NSString *imageName = @"";
        if ([self isPermission_delete_content]) {
            title = UMComLocalizedString(@"delete", @"删除");
            imageName = @"um_delete";
        } else {
            title = UMComLocalizedString(@"spam", @"举报");
            imageName = @"um_spam";
        }
        [self showActionTableViewWithImageNameList:[NSArray arrayWithObjects:imageName,@"um_copy", nil] titles:[NSArray arrayWithObjects:title,UMComLocalizedString(@"copy", @"复制"), nil] type:FeedType];
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
    if (indexPath.row != 1 && indexPath.row != 3) {
        if (type == FeedType) {
            [self dealWithFeedActionWithIndex:indexPath.row];
        }else if (type == CommentType){
            [self dealWithCommentActionWithIndex:indexPath.row];
        }
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
    }else if (index == 2){
        [self presentReplyView:self.commentTableView.selectedComment];
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
    }else if (index == 2){
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
    [[UMComTopicFeedAction action] performActionAfterLogin:topic viewController:self completion:nil];
}

- (void)customObj:(id)obj clickOnImageView:(UIImageView *)feed complitionBlock:(void (^)(UIViewController *))block
{
    if (block) {
        block(self);
    }
}
- (void)customObj:(id)obj clickOnFeedText:(UMComFeed *)feed
{
    if ([self.commentTextField becomeFirstResponder]) {
        [self dismissAllEditView];
    }
}

- (void)customObj:(id)obj clickOnOriginFeedText:(UMComFeed *)feed
{
    if (feed.isDeleted || [feed.status intValue] >= FeedStatusDeleted) {
        return;
    }
    [self transitionToFeedDetailViewControllerWithFeed:feed showType:UMComShowFromClickFeedText];
}

- (void)customObj:(id)obj clickOnLikeFeed:(UMComFeed *)feed
{
    if ([feed.liked boolValue] == YES) {
        [[UMComDisLikeAction action] performActionAfterLogin:feed viewController:self completion:^(NSArray *data, NSError *error) {
            if (!error) {
                self.feed.liked = @(0);
                self.feed.likes_count = [NSNumber numberWithInt:[self.feed.likes_count intValue]-1];
                [self refreshFeedsLike:self.feed.feedID];
                [self reloadLikeImageView:self.feed];
                [[NSNotificationCenter defaultCenter] postNotificationName:LikeOperationFinish object:self.feed];
            } else {
                [UMComShowToast deleteLikeFail:error];
            }
        }];
    }else{
        [[UMComLikeAction action] performActionAfterLogin:feed viewController:self completion:^(NSArray *data, NSError *error) {
            if (!error) {
                self.feed.liked = @(1);
                self.feed.likes_count = [NSNumber numberWithInt:[self.feed.likes_count intValue]+1];
                [self refreshFeedsLike:self.feed.feedID];
                [self reloadLikeImageView:self.feed];
                [[NSNotificationCenter defaultCenter] postNotificationName:LikeOperationFinish object:self.feed];
            } else {
                [UMComShowToast createLikeFail:error];
            }
        }];
    }
}

- (void)customObj:(id)obj clickOnForward:(UMComFeed *)feed
{
    if ([self.commentTextField becomeFirstResponder]) {
        [self.commentTextField resignFirstResponder];
        return;
    }
    if (feed.isDeleted || [feed.status intValue] == 2) {
        return;
    }
    [[UMComForwardAction action] performActionAfterLogin:feed viewController:self completion:nil];
}

- (void)customObj:(id)obj clickOnComment:(UMComComment *)comment feed:(UMComFeed *)feed
{
    [[UMComCommentOperationAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if (self.commentTextField.hidden == NO) {
            [self dismissAllEditView];
            return;
        }
        NSString *title = @"";
        NSString *imageName = @"";
        if ([self isPermission_delete_content] || [comment.creator.uid isEqualToString:[UMComSession sharedInstance].loginUser.uid]) {
            title = UMComLocalizedString(@"delete", @"删除");
            imageName = @"um_delete";
        } else {
            title = UMComLocalizedString(@"spam", @"举报");
            imageName = @"um_spam";
        }
        [self showActionTableViewWithImageNameList:[NSArray arrayWithObjects:imageName,@"um_reply", nil] titles:[NSArray arrayWithObjects:title,UMComLocalizedString(@"reply", @"回复"), nil] type:CommentType];
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
    [self dismissAllEditView];   
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

- (void)hiddenShareListView
{
    [self hidenaActionTableView];
    [self hidenShareListView:self.shareListView bgView:self.shadowBgView];
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




#pragma mark - 显示评论视图
/***************************显示评论视图*********************************/

- (void)creatCommentTextField
{
    NSArray *commentInputNibs = [[NSBundle mainBundle]loadNibNamed:@"UMComCommentInput" owner:self options:nil];
    //得到第一个UIView
    UIView *commentInputView = [commentInputNibs objectAtIndex:0];
    self.commentInputView = commentInputView;
    [self.commentInputView addSubview:[self creatSpaceLineWithWidth:self.view.frame.size.width]];
    self.commentTextField = [commentInputView.subviews objectAtIndex:0];
    self.commentTextField.delegate = self;
    self.commentInputView.hidden = YES;
    self.commentTextField.hidden = YES;
    self.commentTextField.delegate = self;
    self.commentTextField.frame = CGRectMake(self.commentTextField.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width-2*self.commentTextField.frame.origin.x, self.commentTextField.frame.size.height);
    self.commentInputView.frame = CGRectMake(0,  self.view.frame.size.height, self.view.frame.size.width, self.commentInputView.frame.size.height);
    [self.view addSubview:self.commentInputView];
    [self.view addSubview:self.commentTextField];
}

- (UIView *)creatSpaceLineWithWidth:(CGFloat)width
{
    UIView *spaceLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 0.3)];
    spaceLine.backgroundColor = TableViewSeparatorRGBColor;
    spaceLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    return spaceLine;
}
-(void)presentEditView
{
    self.commentTextField.text = @"";
    [self.commentTextField becomeFirstResponder];
    NSString *chContent = [NSString stringWithFormat:@"评论内容不能超过%d个字符",140];
    NSString *key = [NSString stringWithFormat:@"Content must not exceed %d characters",140];
    self.commentTextField.placeholder = UMComLocalizedString(key,chContent);
    self.commentTextField.hidden = NO;
    self.commentInputView.hidden = NO;
    self.commentTableView.replyUserId = nil;
}

- (void)dismissAllEditView
{
    self.commentTextField.hidden = YES;
    self.commentInputView.hidden = YES;
    [self.commentTextField resignFirstResponder];
}


- (void)presentReplyView:(UMComComment *)comment;
{
    self.commentTextField.text = @"";
    self.commentTextField.placeholder = [NSString stringWithFormat:@"回复%@",[[comment creator] name]];
    self.commentTextField.hidden = NO;
    self.commentInputView.hidden = NO;
    [self.commentTextField becomeFirstResponder];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if (textField.text == nil || textField.text.length == 0) {
        [[[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"Sorry",@"抱歉") message:UMComLocalizedString(@"Empty_Text",@"内容不能为空") delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK",@"好") otherButtonTitles:nil] show];
        return NO;
    }
    if (textField.text.length > kCommentLenght) {
        NSString *chContent = [NSString stringWithFormat:@"评论内容不能超过%d个字符",(int)kCommentLenght];
        NSString *key = [NSString stringWithFormat:@"Content must not exceed %d characters",(int)kCommentLenght];
        [[[UIAlertView alloc]
          initWithTitle:UMComLocalizedString(@"Sorry",@"抱歉") message:UMComLocalizedString(key,chContent) delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK",@"好") otherButtonTitles:nil] show];
        return NO;
    }
    [self postComment:textField.text];
    [self dismissAllEditView];
    return YES;
}


- (void)postComment:(NSString *)content
{
    self.showType = UMComShowFromClickDefault;
    [UMComCommentFeedRequest postWithSourceFeedId:self.feed.feedID commentContent:content replyUserId:self.commentTableView.replyUserId completion:^(NSError *error) {
        if (error) {
            [UMComShowToast createCommentFail:error];
        }else{
            self.feed.comments_count = [NSNumber numberWithInt:[self.feed.comments_count intValue]+1];
            [self refreshFeedsComments:self.feed.feedID];
            [[NSNotificationCenter defaultCenter] postNotificationName:CommentOperationFinish object:self.feed];
        }
    }];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length != 0 && textField.text.length >= kCommentLenght) {
        if (!self.noticeLabel) {
            self.noticeLabel = [[UILabel alloc]initWithFrame:textField.frame];
            [textField.superview addSubview:self.noticeLabel];
            self.noticeLabel.text = [NSString stringWithFormat:@"评论内容不能超过%d个字符",(int)kCommentLenght];
            self.noticeLabel.backgroundColor = [UIColor clearColor];
            self.noticeLabel.textAlignment = NSTextAlignmentCenter;
        }
        string=nil;
        self.noticeLabel.hidden = NO;
        self.commentTextField.hidden = YES;
        [self performSelector:@selector(hidenNoticeLabel) withObject:nil afterDelay:0.8f];
        return NO;
    }
    return YES;
}

- (void)hidenNoticeLabel
{
    self.noticeLabel.hidden = YES;
    self.commentTextField.hidden = NO;
}

- (void)keyboardWillShow:(NSNotification*)notification {
    [self.view bringSubviewToFront:self.commentInputView];
    [self.view bringSubviewToFront:self.commentTextField];
    CGRect  keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.commentInputView.center = CGPointMake(self.view.frame.size.width/2, keyBoardFrame.origin.y - self.commentInputView.frame.size.height-41.5);
    self.commentTextField.center = self.commentInputView.center;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)postFeedCompleteSucceed:(NSNotification *)notification
{
    
    [self fetchOnFeedFromServer];

}

@end


