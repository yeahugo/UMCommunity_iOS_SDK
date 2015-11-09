//
//  UMComFeedDetailViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 11/13/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComFeedDetailViewController.h"
#import "UMComFeed+UMComManagedObject.h"
#import "UMComPullRequest.h"
#import "UMComCoreData.h"
#import "UMComComment.h"
#import "UMComBarButtonItem.h"
#import "UMComAction.h"
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
#import "UMComLikeListView.h"
#import "UMComUserCenterCollectionView.h"
#import "UMComEditViewController.h"
#import "UMComNavigationController.h"
#import "UMComTopicFeedViewController.h"
#import "UMComCommentEditView.h"
#import "UMComUserCenterViewController.h"
#import "UMComScrollViewDelegate.h"
#import "UMComClickActionDelegate.h"
#import "UMComFeedTableView.h"
#import "UMComFeedsTableViewCell.h"
#import "UMComMutiStyleTextView.h"
#import "UMComRefreshView.h"
#import "UMComUser+UMComManagedObject.h"


typedef enum {
    FeedType = 0,
    CommentType = 1
} OperationType;

typedef void(^LoadFinishBlock)(NSError *error);

static const CGFloat kLikeViewHeight = 30;
#define UMComCommentNamelabelHeght 20
#define UMComCommentTextFont UMComFontNotoSansLightWithSafeSize(15)
#define UMComCommentDeltalWidth 72

@interface UMComFeedDetailViewController ()<UMComClickActionDelegate,UMComRefreshViewDelegate,UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate>

#pragma mark - property
@property (nonatomic, copy) NSString *feedId;

@property (nonatomic, strong) UMComFeed *feed;

@property (nonatomic, copy) NSString *commentId;

@property (nonatomic, strong) UMComPullRequest *fetchLikeRequest;

@property (nonatomic, strong) UMComFeedCommentsRequest *fecthCommentRequest;

@property (nonatomic, strong) UMComFeedStyle *feedStyle;

@property (nonatomic, strong) UMComLikeListView *likeListView;

@property (nonatomic, strong) UMComActionStyleTableView *actionTableView;

@property (nonatomic, strong) UMComShareCollectionView *shareListView;

@property (nonatomic, strong) UMComCommentEditView *commentEditView;

@property (nonatomic, strong) UIView *spaceHiddenView;

@property (nonatomic, strong) NSDictionary * viewExtra;

@property (nonatomic, strong) NSArray *reloadComments;
@property (nonatomic, strong) NSArray *commentStyleViewArray;
@property (nonatomic, strong) UMComComment *selectedComment;
@property (nonatomic, strong) NSString *replyUserId;

@end

@implementation UMComFeedDetailViewController
{
    BOOL isViewDidAppear;
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
    }
    return self;
}

