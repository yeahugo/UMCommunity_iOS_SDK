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
#import "UMComEditViewController.h"
#import "UMComNavigationController.h"
#import "UMComTopicFeedViewController.h"
#import "UMComCommentEditView.h"
#import "UMComUserCenterViewController.h"
#import "UMComScrollViewDelegate.h"
#import "UMComClickActionDelegate.h"
#import "UMComFeedsTableViewCell.h"
#import "UMComMutiStyleTextView.h"
#import "UMComRefreshView.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComNearbyFeedViewController.h"
#import "UMComWebViewController.h"


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

@property (nonatomic, strong) UMComFeedStyle *feedStyle;

@property (nonatomic, strong) UMComLikeListView *likeListView;

@property (nonatomic, strong) UMComActionStyleTableView *actionTableView;

@property (nonatomic, strong) UMComShareCollectionView *shareListView;

@property (nonatomic, strong) UMComCommentEditView *commentEditView;

@property (nonatomic, strong) NSDictionary * viewExtra;

@property (nonatomic, strong) NSArray *reloadComments;
@property (nonatomic, strong) NSArray *commentStyleViewArray;

@property (nonatomic, strong) UMComComment *selectedComment;
@property (nonatomic, strong) NSString *replyUserId;

@property (nonatomic, strong) UMComOneFeedRequest *fetchFeedsController;

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
    self = [super init];
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
    isViewDidAppear = YES;
    
    if (self.menuView.superview != [UIApplication sharedApplication].keyWindow) {
        [[UIApplication sharedApplication].keyWindow addSubview:self.menuView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.menuView removeFromSuperview];
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
    [self.tableView registerNib:[UINib nibWithNibName:@"UMComFeedsTableViewCell" bundle:nil] forCellReuseIdentifier:@"UMComFeedsTableViewCell"];
     [self.tableView registerNib:[UINib nibWithNibName:@"UMComCommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"UMComCommentTableViewCell"];
    
    [self setTitleViewWithTitle:UMComLocalizedString(@"Feed_Detail_Title", @"正文内容")];
    [self setBackButtonWithImage];
    if (self.navigationController.viewControllers.count <= 1) {
        [self setLeftButtonWithImageName:@"Backx" action:@selector(goBack)];
    }
    [self setRightButtonWithImageName:@"um_diandiandian" action:@selector(onClickHandlButton:)];
    
    self.likeListView = [[UMComLikeListView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kLikeViewHeight)];
    self.likeListView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.likeListView.delegate = self;
    
    UMComOneFeedRequest *oneFeedController = [[UMComOneFeedRequest alloc] initWithFeedId:self.feedId viewExtra:self.viewExtra];
    self.fetchFeedsController = oneFeedController;
    
    self.fetchLikeRequest = [[UMComFeedLikesRequest alloc] initWithFeedId:self.feedId count:TotalLikesSize];
    self.fetchRequest = [[UMComFeedCommentsRequest alloc] initWithFeedId:self.feedId commentUserId:nil order:commentorderByTimeDesc count:BatchSize];
  
    if (self.feed) {
        [self reloadViewsWithFeed];
    }
    [self refreshNewData:nil];
    
    [self createMuneView];
}

#pragma mark - UITableViewDelegate And UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (section == 0) {
        count = 1;
    }else{
        count = self.reloadComments.count;
        if (count > 0) {
            if (count >= 20) {
                self.loadMoreStatusView.hidden = NO;
                if (!self.haveNextPage) {
                    [self.loadMoreStatusView setLoadStatus:UMComFinish];
                }
            }else{
                self.loadMoreStatusView.hidden = YES;
            }
            self.noDataTipLabel.hidden = YES;
        }else{
            self.loadMoreStatusView.hidden = YES;
            self.noDataTipLabel.hidden = YES;
        }
    }
    return count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString * cellIdentifier = @"UMComFeedsTableViewCell";
        UMComFeedsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        [cell reloadFeedWithfeedStyle:self.feedStyle tableView:tableView cellForRowAtIndexPath:indexPath];
        if (self.likeListView.superview != cell.contentView) {
            [cell.contentView addSubview:self.likeListView];
        }
        cell.bottomMenuBgView.hidden = YES;
        return cell;
    }else{
        static NSString *cellID = @"UMComCommentTableViewCell";
        UMComCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UMComComment *comment = nil;
        UMComMutiText *mutiText = nil;
        if (indexPath.row < self.reloadComments.count) {
            comment = self.reloadComments[indexPath.row];
            mutiText = self.commentStyleViewArray[indexPath.row];
        }
        [cell reloadWithComment:comment commentStyleView:mutiText];
        __weak typeof(self) weakSelf = self;
        cell.clickOnCommentContent = ^(UMComComment *comment){
            weakSelf.selectedComment = comment;
            weakSelf.replyUserId = comment.creator.uid;
        };
        cell.delegate = self;
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
            UMComMutiText *mutiText = self.commentStyleViewArray[indexPath.row];
            commentTextViewHeight = mutiText.textSize.height + 12 + 16;
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

#pragma mark - UMComRefreshTableViewDelegate

- (void)refreshData
{
    [self refreshNewData:nil];
}

#pragma mark - data handle

- (void)handleCoreDataDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        self.dataArray = data;
        __weak typeof(self) weakSelf = self;
        [weakSelf reloadCommentTableViewArrWithComments:data completion:^{
            [weakSelf reloadViewsWithFeed];
        }];
    }
    if (finishHandler) {
        finishHandler();
    }
}