- (id)initWithFeed:(NSString *)feedId
         commentId:(NSString *)commentId
         viewExtra:(NSDictionary *)viewExtra
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postFeedCompleteSucceed:) name:kNotificationPostFeedResultNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedDeletedCompletion:) name:kUMComFeedDeletedFinishNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (isrefreshCommentFinish == YES && self.showType == UMComShowFromClickComment) {
        isrefreshCommentFinish = NO;
        [self showCommentEditViewWithComment:nil];
    }
    CGFloat heigth = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    
    self.menuView.frame = CGRectMake(0, self.view.window.frame.size.height - self.menuView.frame.size.height-heigth, self.view.frame.size.width, self.menuView.frame.size.height);
    isViewDidAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.commentEditView dismissAllEditView];
    isrefreshCommentFinish = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationPostFeedResultNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUMComFeedDeletedFinishNotification object:nil];
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
    
    self.feedsTableView.tableHeaderView = nil;
    UMComRefreshView * refreshView = [[UMComRefreshView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kUMComRefreshOffsetHeight) ScrollView:self.feedsTableView];
    self.feedsTableView.backgroundColor = [UIColor clearColor];
    refreshView.startLocation = 0;
    refreshView.refreshDelegate = self;
    refreshView.headView.lineSpace.hidden = YES;
    [self.view insertSubview:refreshView.headView belowSubview:self.feedsTableView];
    [self.feedsTableView.tableFooterView addSubview:refreshView.footView];
    self.feedsTableView.refreshController = refreshView;
    self.feedsTableView.dataSource = self;
    self.feedsTableView.delegate = self;
    self.feedsTableView.feedType = feedDetailType;
    [self.feedsTableView registerNib:[UINib nibWithNibName:@"UMComCommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"CommentTableViewCell"];
    self.feedsTableView.frame = CGRectMake(0, 0, self.feedsTableView.frame.size.width, self.view.frame.size.height - 40);
    [self creatLineInView:self.feedsTableView];
    
    [self setTitleViewWithTitle:UMComLocalizedString(@"Feed_Detail_Title", @"正文内容")];
    [self setBackButtonWithImage];
    if (self.navigationController.viewControllers.count <= 1) {
        [self setLeftButtonWithImageName:@"Backx" action:@selector(goBack)];
    }
    [self setRightButtonWithImageName:@"um_diandiandian" action:@selector(onClickHandlButton:)];
    
    self.menuView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view bringSubviewToFront:self.menuView];
    
    self.likeListView = [[UMComLikeListView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kLikeViewHeight)];
    self.likeListView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.likeListView.delegate = self;
    
    UMComOneFeedRequest *oneFeedController = [[UMComOneFeedRequest alloc] initWithFeedId:self.feedId viewExtra:self.viewExtra];
    self.fetchFeedsController = oneFeedController;
    
    self.fetchLikeRequest = [[UMComFeedLikesRequest alloc] initWithFeedId:self.feedId count:TotalLikesSize];
    self.fecthCommentRequest = [[UMComFeedCommentsRequest alloc] initWithFeedId:self.feedId order:commentorderByTimeDesc count:BatchSize];
  
    if (self.feed) {
        [self reloadViewsWithFeed];
    }
    [self refreshNewData:nil];
//    self.spaceHiddenView = [[UIView alloc]initWithFrame:CGRectMake(0, self.feedStyle.totalHeight+self.likeListView.frame.size.height, self.feedsTableView.frame.size.width, 6)];
//    self.spaceHiddenView.backgroundColor = [UIColor whiteColor];
//    [self.feedsTableView addSubview:self.spaceHiddenView];
}

#pragma mark - UITableViewDelegate And UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else{
        return self.reloadComments.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString * cellIdentifier = @"FeedsTableViewCell";
        UMComFeedsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self.feedsTableView.clickActionDelegate;
        [cell reloadFeedWithfeedStyle:self.feedStyle tableView:tableView cellForRowAtIndexPath:indexPath];
        if (self.likeListView.superview != cell.contentView) {
            [cell.contentView addSubview:self.likeListView];
        }
        cell.bottomMenuBgView.hidden = YES;
//        self.spaceHiddenView.frame = CGRectMake(0, cell.frame.size.height - 5, self.feedsTableView.frame.size.width, 6);
        return cell;
    }else{
        static NSString *cellID = @"CommentTableViewCell";
        UMComCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UMComComment *comment = nil;
        UMComMutiStyleTextView *styleView = nil;
        if (indexPath.row < self.reloadComments.count) {
            comment = self.reloadComments[indexPath.row];
            styleView = self.commentStyleViewArray[indexPath.row];
        }
        [cell reloadWithComment:comment commentStyleView:styleView];
        __weak typeof(self) weakSelf = self;
        cell.clickOnCommentContent = ^(UMComComment *comment){
            weakSelf.selectedComment = comment;
            weakSelf.replyUserId = comment.creator.uid;
        };
        cell.delegate = self.feedsTableView.clickActionDelegate;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return self.feedStyle.totalHeight + DeltaHeight + 6 + self.likeListView.frame.size.height;
    }else{
        CGFloat commentTextViewHeight = 0;
        if (indexPath.row < self.commentStyleViewArray.count && indexPath.row < self.reloadComments.count) {
            UMComMutiStyleTextView *styleView = self.commentStyleViewArray[indexPath.row];
            commentTextViewHeight = styleView.totalHeight + 12 + 16;
        }
        return commentTextViewHeight;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }else{
        return [self getTableControlView];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }else{
        return 40;
    }
}

- (UIView *)getTableControlView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, kUMComLoadMoreOffsetHeight, self.view.frame.size.width, 40)];
    view.backgroundColor = [UIColor whiteColor];
    UIFont *font = UMComFontNotoSansLightWithSafeSize(14);
    UILabel *commentLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 80, 40)];
    commentLabel.text = [NSString stringWithFormat:@"评论(%@)",self.feed.comments_count];
    commentLabel.font = font;
    commentLabel.textColor = [UMComTools colorWithHexString:FontColorGray];
    [view addSubview:commentLabel];
    
    UILabel *forwardLabel = [[UILabel alloc]initWithFrame:CGRectMake(view.frame.size.width-95, 0, 80, 40)];
    forwardLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    forwardLabel.font = font;
    forwardLabel.textColor = [UIColor lightGrayColor];
    forwardLabel.textAlignment = NSTextAlignmentRight;
    forwardLabel.text = [NSString stringWithFormat:@"转发(%@)",self.feed.forward_count];
    [view addSubview:forwardLabel];
    UIView *bottomLine = [self creatLineInView:view];
    bottomLine.frame = CGRectMake(0, view.frame.size.height-0.3, view.frame.size.width, 0.3);
    return view;
}

- (UIView *)creatLineInView:(UIView *)view
{
    UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.3)];
    bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    bottomLine.backgroundColor = TableViewSeparatorRGBColor;
    [view addSubview:bottomLine];
    return bottomLine;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.commentEditView dismissAllEditView];
    if (scrollView.contentOffset.y > 0) {
        self.feedsTableView.refreshController.headView.hidden = YES;
    }else{
        self.feedsTableView.refreshController.headView.hidden = NO;
    }
    [self.feedsTableView.refreshController refreshScrollViewDidScroll:scrollView haveNextPage:isHaveNextPage];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.feedsTableView.refreshController refreshScrollViewDidEndDragging:scrollView haveNextPage:isHaveNextPage];
}

#pragma mark - UMComRefreshTableViewDelegate

- (void)refreshData:(UMComRefreshView *)refreshView loadingFinishHandler:(RefreshDataLoadFinishHandler)handler
{
    [self refreshNewData:^(NSError *error) {
        if (handler) {
            handler(error);
        }
    }];
}

- (void)loadMoreData:(UMComRefreshView *)refreshView loadingFinishHandler:(RefreshDataLoadFinishHandler)handler
{
    __weak typeof(self) weakSelf = self;
    [self.fecthCommentRequest fetchNextPageFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        isHaveNextPage = haveNextPage;
        if (!error) {
            NSMutableArray *tempData = [NSMutableArray array];
            [tempData addObjectsFromArray:weakSelf.reloadComments];
            [tempData addObjectsFromArray:data];
            [weakSelf reloadCommentTableViewArrWithComments:tempData];
            int commentCount = [weakSelf.feed.comments_count intValue];
            if (commentCount < tempData.count) {
                commentCount = (int)tempData.count;
            }
            weakSelf.feed.comments_count = [NSNumber numberWithInt:commentCount];
            [weakSelf.feedsTableView reloadData];
        }
        if (handler) {
            handler(error);
        }
    }];
}

#pragma mark - private Method

- (void)reloadViewsWithFeed
{
    self.feedStyle = [UMComFeedStyle feedStyleWithFeed:self.feed viewWidth:self.view.frame.size.width feedType:feedDetailType];
    if (self.likeListView.likeList.count > 0) {
        self.likeListView.frame = CGRectMake(0, self.feedStyle.totalHeight+DeltaHeight, self.view.frame.size.width, kLikeViewHeight);
        self.likeListView.hidden = NO;
    }else{
        self.likeListView.frame = CGRectMake(0, self.feedStyle.totalHeight, self.view.frame.size.width, 0);
        self.likeListView.hidden = YES;
    }
    
    [self.feedsTableView reloadData];
    
    CGFloat comtentSizeHeight = self.feedStyle.totalHeight + self.likeListView.frame.size.height + DeltaHeight + self.feedsTableView.frame.size.height;
    if (self.feedsTableView.contentSize.height < comtentSizeHeight && self.reloadComments.count > 0) {
        self.feedsTableView.contentSize = CGSizeMake(self.feedsTableView.contentSize.width, comtentSizeHeight);
        self.feedsTableView.refreshController.footView.hidden = YES;
    }else if (self.reloadComments.count == 0){
        self.feedsTableView.refreshController.footView.hidden = YES;
    }else{
        self.feedsTableView.refreshController.footView.hidden = NO;
    }
}