- (void)handleServerDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        self.dataArray = data;
        __weak typeof(self) weakSelf = self;
        [weakSelf reloadCommentTableViewArrWithComments:data completion:^{
            [weakSelf reloadViewsWithFeed];
        }];    }
    if (finishHandler) {
        finishHandler();
    }
}

- (void)handleLoadMoreDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataArray];
        [tempArray addObjectsFromArray:data];
        self.dataArray = tempArray;
        __weak typeof(self) weakSelf = self;
        NSMutableArray *tempData = [NSMutableArray array];
        [tempData addObjectsFromArray:weakSelf.reloadComments];
        [tempData addObjectsFromArray:data];
        [weakSelf reloadCommentTableViewArrWithComments:tempData completion:^{
            int commentCount = [weakSelf.feed.comments_count intValue];
            if (commentCount < tempData.count) {
                commentCount = (int)tempData.count;
            }
            weakSelf.feed.comments_count = [NSNumber numberWithInt:commentCount];
            [weakSelf.tableView reloadData];
        }];
    }
    if (finishHandler) {
        finishHandler();
    }
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
    
    [self.tableView reloadData];
    
    CGFloat comtentSizeHeight = self.feedStyle.totalHeight + self.likeListView.frame.size.height + DeltaHeight + self.tableView.frame.size.height;
    if (self.tableView.contentSize.height < comtentSizeHeight && self.reloadComments.count > 0) {
        self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, comtentSizeHeight);
    }
}