- (void)refreshNewData:(LoadFinishBlock)block
{
    __weak typeof(self) weakSelf = self;
    [self fetchOnFeedFromServer:^(NSError *error){
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kUMComRemoteNotificationReceivedNotification object:nil];
            [weakSelf reloadLikeImageView:weakSelf.feed];
            [weakSelf refreshFeedsLike:weakSelf.feedId block:^(NSError *error) {
                [weakSelf refreshFeedsComments:weakSelf.feedId block:^(NSError *error) {
                    if (block) {
                        block(nil);
                    }
                }];
            }];
        }else{
            if (block) {
                block(error);
            }
        }
    }];
}

- (void)reloadLikeImageView:(UMComFeed *)feed
{
    if (feed.liked.boolValue) {
        self.likeImageView.image = UMComImageWithImageName(@"um_like+");
        self.likeStatusLabel.text = UMComLocalizedString(@"cancel", @"取消");
    } else {
        self.likeStatusLabel.text = UMComLocalizedString(@"like", @"点赞");
        self.likeImageView.image = UMComImageWithImageName(@"um_like");
    }
}

- (void)fetchOnFeedFromServer:(LoadFinishBlock)block
{
    __weak typeof(self) weakSelf = self;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.fetchFeedsController fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (!error) {
            if ([data isKindOfClass:[NSArray class]] && data.count > 0) {
                weakSelf.feed = data[0];
                [weakSelf reloadViewsWithFeed];
            }
        }else{
            [UMComShowToast showFetchResultTipWithError:error];
        }
        if (block) {
            block(error);
        }
    }];
    
}

- (void)refreshFeedsLike:(NSString *)feedId block:(LoadFinishBlock)block
{
    __weak typeof(self) weakSelf = self;
    
    if (self.feed.likes.count > 0) {
        [self.likeListView reloadViewsWithfeed:self.feed likeArray:self.feed.likes.array];
        [weakSelf reloadViewsWithFeed];
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.fetchLikeRequest fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (!error) {
            [weakSelf.likeListView reloadViewsWithfeed:weakSelf.feed likeArray:data];
        }else{
            [UMComShowToast showFetchResultTipWithError:error];
        }
        [weakSelf reloadViewsWithFeed];
        if (block) {
            block(error);
        }
    }];
}

- (void)refreshFeedsComments:(NSString *)feedId block:(LoadFinishBlock)block
{
    __weak typeof(self) weakSelf = self;
    
    if (self.feed.comments.count > 0) {
        [self reloadCommentTableViewArrWithComments:self.feed.comments.array];
        [self.feedsTableView reloadData];
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.fecthCommentRequest fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        isHaveNextPage = haveNextPage;
        isrefreshCommentFinish = YES;
        if (!error) {
            [weakSelf reloadCommentTableViewArrWithComments:data];
            [weakSelf reloadViewsWithFeed];
        }else{
            [UMComShowToast showFetchResultTipWithError:error];
        }
        if (weakSelf.showType == UMComShowFromClickComment || weakSelf.showType == UMComShowFromClickRemoteNotice) {
            if (isViewDidAppear == YES && weakSelf.showType == UMComShowFromClickComment) {
                if (weakSelf.reloadComments.count > 0) {
                    [weakSelf.feedsTableView setContentOffset:CGPointMake(0, weakSelf.feedStyle.totalHeight+weakSelf.likeListView.frame.size.height+DeltaHeight) animated:NO];
                }
                [weakSelf showCommentEditViewWithComment:nil];
            }
        }
        if (weakSelf.reloadComments.count == 0) {
            [weakSelf.feedsTableView.refreshController.footView hidenVews];
        }
        if (block) {
            block(error);
        }
    }];
}

- (void)reloadCommentTableViewArrWithComments:(NSArray *)reloadComments
{
    NSMutableArray *mutiStyleViewArr = [NSMutableArray array];
    int index = 0;
    for (UMComComment *comment in reloadComments) {
        NSMutableString * replayStr = [NSMutableString stringWithString:@""];
        NSMutableArray *checkWords = nil; //[NSMutableArray arrayWithCapacity:1];
        if (comment.reply_user) {
            [replayStr appendString:@"回复"];
            checkWords = [NSMutableArray arrayWithObject:[NSString stringWithFormat:UserNameString,comment.reply_user.name]];
            [replayStr appendFormat:UserNameString,comment.reply_user.name];
            [replayStr appendFormat:@"："];
        }
        if (comment.content) {
            [replayStr appendFormat:@"%@",comment.content];
        }
        UMComMutiStyleTextView *commentStyleView = [UMComMutiStyleTextView rectDictionaryWithSize:CGSizeMake(self.view.frame.size.width-UMComCommentDeltalWidth, MAXFLOAT) font:UMComCommentTextFont attString:replayStr lineSpace:2 runType:UMComMutiTextRunCommentType checkWords:checkWords];
        float height = commentStyleView.totalHeight + 5/2 + UMComCommentNamelabelHeght;
        commentStyleView.totalHeight  = height;
        [mutiStyleViewArr addObject:commentStyleView];
        index++;
    }
    self.commentStyleViewArray = mutiStyleViewArr;
    self.reloadComments = reloadComments;
}

#pragma mark - button action

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

- (IBAction)didClikeObComment:(UITapGestureRecognizer *)sender
{
    [self.commentEditView dismissAllEditView];
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            [weakSelf showCommentEditViewWithComment:nil];
        }
    }];
}


#pragma mark - showActionView
- (void)onClickHandlButton:(UIButton *)sender
{
    [self.commentEditView dismissAllEditView];
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            NSMutableArray *titles = [NSMutableArray array];
            NSMutableArray *imageNames = [NSMutableArray array];
            NSString *title = UMComLocalizedString(@"spam", @"举报");
            NSString *imageName = @"um_spam";
            if (![self.feed.creator.uid isEqualToString:[UMComSession sharedInstance].uid]) {
                [titles addObject:title];
                [imageNames addObject:imageName];
            }
            if ([weakSelf isPermission_delete_content] || [weakSelf.feed.creator.uid isEqualToString:[UMComSession sharedInstance].uid]) {
                title = UMComLocalizedString(@"delete", @"删除");
                [titles addObject:title];
                imageName = @"um_delete";
                [imageNames addObject:imageName];
            }
            title = UMComLocalizedString(@"copy", @"复制");
            [titles addObject:title];
            imageName = @"um_copy";
            [imageNames addObject:imageName];
            [weakSelf showActionTableViewWithImageNameList:imageNames titles:titles type:FeedType];
        }
    }];
}

- (BOOL)isPermission_delete_content
{
    BOOL isPermission_delete_content = NO;
    UMComUser *user = [UMComSession sharedInstance].loginUser;
    if ([user isPermissionDelete] || [self.feed.creator.uid isEqualToString:user.uid]) {
        isPermission_delete_content = YES;
    }
    return isPermission_delete_content;
}

- (void)showActionTableViewWithImageNameList:(NSArray *)imageNameList titles:(NSArray *)titles type:(OperationType)type
{
    operationType = type;
    if (!self.actionTableView) {
        self.actionTableView = [[UMComActionStyleTableView alloc]initWithFrame:CGRectMake(15, self.view.frame.size.height, self.view.frame.size.width-30, 134) style:UITableViewStylePlain];
    }
    __weak UMComFeedDetailViewController *weakSelf = self;
    self.actionTableView.didSelectedAtIndexPath = ^(NSString *title, NSIndexPath *indexPath){
        if (type == CommentType) {
            [weakSelf handleCommentActionWithTitle:title index:indexPath.row];
        }else if (type == FeedType){
            [weakSelf handleFeedActionWithTitle:title index:indexPath.row];
        }
    };
    [self.actionTableView setImageNameList:imageNameList titles:titles];
    self.actionTableView.feed = self.feed;
    [weakSelf.actionTableView showActionSheet];
}

- (void)handleCommentActionWithTitle:(NSString *)title index:(NSInteger)index
{
    if ([self.actionTableView.selectedTitle isEqualToString:@"回复"]){
        [self showCommentEditViewWithComment:self.selectedComment];
    }else if ([self.actionTableView.selectedTitle isEqualToString:@"删除"]){
        [self showSureActionMessage:UMComLocalizedString(@"sure to deleted comment", @"确定要删除这条评论？")];
    }else if ([self.actionTableView.selectedTitle isEqualToString:@"举报"]){
        [self showSureActionMessage:UMComLocalizedString(@"sure to spam comment", @"确定要举报这条评论？")];
    }
}