- (void)refreshNewData:(LoadFinishBlock)block
{
    __weak typeof(self) weakSelf = self;
    [self fetchOnFeedFromServer:^(NSError *error){
        if (!error) {
            if (weakSelf.showType == UMComShowFromClickRemoteNotice) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kUMComRemoteNotificationReceivedNotification object:nil];
            }
            [weakSelf reloadLikeImageView:weakSelf.feed];
            [weakSelf refreshFeedsLike:weakSelf.feedId block:^(NSError *error) {
                [weakSelf refreshFeedsComments:weakSelf.feedId block:^(NSError *error) {
                    if (block) {
                        block(error);
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
        [self reloadCommentTableViewArrWithComments:self.feed.comments.array completion:^{
            [weakSelf.tableView reloadData];
        }];
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self refreshNewDataFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        isHaveNextPage = haveNextPage;
        isrefreshCommentFinish = YES;
        if (error) {
            [UMComShowToast showFetchResultTipWithError:error];
        }
        if (weakSelf.showType == UMComShowFromClickComment || weakSelf.showType == UMComShowFromClickRemoteNotice) {
            if (isViewDidAppear == YES && weakSelf.showType == UMComShowFromClickComment) {
                if (weakSelf.reloadComments.count > 0) {
                    [weakSelf.tableView setContentOffset:CGPointMake(0, weakSelf.feedStyle.totalHeight+weakSelf.likeListView.frame.size.height+DeltaHeight) animated:NO];
                }
                [weakSelf showCommentEditViewWithComment:nil];
            }
        }
        if (block) {
            block(error);
        }
    }];
}

- (void)reloadCommentTableViewArrWithComments:(NSArray *)reloadComments completion:(void (^)())completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
            UMComMutiText *commentMutiText = [UMComMutiText mutiTextWithSize:CGSizeMake(self.view.frame.size.width-UMComCommentDeltalWidth, MAXFLOAT) font:UMComCommentTextFont  string:replayStr lineSpace:2 checkWords:checkWords];
            float height = commentMutiText.textSize.height + 5/2 + UMComCommentNamelabelHeght;
            commentMutiText.textSize  = CGSizeMake(commentMutiText.textSize.width, height);
            [mutiStyleViewArr addObject:commentMutiText];
            index++;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.commentStyleViewArray = mutiStyleViewArr;
            self.reloadComments = reloadComments;
            if (completion) {
                completion();
            }
        });
    });

}

#pragma mark - button action

- (void)didClickOnLike:(UIButton *)sender {
    [self.commentEditView dismissAllEditView];
    [self customObj:sender clickOnLikeFeed:self.feed];
}

- (void)didClickOnForward:(UIButton *)sender {
    [[UMComAction action] performActionAfterLogin:self.feed viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            UMComEditViewController *editViewController = [[UMComEditViewController alloc] initWithForwardFeed:self.feed];
            editViewController.createFeedSucceed = ^(UMComFeed *feed){
                [self reloadViewsWithFeed];
            };
            UMComNavigationController *editNaviController = [[UMComNavigationController alloc] initWithRootViewController:editViewController];
            [self presentViewController:editNaviController animated:YES completion:nil];
        }
    }];
}

- (void)didClikeObComment:(UIButton *)sender
{
    [self.commentEditView dismissAllEditView];
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            [weakSelf showCommentEditViewWithComment:nil];
        }
    }];
}

- (void)createMuneView
{
    CGFloat menuViewHeight = 40;
    UIView *menuView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIApplication sharedApplication].keyWindow.frame.size.height - menuViewHeight, self.view.frame.size.width, menuViewHeight)];
    [[UIApplication sharedApplication].keyWindow addSubview:menuView];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [menuView addSubview:line];
    menuView.backgroundColor = [UIColor whiteColor];
    CGFloat buttonHeight = 40;
    CGFloat buttonWidth = 65;
    CGRect buttonFrame = CGRectMake(0, (menuViewHeight - buttonHeight)/2, buttonWidth, buttonHeight);
    for (int index = 0; index < 3; index ++) {
        NSString *title = nil;
        NSString *imageName = nil;
        SEL action;
        if (index == 0) {
            action = @selector(didClickOnLike:);
            title = @"点赞";
            if ([self.feed.liked boolValue]) {
                imageName = @"um_like+";
            }else{
                imageName = @"um_like-";
            }
            buttonFrame.origin.x = self.view.frame.size.width/4-buttonWidth;
        }else if (index == 1){
            title = @"转发";
            imageName = @"um_repo";
            action = @selector(didClickOnForward:);
            buttonFrame.origin.x = self.view.frame.size.width/2 - buttonWidth/2;
        }else if (index == 2){
            title = @"评论";
            imageName = @"um_comment";
            action = @selector(didClikeObComment:);
            buttonFrame.origin.x = self.view.frame.size.width -self.view.frame.size.width/4;
        }
        
        UIButton *button = [self createNewButtonWithImageName:imageName title:title action:action frame:buttonFrame];
        [menuView addSubview:button];
    }
    self.menuView = menuView;
}

- (UIButton *)createNewButtonWithImageName:(NSString *)imageName
                                     title:(NSString *)title
                                    action:(SEL)action
                                     frame:(CGRect)frame;
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = UMComFontNotoSansLightWithSafeSize(16);
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:UMComImageWithImageName(imageName) forState:UIControlStateNormal];
    CGFloat imageWidth = 16;
    CGFloat imageHight = 14;
    CGFloat imageEdge = 5;
    CGFloat imageTopEdge = frame.size.height/2 - imageHight/2;
    [button setImageEdgeInsets:UIEdgeInsetsMake(imageTopEdge, imageEdge, imageTopEdge, frame.size.width - imageWidth - imageEdge)];
    
    return button;
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
        if (error){
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
            if ([obj isKindOfClass:[UIButton class]]) {
                UIButton *likeButton = obj;
                if ([feed.liked boolValue]) {
                    [likeButton setImage:UMComImageWithImageName(@"um_like+") forState:UIControlStateNormal];
                }else{
                   [likeButton setImage:UMComImageWithImageName(@"um_like-") forState:UIControlStateNormal];
                }
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
                                       NSIndexPath *indexPath = [weakSelf.tableView indexPathForCell:cell];
                                       [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                   }
                                 
                               }];
    }];
}


- (void)customObj:(id)obj clickOnUser:(UMComUser *)user
{
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:user viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            UMComUserCenterViewController *userCenterVc = [[UMComUserCenterViewController alloc]initWithUser:user];
            [weakSelf.navigationController pushViewController:userCenterVc animated:YES];
        }
    }];
}

- (void)customObj:(id)obj clickOnTopic:(UMComTopic *)topic
{
    if (!topic) {
        return;
    }
    UMComTopicFeedViewController *oneFeedViewController = [[UMComTopicFeedViewController alloc] initWithTopic:topic];
    [self.navigationController  pushViewController:oneFeedViewController animated:YES];
}


- (void)customObj:(id)obj clickOnOriginFeedText:(UMComFeed *)feed
{
    if (!feed) {
        return;
    }
    UMComFeedDetailViewController * feedDetailViewController = [[UMComFeedDetailViewController alloc] initWithFeed:feed showFeedDetailShowType:UMComShowFromClickFeedText];
    [self.navigationController pushViewController:feedDetailViewController animated:YES];
}

- (void)customObj:(id)obj clickOnURL:(NSString *)url
{
    UMComWebViewController * webViewController = [[UMComWebViewController alloc] initWithUrl:url];
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)customObj:(id)obj clickOnLocationText:(UMComFeed *)feed
{
    if (!feed || [feed.status intValue] >= FeedStatusDeleted) {
        return;
    }
    NSDictionary *locationDic = feed.location;
    if (!locationDic) {
        locationDic = feed.origin_feed.location;
    }
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[[[locationDic valueForKey:@"geo_point"] objectAtIndex:1] floatValue] longitude:[[[locationDic valueForKey:@"geo_point"] objectAtIndex:0] floatValue]];
    __weak typeof(self) weakSelf = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        UMComNearbyFeedViewController *nearbyFeedViewController = [[UMComNearbyFeedViewController alloc] initWithLocation:location title:[locationDic valueForKey:@"name"]];
        [weakSelf.navigationController pushViewController:nearbyFeedViewController animated:YES];
    }];
}


- (void)customObj:(id)obj clickOnForward:(UMComFeed *)feed
{
    if (!feed) {
        return;
    }
    [[UMComAction action] performActionAfterLogin:feed viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            UMComEditViewController *editViewController = [[UMComEditViewController alloc] initWithForwardFeed:feed];
            UMComNavigationController *editNaviController = [[UMComNavigationController alloc] initWithRootViewController:editViewController];
            [self presentViewController:editNaviController animated:YES completion:nil];
        }
    }];
}


- (void)customObj:(id)obj clickOnImageView:(UIImageView *)imageView complitionBlock:(void (^)(UIViewController *viewcontroller))block
{
    if (block) {
        block(self);
    }
}