- (void)handleFeedActionWithTitle:(NSString *)title index:(NSInteger)index
{
    if ([self.actionTableView.selectedTitle isEqualToString:@"复制"]) {
        [self customObj:nil clickOnCopy:self.feed];
    }else if ([self.actionTableView.selectedTitle isEqualToString:@"删除"]){
        [self showSureActionMessage:UMComLocalizedString(@"sure to deleted comment", @"确定要删除这条消息？")];
    }else if ([self.actionTableView.selectedTitle isEqualToString:@"举报"]){
        [self showSureActionMessage:UMComLocalizedString(@"sure to spam comment", @"确定要举报这条消息？")];
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
            if ([self.actionTableView.selectedTitle isEqualToString:@"删除"]) {
                [self deletedFeed:self.feed];
            }else if ([self.actionTableView.selectedTitle isEqualToString:@"举报"]){
                [self spamFeed:self.feed];
            }
        }else{
            if ([self.actionTableView.selectedTitle isEqualToString:@"删除"]) {
                [self deleteComment];
            }else if ([self.actionTableView.selectedTitle isEqualToString:@"举报"]){
                [self spamComment];
                
            }
        }
    }
}

- (void)deleteComment
{
    [UMComPushRequest deleteWithComment:self.selectedComment feed:self.feed completion:^(id responseObject, NSError *error) {
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kUMComCommentOperationFinishNotification object:self.feed];
            [self refreshFeedsComments:self.feed.feedID block:nil];
        }
    }];
}

- (void)spamComment
{
    [UMComPushRequest spamWithComment:self.selectedComment completion:^(id responseObject, NSError *error) {
        [UMComShowToast spamComment:error];
    }];
    
}

- (void)spamFeed:(UMComFeed *)feed
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [UMComPushRequest spamWithFeed:feed completion:^(NSError *error) {
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
        [[NSNotificationCenter defaultCenter] postNotificationName:kUMComFeedDeletedFinishNotification object:self.feed];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [UMComPushRequest deleteWithFeed:feed completion:^(NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (!error) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:kUMComFeedDeletedFinishNotification object:feed];
//            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [UMComShowToast showFetchResultTipWithError:error];
        }
    }];
}

/****************UMComClickActionDelegate**********************************/

#pragma mark - UMComClickActionDelegate

- (void)customObj:(id)obj clickOnFeedText:(UMComFeed *)feed
{
    [self.commentEditView dismissAllEditView];
}

- (void)customObj:(id)obj clickOnLikeFeed:(UMComFeed *)feed
{
    __weak typeof(self) weakSelf = self;
    if ([feed.status intValue] >= FeedStatusDeleted) {
        return;
    }
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        
        [UMComPushRequest likeWithFeed:feed isLike:![feed.liked boolValue] completion:^(id responseObject, NSError *error) {
            if (error) {
                [UMComShowToast showFetchResultTipWithError:error];
            }
            [weakSelf refreshFeedsLike:feed.feedID block:nil];
            [weakSelf reloadLikeImageView:feed];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUMComLikeOperationFinishNotification object:feed];
        }];
    }];
}