- (void)customObj:(id)obj clickOnShare:(UMComFeed *)feed
{
    if (!feed) {
        return;
    }
    self.shareListView = [[UMComShareCollectionView alloc]initWithFrame:CGRectMake(0, self.view.window.frame.size.height, self.view.window.frame.size.width,120)];
    self.shareListView.feed = feed;
    self.shareListView.shareViewController = self;
    [self.shareListView shareViewShow];
}

#pragma mark - rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.shareListView dismiss];
}


#pragma mark - 显示评论视图
///***************************显示评论视图*********************************/
- (void)showCommentEditViewWithComment:(UMComComment *)comment
{
    if (!self.commentEditView) {
        self.commentEditView = [[UMComCommentEditView alloc]initWithSuperView:[UIApplication sharedApplication].keyWindow];
        __weak typeof(self) weakSelf = self;
        self.commentEditView.SendCommentHandler = ^(NSString *commentText){
            if (commentText == nil || commentText.length == 0) {
                [[[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"Sorry",@"抱歉") message:UMComLocalizedString(@"Empty_Text",@"内容不能为空") delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK",@"好") otherButtonTitles:nil] show];
            }
            if ([UMComTools getStringLengthWithString:commentText] > [UMComSession sharedInstance].comment_length) {
                NSString *chContent = [NSString stringWithFormat:@"评论内容不能超过%d个字符",(int)[UMComSession sharedInstance].comment_length];
                NSString *key = [NSString stringWithFormat:@"Content must not exceed %d characters",(int)[UMComSession sharedInstance].comment_length];
                [[[UIAlertView alloc]
                  initWithTitle:UMComLocalizedString(@"Sorry",@"抱歉") message:UMComLocalizedString(key,chContent) delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK",@"好") otherButtonTitles:nil] show];
            }
            
            [weakSelf postComment:commentText];
        };
    }
    if (comment) {
        [self.commentEditView presentEditView];
        self.commentEditView.commentTextField.placeholder = [NSString stringWithFormat:@"回复%@",[[comment creator] name]];
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
    UMComComment *replyComment = nil;
    if (self.replyUserId) {
        replyComment = self.selectedComment;
    }
    [UMComPushRequest commentFeedWithFeed:self.feed
                          commentContent:content
                            replyComment:replyComment
                    commentCustomContent:nil
                                  images:nil
                              completion:^(id responseObject,NSError *error) {
        if (error) {
            
            if (error.code == ERR_CODE_FEED_COMMENT_UNAVAILABLE) {
                [UMComShowToast showFetchResultTipWithError:error];
                [self refreshNewData:nil];
            }
            [UMComShowToast showFetchResultTipWithError:error];
        }else{
            [self insertComment:responseObject atIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
//            [weakSelf refreshFeedsComments:weakSelf.feed.feedID block:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUMComCommentOperationFinishNotification object:weakSelf.feed];
        }
    }];
}


- (void)insertComment:(UMComComment *)comment atIndexPath:(NSIndexPath *)indexPath
{
    if (![comment isKindOfClass:[UMComComment class]]) {
        return;
    }
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
    UMComMutiText *commentMutiText = [UMComMutiText mutiTextWithSize:CGSizeMake(self.view.frame.size.width-UMComCommentDeltalWidth, MAXFLOAT) font:UMComCommentTextFont  string:replayStr lineSpace:2 checkWords:checkWords];
    float height = commentMutiText.textSize.height + 5/2 + UMComCommentNamelabelHeght;
    commentMutiText.textSize  = CGSizeMake(commentMutiText.textSize.width, height);
    NSMutableArray *commentArray = [NSMutableArray arrayWithObject:comment];
    [commentArray addObjectsFromArray:self.reloadComments];
    NSMutableArray *commentMutiTextArray = [NSMutableArray arrayWithObject:commentMutiText];
    [commentMutiTextArray addObjectsFromArray:self.commentStyleViewArray];
    self.commentStyleViewArray = commentMutiTextArray;
    self.reloadComments = commentArray;
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
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
        if (self.deletedCompletion) {
            self.deletedCompletion(feed);
        }
    }
}

@end