- (void)customObj:(id)obj clickOnComment:(UMComComment *)comment feed:(UMComFeed *)feed
{
    
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        [self.commentEditView dismissAllEditView];
        NSMutableArray *titles = [NSMutableArray array];
        NSMutableArray *imageNames = [NSMutableArray array];
        NSString *title = UMComLocalizedString(@"spam", @"举报");
        NSString *imageName = @"um_spam";
        if (![comment.creator.uid isEqualToString:[UMComSession sharedInstance].uid]) {
            [titles addObject:title];
            [imageNames addObject:imageName];
        }
        if ([weakSelf isPermission_delete_content] || [comment.creator.uid isEqualToString:[UMComSession sharedInstance].loginUser.uid]) {
            title = UMComLocalizedString(@"delete", @"删除");
            [titles addObject:title];
            imageName = @"um_delete";
            [imageNames addObject:imageName];
        }
        title = UMComLocalizedString(@"reply", @"回复");
        [titles addObject:title];
        imageName = @"um_reply";
        [imageNames addObject:imageName];
        [self showActionTableViewWithImageNameList:imageNames titles:titles type:CommentType];
    }];
    
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet;
{
    UIImageView *imageView = [[UIImageView alloc]initWithImage:UMComImageWithImageName(@"spam")];
    [actionSheet addSubview:imageView];
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

- (void)customObj:(id)obj clickOnFavouratesFeed:(UMComFeed *)feed
{
    __weak typeof(self) weakSelf = self;
    BOOL isFavourite = ![[feed has_collected] boolValue];
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        [UMComPushRequest favouriteFeedWithFeed:feed
                                    isFavourite:isFavourite
                                     completion:^(NSError *error) {
                                        [UMComShowToast favouriteFeedFail:error isFavourite:isFavourite];
                                        [[NSNotificationCenter defaultCenter] postNotificationName:kUMComFavouratesFeedOperationFinishNotification object:weakSelf.feed];
                                        [weakSelf reloadViewsWithFeed];
        }];
    }];
}

- (void)customObj:(id)obj clickOnLikeComment:(UMComComment *)comment
{
    __weak typeof(self) weakSelf = self;
   __weak UMComCommentTableViewCell *cell = (UMComCommentTableViewCell *)obj;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        [UMComPushRequest likeWithComment:comment
                                   isLike:![comment.liked boolValue]
                               completion:^(id responseObject, NSError *error) {
                                   if (error.code == ERR_CODE_FEED_COMMENT_UNAVAILABLE) {
                                       [UMComShowToast showFetchResultTipWithError:error];
                                       [self refreshNewData:nil];
                                   }else{
                                       NSIndexPath *indexPath = [weakSelf.feedsTableView indexPathForCell:cell];
                                       [weakSelf.feedsTableView reloadRowAtIndex:indexPath];
                                   }
                                 
                               }];
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
            if (commentText == nil || commentText.length == 0) {
                [[[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"Sorry",@"抱歉") message:UMComLocalizedString(@"Empty_Text",@"内容不能为空") delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK",@"好") otherButtonTitles:nil] show];
            }
            if ([UMComTools getStringLengthWithString:commentText] > kCommentLenght) {
                NSString *chContent = [NSString stringWithFormat:@"评论内容不能超过%d个字符",(int)kCommentLenght];
                NSString *key = [NSString stringWithFormat:@"Content must not exceed %d characters",(int)kCommentLenght];
                [[[UIAlertView alloc]
                  initWithTitle:UMComLocalizedString(@"Sorry",@"抱歉") message:UMComLocalizedString(key,chContent) delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK",@"好") otherButtonTitles:nil] show];
            }
            
            [weakSelf postComment:commentText];
        };
    }
    if (comment) {
        [self.commentEditView presentReplyView:comment];
    }else{
        self.replyUserId = nil;
        [self.commentEditView presentEditView];
    }
    if (self.showType == UMComShowFromClickComment) {
        self.showType = UMComShowFromClickDefault;
    }
}

- (void)postComment:(NSString *)content
{
    __weak typeof(self) weakSelf = self;
    UMComUser *replyUser = nil;
    if (self.replyUserId) {
        replyUser = self.selectedComment.creator;
    }
    [UMComPushRequest postWithSourceFeed:self.feed
                          commentContent:content
                               replyUser:replyUser
                    commentCustomContent:nil
                                  images:nil
                              completion:^(NSError *error) {
        if (error) {
            if (error.code == ERR_CODE_FEED_COMMENT_UNAVAILABLE) {
                [UMComShowToast showFetchResultTipWithError:error];
                [self refreshNewData:nil];
            }
            [UMComShowToast showFetchResultTipWithError:error];
        }else{
            [weakSelf refreshFeedsComments:weakSelf.feed.feedID block:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUMComCommentOperationFinishNotification object:weakSelf.feed];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)postFeedCompleteSucceed:(NSNotification *)notification
{
    [self fetchOnFeedFromServer:nil];
}

- (void)feedDeletedCompletion:(NSNotification *)notification
{
    UMComFeed *feed = notification.object;
    if ([feed isKindOfClass:[UMComFeed class]] && [feed.feedID isEqualToString:self.feed.feedID]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end


