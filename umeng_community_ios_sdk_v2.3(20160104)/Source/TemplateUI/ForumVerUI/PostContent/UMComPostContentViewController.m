//
//  UMComPostContentViewController.m
//  UMCommunity
//
//  Created by umeng on 12/2/15.
//  Copyright © 2015 Umeng. All rights reserved.
//

#import "UMComPostContentViewController.h"
#import "UMComFeed.h"
#import "UMComFeed+UMComManagedObject.h"
#import "UMComTools.h"
#import "UMComConfigFile.h"
#import "UMComUser.h"
#import "UMComComment.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComGridView.h"
#import "UMComPullRequest.h"
#import "UMComHttpManager.h"
#import "UMComImageUrl.h"
#import "UMComMutiStyleTextView.h"
#import "UMComPushRequest.h"
#import "UMComShowToast.h"
#import "UMComShareCollectionView.h"

#import "UMComPostContentCommentCell.h"
#import "UMComPostContentBodyCell.h"

#import "UMComForumUserCenterViewController.h"
#import "UMComPostReplyEditView.h"
#import "UMComSession.h"
#import "UMComAction.h"

#import "UMImagePickerController.h"
#import "UMComWebViewController.h"
#import "UIViewController+UMComAddition.h"
#import "UMComNavigationController.h"
#import "UMComiToast.h"
#import <AVFoundation/AVFoundation.h>
#import "UMComNotificationMacro.h"
#import "UMComUser+UMComManagedObject.h"


#define UMComFeedMenuName @"name"
#define UMComFeedMenuSelector @"selector"
#define UMComFeedIdentifierPrefix @"feed"
#define UMComPostBottomBarHeight 50

#define UMComPostReplyTextMaxLength 300

#define UMComPostActionSheetPostTag 99002
#define UMComPostActionSheetCommentTag 99001

@interface UMComPostContentViewController ()
<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

/* Data */
@property (nonatomic, strong) NSArray *displayedCommentList;
@property (nonatomic, strong) NSMutableArray *sentCommentList;

@property (nonatomic, strong) NSString *feedID;
@property (nonatomic, strong) NSString *wakedCommentID;
@property (nonatomic, strong) UMComFeed *feed;

/* UI */
@property (nonatomic, strong) UMComMutiText *precalcText;

@property (nonatomic, strong) NSMutableDictionary *cacheHeightInfo;

@property (nonatomic, strong) NSMutableDictionary *commentPrecalcTextCache;

@property (nonatomic, strong) UMComPostContentCell *cachedPostBodyCell;
@property (nonatomic, strong) NSMutableArray *cachedCommentCellQueue;

@property (nonatomic, strong) NSMutableArray *menuList;
@property (nonatomic, strong) NSMutableArray *CommentMenuList;

@property (nonatomic, strong) UIButton *watchHostButton;
@property (nonatomic, strong) UIButton *replyPostButton;
@property (nonatomic, strong) UIButton *favNavButton;

@property (nonatomic, strong) UIView *bottomBarView;

@property (nonatomic, weak) UMComPostReplyEditView *replyEditView;

/* Logic action */
@property (nonatomic, assign) BOOL watchHost;

@property (nonatomic, assign) UMComPostContentCommentCell *currentOpCommentCell;
@property (nonatomic, assign) UMComComment *currentOpComment;

@property (nonatomic, assign) BOOL menuListContainsDelete;

@property (nonatomic, strong) UMComShareCollectionView *shareListView;//分享选项


@end

@implementation UMComPostContentViewController
{
    BOOL _tableviewConsumeCachedCellFlag;
}

static NSString *UMComPostCommentCellIdentifier = @"UMComPostCommentCellIdentifier";
static NSString *UMComPostContentCellIdentifier = @"UMComPostContentCellIdentifier";
static NSString *UMComPostNoCommentCellIdentifier = @"UMComPostNoCommentCellIdentifier";

- (instancetype)initWithFeedID:(NSString *)feedID andCommentID:(NSString *)commentID
{
    if (self = [self init]) {
        self.feedID = feedID;
        self.wakedCommentID = commentID;
        if (_feedID) {
            [self requestPostData];
        }
    }
    return self;
}

- (instancetype)initWithFeed:(UMComFeed *)feed
{
    if (self = [self init]) {
        self.feed = feed;
        self.feedID = feed.feedID;
        [self requestPostData];
        
        if (_feed.title.length == 0) {
            _feed.title = [_feed.text substringToIndex:_feed.text.length < 30 ? _feed.text.length : 30];
        }
        
        [self requestCommentData];
        
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        _tableviewConsumeCachedCellFlag = NO;
        
        self.watchHost = NO;
        
        [self createTopBarItems];
        
        self.displayedCommentList = [NSMutableArray array];
        self.sentCommentList = [NSMutableArray array];
        NSUInteger cachePagesCount = 2;
        self.cacheHeightInfo = [NSMutableDictionary dictionaryWithCapacity:20 * cachePagesCount + 1];
        self.commentPrecalcTextCache = [NSMutableDictionary dictionaryWithCapacity:20 * cachePagesCount];
        self.cachedCommentCellQueue = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    
    
    [self.tableView registerClass:[UMComPostContentCell class] forCellReuseIdentifier:UMComPostContentCellIdentifier];
    [self.tableView registerClass:[UMComPostContentCommentCell class] forCellReuseIdentifier:UMComPostCommentCellIdentifier];
    
    [super viewDidLoad];
    
    [self setForumUITitle:@"帖子详情"];
    
    self.tableView.backgroundColor = UMComColorWithColorValueString(@"#FAFBFD");
    CGRect tableFrame = self.view.bounds;
    tableFrame.size.height = tableFrame.size.height - UMComPostBottomBarHeight;
    self.tableView.frame = tableFrame;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.noDataTipLabel removeFromSuperview];
    self.noDataTipLabel = nil;

//    self.noDataTipLabel.text = @"暂时没有评论";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self createBottomBar];
    
    [self.tableView.superview addSubview:_bottomBarView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onReceivePostDeleteNotification:)
                                                 name:kUMComFeedDeletedFinishNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_bottomBarView removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UI
- (void)createTopBarItems
{
    self.favNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_favNavButton addTarget:self action:@selector(favouritePost) forControlEvents:UIControlEventTouchUpInside];
    _favNavButton.frame = CGRectMake(0.f, 0.f, 20.f, 20.f);
    UIImage *image = UMComImageWithImageName(@"um_forum_collection_normal");
    [_favNavButton setImage:image forState:UIControlStateNormal];
    image = UMComImageWithImageName(@"um_forum_collection_highlight");
    [_favNavButton setImage:image forState:UIControlStateHighlighted];
    [_favNavButton setImage:image forState:UIControlStateSelected];
    UIBarButtonItem *favItem = [[UIBarButtonItem alloc] initWithCustomView:_favNavButton];
    
    _favNavButton.selected = [self.feed.has_collected boolValue];
    
    UIButton *menuItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuItemButton addTarget:self action:@selector(displayPostMenu:) forControlEvents:UIControlEventTouchUpInside];
    menuItemButton.frame = CGRectMake(0.f, 0.f, 20.f, 4.f);
    image = UMComImageWithImageName(@"um_forum_more_gray");
    [menuItemButton setImage:image forState:UIControlStateNormal];
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithCustomView:menuItemButton];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]init];
    UIView *spaceView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 20)];
    spaceView.backgroundColor = [UIColor clearColor];
    [spaceItem setCustomView:spaceView];
    
    NSArray<UIBarButtonItem *> *items = [NSArray arrayWithObjects:menuItem, spaceItem, favItem, nil];
    [self.navigationItem setRightBarButtonItems:items];
}

#pragma mark UI Actions
- (void)watchHost:(id)sender
{
    _watchHost = !_watchHost;
    _watchHostButton.selected = _watchHost;
    [self requestCommentData];
}

- (BOOL)prefersStatusBarHidden
{
    if (UMComSystem_Version_Greater_Than_Or_Equal_To(@"9.0")) {
        return NO;
    }
    return [_replyEditView superview] ? YES : NO;
}

- (void)insertComment:(UMComComment *)comment
{
    [_sentCommentList addObject:comment];
    [self synthesizeCommentList];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_displayedCommentList.count-1 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_displayedCommentList.count-1 inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [_cachedPostBodyCell updateActionButtonStatus];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewController:action:object:)]) {
        [_delegate viewController:self action:UMPostContentViewActionUpdateCount object:_feed];
    }
}

- (void)createImagePicker
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author == kCLAuthorizationStatusDenied)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"本应用无访问照片的权限，如需访问，可在设置中修改" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
        return;
    }
    if([UMImagePickerController isAccessible])
    {
        UMImagePickerController *imagePickerController = [[UMImagePickerController alloc] init];
        imagePickerController.minimumNumberOfSelection = 1;
        imagePickerController.maximumNumberOfSelection = 1;
        
        [imagePickerController setFinishHandle:^(BOOL isCanceled,NSArray *assets){
            if(!isCanceled)
            {
                [_replyEditView setImageAssets:assets];
            }
        }];
        
        UMComNavigationController *navigationController = [[UMComNavigationController alloc] initWithRootViewController:imagePickerController];
        [self presentViewController:navigationController animated:YES completion:NULL];
    }
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *selectImage = [info valueForKey:@"UIImagePickerControllerOriginalImage"];
    UIImage *tempImage = nil;
    if (selectImage.imageOrientation != UIImageOrientationUp) {
        UIGraphicsBeginImageContext(selectImage.size);
        [selectImage drawInRect:CGRectMake(0, 0, selectImage.size.width, selectImage.size.height)];
        tempImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }else{
        tempImage = selectImage;
    }
    [_replyEditView addPickedImage:tempImage];
}


-(void)takePhoto
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted)
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"本应用无访问相机的权限，如需访问，可在设置中修改" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
            return;
        }
    }else{
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == kCLAuthorizationStatusRestricted || author == kCLAuthorizationStatusDenied)
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"本应用无访问相机的权限，如需访问，可在设置中修改" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
            return;
        }
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:^{
            
        }];
    }
}

- (UMComPostReplyEditView *)showReplyEditView
{
//    if (![self checkLoginStatus]) {
//        return nil;
//    }

    NSArray *viewArray = [[NSBundle mainBundle] loadNibNamed:@"UMComPostReplyEditView" owner:self options:nil];
    UMComPostReplyEditView *replyView = viewArray[0];
    replyView.frame = self.navigationController.view.bounds;
    
    self.replyEditView = replyView;
    [self.navigationController.view addSubview:replyView];
    if (UMComSystem_Version_Greater_Than_Or_Equal_To(@"7.0")) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    replyView.getImageBlock = ^(UMComPostReplyImagePickerType type){
        if (type == UMComPostReplyImagePickerCamera) {
            [self takePhoto];
        } else {
            [self createImagePicker];
        }
    };
    
    return replyView;
}

//- (void)updateNoDataTipPosition:(NSUInteger)cellHeight
//{
//    CGRect frame = self.noDataTipLabel.frame;
//    frame.origin.y = cellHeight + UMComPostPad;
//    self.noDataTipLabel.frame = frame;
//}

#pragma mark UI event
- (void)displayPostMenu:(id)sender
{
    if (_menuList) {
        [_menuList removeAllObjects];
    } else {
        self.menuList = [NSMutableArray arrayWithCapacity:5];
    }
    
    NSString *destructiveButtonString = nil;
    if ([self checkAuthDeletePost]) {
        [_menuList addObject:@{UMComFeedMenuName: @"删除",
                               UMComFeedMenuSelector: NSStringFromSelector(@selector(deletePost))}];
        destructiveButtonString = [_menuList firstObject][UMComFeedMenuName];
        _menuListContainsDelete = YES;
    } else {
        _menuListContainsDelete = NO;
    }
    [_menuList addObject:@{UMComFeedMenuName: @"回复",
                           UMComFeedMenuSelector: NSStringFromSelector(@selector(replyPost))}];
    if ([_feed.ban_user integerValue] == 1) {
        NSString *tip = @"禁言";
        if ([self isUserBeingBaned:_feed.creator]) {
            tip = @"解除禁言";
        }
        [_menuList addObject:@{UMComFeedMenuName: tip,
                               UMComFeedMenuSelector: NSStringFromSelector(@selector(banUserWithinTopic))}];
    }
    [_menuList addObject:@{UMComFeedMenuName: @"分享",
                           UMComFeedMenuSelector: NSStringFromSelector(@selector(sharePost))}];
    
    if ([self checkNeedReport]) {
        [_menuList addObject:@{UMComFeedMenuName: @"举报",
                               UMComFeedMenuSelector: NSStringFromSelector(@selector(reportPost))}];
    }

    [_menuList addObject:@{UMComFeedMenuName: @"拷贝",
                           UMComFeedMenuSelector: NSStringFromSelector(@selector(copyPost))}];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:destructiveButtonString
                                              otherButtonTitles:nil];
    sheet.tag = UMComPostActionSheetPostTag;
    for (int i = _menuListContainsDelete ? 1 : 0; i < _menuList.count; ++i) {
        [sheet addButtonWithTitle:[_menuList objectAtIndex:i][UMComFeedMenuName]];
    }
    [sheet showInView:self.view];
}
- (void)displayCommentMenu
{
    if (_CommentMenuList) {
        [_CommentMenuList removeAllObjects];
    } else {
        self.CommentMenuList = [NSMutableArray arrayWithCapacity:5];
    }

    NSString *destructiveButtonString = nil;
    if ([self checkAuthDeleteComment]) {
        [_CommentMenuList addObject:@{UMComFeedMenuName: @"删除",
                                      UMComFeedMenuSelector: NSStringFromSelector(@selector(deleteComment))}];
        destructiveButtonString = [_CommentMenuList firstObject][UMComFeedMenuName];
        _menuListContainsDelete = YES;
    } else {
        _menuListContainsDelete = NO;
    }
    [_CommentMenuList addObject:@{UMComFeedMenuName: @"回复",
                                  UMComFeedMenuSelector: NSStringFromSelector(@selector(replyComment))}];
    if ([_currentOpComment.ban_user integerValue] == 1) {
        NSString *tip = @"禁言";
        if ([self isUserBeingBaned:_currentOpComment.creator]) {
            tip = @"解除禁言";
        }
        [_CommentMenuList addObject:@{UMComFeedMenuName:tip,
                                      UMComFeedMenuSelector: NSStringFromSelector(@selector(banUserWithinComment))}];
    }
    
    if ([self checkNeedReportForCurComment:self.currentOpComment]) {
        [_CommentMenuList addObject:@{UMComFeedMenuName: @"举报",
                                  UMComFeedMenuSelector: NSStringFromSelector(@selector(reportComment))}];
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:destructiveButtonString                                              otherButtonTitles:nil];
    sheet.tag = UMComPostActionSheetCommentTag;
    
    for (int i = _menuListContainsDelete ? 1 : 0; i < _CommentMenuList.count; ++i) {
        [sheet addButtonWithTitle:[_CommentMenuList objectAtIndex:i][UMComFeedMenuName]];
    }
    [sheet showInView:self.view];
}
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSInteger cancelButtonIndex = _menuListContainsDelete ? 1 : 0;
//    if (buttonIndex == cancelButtonIndex)   return;
//    
//    NSUInteger listIndex = buttonIndex == 0 ? buttonIndex : buttonIndex - 1;
//    SEL sel;
//    if (actionSheet.tag == UMComPostActionSheetPostTag) {
////        NSLog(@"%@", _menuList[listIndex][UMComFeedMenuSelector]);
//        sel = NSSelectorFromString(_menuList[listIndex][UMComFeedMenuSelector]);
//    } else if (actionSheet.tag == UMComPostActionSheetCommentTag) {
////        NSLog(@"%@", _CommentMenuList[listIndex][UMComFeedMenuSelector]);
//        sel = NSSelectorFromString(_CommentMenuList[listIndex][UMComFeedMenuSelector]);
//        
//    }
//    
//    // TODO: warn
//    [self performSelector:sel];
//}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSInteger cancelButtonIndex = _menuListContainsDelete ? 1 : 0;
    if (buttonIndex == cancelButtonIndex)   return;
    
    NSUInteger listIndex = buttonIndex == 0 ? buttonIndex : buttonIndex - 1;
    SEL sel;
    if (actionSheet.tag == UMComPostActionSheetPostTag) {
        //        NSLog(@"%@", _menuList[listIndex][UMComFeedMenuSelector]);
        sel = NSSelectorFromString(_menuList[listIndex][UMComFeedMenuSelector]);
    } else if (actionSheet.tag == UMComPostActionSheetCommentTag) {
        //        NSLog(@"%@", _CommentMenuList[listIndex][UMComFeedMenuSelector]);
        sel = NSSelectorFromString(_CommentMenuList[listIndex][UMComFeedMenuSelector]);
        
    }
    
    // TODO: warn
    [self performSelector:sel];

}

- (void)createBottomBar
{
    if (_bottomBarView) {
        return;
    }
    
    NSUInteger barHeight = UMComPostBottomBarHeight;
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                 self.view.superview.frame.size.height - barHeight,
                                                                 self.view.superview.frame.size.width,
                                                                 barHeight)];
    bottomBar.backgroundColor = UMComColorWithColorValueString(UMComPostColorInnerBgColor);
    bottomBar.layer.borderWidth = 1.f;
    bottomBar.layer.borderColor = UMComColorWithColorValueString(UMComPostColorBottomLine).CGColor;
    self.bottomBarView = bottomBar;
    
    CGSize buttonSize = CGSizeMake(90.f, 30.f);
    
    self.watchHostButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _watchHostButton.frame = CGRectMake(UMComPostOriginX,
                                        UMComPostOriginY,
                                        buttonSize.width,
                                        buttonSize.height);
    _watchHostButton.layer.cornerRadius = 5.f;
    _watchHostButton.layer.masksToBounds = YES;
    _watchHostButton.layer.borderColor = UMComColorWithColorValueString(UMComPostColorBottomLine).CGColor;
    _watchHostButton.layer.borderWidth = 1.f;
    
    [_watchHostButton setTitleColor:UMComColorWithColorValueString(UMComPostColorBlue) forState:UIControlStateNormal];
    [_watchHostButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_watchHostButton setBackgroundImage:[UMComTools imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_watchHostButton setBackgroundImage:[UMComTools imageWithColor:UMComColorWithColorValueString(UMComPostColorBlue)] forState:UIControlStateSelected];
    
    _watchHostButton.titleLabel.font = UMComFontNotoSansLightWithSafeSize(12.f);
    [_watchHostButton setTitle:@"只看楼主" forState:UIControlStateNormal];
    [_watchHostButton setTitle:@"查看全部" forState:UIControlStateSelected];
    [_watchHostButton addTarget:self action:@selector(watchHost:) forControlEvents:UIControlEventTouchUpInside];
    
    self.replyPostButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _replyPostButton.frame = CGRectMake(UMComPostOriginX + _watchHostButton.frame.size.width + UMComPostPad,
                                        UMComPostOriginY,
                                        bottomBar.frame.size.width - _watchHostButton.frame.origin.x - _watchHostButton.frame.size.width - UMComPostPad * 2,
                                        buttonSize.height);
    _replyPostButton.layer.borderColor = UMComColorWithColorValueString(UMComPostColorBottomLine).CGColor;
    _replyPostButton.layer.borderWidth = 1.f;
    _replyPostButton.layer.cornerRadius = 5.f;
    _replyPostButton.layer.masksToBounds = YES;
    _replyPostButton.backgroundColor = [UIColor whiteColor];
    [_replyPostButton addTarget:self action:@selector(replyPost) forControlEvents:UIControlEventTouchUpInside];
    _replyPostButton.titleLabel.font = UMComFontNotoSansLightWithSafeSize(15.f);
    [_replyPostButton setTitleColor:UMComColorWithColorValueString(@"B5B5B5") forState:UIControlStateNormal];
    [_replyPostButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -_replyPostButton.frame.size.width / 2 - 13.f, 0, 0)];
    [_replyPostButton setTitle:@"写回帖" forState:UIControlStateNormal];
    
    UIImage *replyMarkImage = UMComImageWithImageName(@"um_forum_post_edit_nomal");
    CALayer *layer = [CALayer layer];
    layer.contents = (id)replyMarkImage.CGImage;
    layer.frame = CGRectMake(UMComPostOriginX, (_replyPostButton.frame.size.height - 14.f) / 2, 13.f, 14.f);
    [_replyPostButton.layer addSublayer:layer];
    
    [bottomBar addSubview:_watchHostButton];
    [bottomBar addSubview:_replyPostButton];
}


#pragma mark - Actions
- (void)requestPostData
{
    if (_feedID.length == 0) {
        return;
    }
    __weak typeof(self) ws = self;
    NSDictionary *extraDict = nil;
    if (_wakedCommentID) {
        extraDict = @{@"comment_id": _wakedCommentID};
    }
    UMComOneFeedRequest *req = [[UMComOneFeedRequest alloc] initWithFeedId:_feedID viewExtra:extraDict];
    [req fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        if (error) {
            [UMComShowToast showFetchResultTipWithError:error];
        } else {
            if ([data[0] isKindOfClass:[UMComFeed class]]) {
                UMComFeed *feed = (UMComFeed *)data[0];
                if (!ws.feed) {
                    ws.feed = feed;
                    ws.wakedCommentID = nil;
                    [self requestCommentData];
                }
                ws.feed = feed;
                ws.cachedPostBodyCell.feed = nil;
                ws.cachedPostBodyCell = nil;
                [ws.tableView reloadData];
            }
        }
    }];
}

- (void)requestCommentData
{
    if (!self.fetchRequest) {
        self.fetchRequest = [[UMComFeedCommentsRequest alloc] initWithFeedId:_feed.feedID commentUserId:nil order:commentorderByTimeAsc count:BatchSize];
    }
    if (_watchHost) {
        UMComFeedCommentsRequest *request = (UMComFeedCommentsRequest *)self.fetchRequest;
        request.comment_uid = _feed.creator.uid;
    } else {
        UMComFeedCommentsRequest *request = (UMComFeedCommentsRequest *)self.fetchRequest;
        request.comment_uid = nil;
    }
    [self loadAllData:nil fromServer:nil];
}

// Check Auth on SDK
/*

- (BOOL)checkAuthBanUser
{
    NSInteger authType = [[UMComSession sharedInstance].loginUser.atype integerValue];
    if (authType == 1 || authType == 3 || authType == 4) {
        return YES;
    }
    return NO;
}

- (BOOL)checkAuthBanHost
{
    if ([[UMComSession sharedInstance].loginUser.uid isEqualToString:_feed.creator.uid]) {
        return NO;
    }
    return [self checkAuthBanUser];
}

- (BOOL)checkAuthBanCommentUser
{
    if ([[UMComSession sharedInstance].loginUser.uid isEqualToString:_currentOpComment.creator.uid]) {
        return NO;
    }
    
    return [self checkAuthBanUser];
}

- (BOOL)checkAuthDeletePost
{
    return ([self checkAuthBanUser] || [[UMComSession sharedInstance].loginUser.uid isEqualToString:_feed.creator.uid]);
}

- (BOOL)checkAuthDeleteComment
{
    return ([self checkAuthBanUser] || [[UMComSession sharedInstance].loginUser.uid isEqualToString:_currentOpComment.creator.uid]);
}

- (BOOL)checkLoginStatus
{
    if ([UMComSession sharedInstance].uid) {
        return YES;
    } else {
        [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        }];
        return NO;
    }
}
 
*/

- (BOOL)isUserBeingBaned:(UMComUser *)user
{
    return [user.status integerValue] == 6;
}

- (BOOL)checkAuthDeletePost
{
    return ([_feed.permission integerValue] >= 100);
}

- (BOOL)checkAuthDeleteComment
{
    return (_currentOpComment.permission.integerValue >= 100);
}

/**
 *  判断当前用户是否有举报功能针对feed
 *
 *  @return YES 表示需要举报 NO表示不需要举报
 *  @note 如果用户feed是自己发的，就不需要出现举报按钮(自己举报自己没有意义).
 *        如果用户是全局管理员，也不需要出现举报按钮.(全局管理员可以直接删除，举报功能多余)
 *        如果用户是这个话题的管理员，也不需要举报按钮。
 */
- (BOOL) checkNeedReport
{
    //针对feed
    //如果是本人发布的就不需要举报
    NSString* temp_LogUid = [UMComSession sharedInstance].loginUser.uid;
    NSString* temp_CreatorUid = _feed.creator.uid;
    if (temp_LogUid && temp_CreatorUid && [temp_LogUid isEqualToString:temp_CreatorUid]) {
        return NO;
    }
    
    //如果当前是全局管理员
    NSNumber* typeNumber = [UMComSession sharedInstance].loginUser.atype;
    if(typeNumber && typeNumber.shortValue == 1)
    {
        return NO;
    }
    
    //判断当前是否是当前feed话题管理员
//    NSOrderedSet* tempTopics =  self.feed.topics;
//    if (tempTopics && tempTopics.count > 0) {
//       UMComTopic* tempCurTopic =  [tempTopics objectAtIndex:0];
//        if (tempCurTopic) {
//           return  ![[UMComSession sharedInstance].loginUser isUserHasTopicPermissionWithTopic:tempCurTopic];
//        }
//    }
    
    //此处简单的判断当前帖子的permission为100以上就认为有删除权限，不需要举报
    int permission = 0;
    permission = self.feed.permission.intValue;
    if (permission >= 100) {
        return NO;
    }
    
    return YES;
}

/**
 *  判断当前用户是否有举报功能针对评论
 *
 *  @return YES 表示需要举报 NO表示不需要举报
 *  @note 如果用户feed是自己发的，就不需要出现举报按钮(自己举报自己没有意义).
 *        如果用户是全局管理员，也不需要出现举报按钮.(全局管理员可以直接删除，举报功能多余)
 *        如果用户是这个话题的管理员，也不需要举报按钮。
 */
- (BOOL) checkNeedReportForCurComment:(UMComComment*)curComment
{
    
    //判断当前评论是否属于自己
    NSString* temp_LogUid = [UMComSession sharedInstance].loginUser.uid;
    NSString* temp_CreatorUid = curComment.creator.uid;
    if (temp_LogUid && temp_CreatorUid && [temp_LogUid isEqualToString:temp_CreatorUid]) {
        return NO;
    }
    
    //判断当前是否全局管理员
    NSNumber* typeNumber = [UMComSession sharedInstance].loginUser.atype;
    if(typeNumber && typeNumber.shortValue == 1)
    {
        return NO;
    }
    
    if (!curComment) {
        return YES;
    }
    
//    //判断当前是否是当前feed话题管理员
//    NSOrderedSet* tempTopics =  self.feed.topics;
//    if (tempTopics && tempTopics.count > 0) {
//        UMComTopic* tempCurTopic =  [tempTopics objectAtIndex:0];
//        if (tempCurTopic) {
//            return  ![[UMComSession sharedInstance].loginUser isUserHasTopicPermissionWithTopic:tempCurTopic];
//        }
//    }
    
    //此处简单的判断当前帖子的permission为100以上就认为有删除权限，不需要举报
    int permission = 0;
    permission = self.feed.permission.intValue;
    if (permission >= 100) {
        return NO;
    }

    
    return YES;
}


- (void)replyComment
{
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            UMComPostReplyEditView *replyView = [self showReplyEditView];
            if (!replyView) {
                return;
            }
            [replyView displayWithMaxLength:UMComPostReplyTextMaxLength
                                commitBlock:^(NSString *content, NSArray *imageList) {
                                    [self replyContent:content toPost:_feed fromComment:_currentOpComment imageList:imageList];
                                } cancelBlock:^{
                                    if (UMComSystem_Version_Greater_Than_Or_Equal_To(@"7.0")) {
                                        [self setNeedsStatusBarAppearanceUpdate];
                                    }
                                }];
        }
    }];

}

- (void)replyPost
{

    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            UMComPostReplyEditView *replyView = [self showReplyEditView];
            if (!replyView) {
                return;
            }
            [replyView displayWithMaxLength:UMComPostReplyTextMaxLength
                                commitBlock:^(NSString *content, NSArray *imageList) {
                                    [self replyContent:content toPost:_feed fromComment:nil imageList:imageList];
                                } cancelBlock:^{
                                    if (UMComSystem_Version_Greater_Than_Or_Equal_To(@"7.0")) {
                                        [self setNeedsStatusBarAppearanceUpdate];
                                    }
                                }];
        }
    }];

}

#pragma mark Menu Actions
- (void)banUserWithinTopic
{
    if ([self.feed.ban_user integerValue] == 1) {
        [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
            if (!error) {
                BOOL ban = ![self isUserBeingBaned:_feed.creator];
                [UMComPushRequest banUser:self.feed.creator inTopics:self.feed.topics.array ban:ban completion:^(id responseObject, NSError *error) {
                    if (error) {
                        [UMComShowToast showFetchResultTipWithError:error];
                    } else {
                        NSString *tip = @"禁言成功";
                        if (!ban) {
                            tip = @"解除禁言成功";
                        }
                        [[UMComiToast makeText:tip] show];
                    }
                }];
            }
        }];
        
    }
}
- (void)banUserWithinComment
{
    if ([_currentOpComment.ban_user integerValue] == 1) {
        [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
            if (!error) {
                BOOL ban = ![self isUserBeingBaned:_currentOpComment.creator];
                [UMComPushRequest banUser:_currentOpComment.creator inTopics:self.feed.topics.array ban:ban completion:^(id responseObject, NSError *error) {
                    if (error) {
                        [UMComShowToast showFetchResultTipWithError:error];
                    } else {
                        NSString *tip = @"禁言成功";
                        if (!ban) {
                            tip = @"解除禁言成功";
                        }
                        [[UMComiToast makeText:tip] show];
                    }
                }];
            }
        }];
        
    }
}

- (void)deletePost
{
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            if ([self checkAuthDeletePost]) {
                [UMComPushRequest deleteWithFeed:_feed completion:^(NSError *error) {
                    if (error) {
                        [UMComShowToast showFetchResultTipWithError:error];
                    }else{
//                        [[UMComiToast makeText:@"内容已删除"] show];
                    }
                }];
            }
        }
    }];
}

- (void)deleteCurrentOPComment
{
    NSArray *visibleComment = self.tableView.visibleCells;
    UITableViewCell *deleteCell = nil;
    for (id cell in visibleComment) {
        if ([cell isKindOfClass:[UMComPostContentCommentCell class]]) {
            if ([((UMComPostContentCommentCell *)cell).comment.commentID isEqualToString:_currentOpComment.commentID]) {
                deleteCell = cell;
            }
        }
    }
    BOOL isDel = NO;
    for (UMComComment *comment in self.dataArray) {
        if ([comment.commentID isEqualToString:_currentOpComment.commentID]) {
            NSMutableArray *commentList = [self.dataArray mutableCopy];
            [commentList removeObject:comment];
            isDel = YES;
            self.dataArray = commentList;
            break;
        }
    }
    if (!isDel) {
        for (UMComComment *comment in self.sentCommentList) {
            if ([comment.commentID isEqualToString:_currentOpComment.commentID]) {
                [self.sentCommentList removeObject:comment];
                isDel = YES;
                break;
            }
        }
    }
    if (isDel) {
        [self synthesizeCommentList];
        [self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:deleteCell]] withRowAnimation:UITableViewRowAnimationFade];
        [self.cachedPostBodyCell updateActionButtonStatus];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(viewController:action:object:)]) {
            [_delegate viewController:self action:UMPostContentViewActionUpdateCount object:_feed];
        }
    }
}

- (void)deleteComment
{
    if ([self checkAuthDeleteComment]) {
        [UMComPushRequest deleteWithComment:_currentOpComment feed:_feed completion:^(id responseObject, NSError *error) {
            if (error) {
                [UMComShowToast showFetchResultTipWithError:error];
                if (error.code == ERR_CODE_FEED_COMMENT_UNAVAILABLE) {
                    [self deleteCurrentOPComment];
                }
            } else {
                [self deleteCurrentOPComment];
            }
        }];
    }
}

- (void)favouritePost
{
    __weak typeof(self) ws = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            [UMComPushRequest favouriteFeedWithFeed:_feed
                                        isFavourite:![_feed.has_collected boolValue]
                                         completion:^(NSError *error) {
                                             if (error) {
                                                 [UMComShowToast showFetchResultTipWithError:error];
                                             } else {
                                                 ws.favNavButton.selected = [ws.feed.has_collected boolValue];
                                                 if ([ws.feed.has_collected boolValue]) {
                                                     [[UMComiToast makeText:@"已收藏"] show];
                                                 } else {
                                                     [[UMComiToast makeText:@"取消收藏"] show];
                                                 }
                                             }
                                         }];
        }
    }];
}

- (void)sharePost
{
    self.shareListView = [[UMComShareCollectionView alloc]initWithFrame:CGRectMake(0, self.view.window.frame.size.height-200, self.view.window.frame.size.width,120)];
    self.shareListView.feed = _feed;
    self.shareListView.shareViewController = self;
    [self.shareListView shareViewShow];
}
#pragma mark - rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.shareListView dismiss];
}


- (void)reportComment
{
    __weak typeof(self) ws = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            [UMComPushRequest spamWithComment:ws.currentOpComment completion:^(id responseObject, NSError *error) {
                if (error) {
                    [UMComShowToast showFetchResultTipWithError:error];
                    if (error.code == ERR_CODE_FEED_COMMENT_UNAVAILABLE) {
                        [self deleteCurrentOPComment];
                    }
                } else {
                    [UMComShowToast spamComment:error];
                }
            }];
        }
    }];
}

- (void)reportPost
{
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            [UMComPushRequest spamWithFeed:_feed completion:^(NSError *error) {
                if (error) {
                    [UMComShowToast showFetchResultTipWithError:error];
                } else {
                    [[UMComiToast makeText:@"举报成功"] show];
                }
            }];
        }
    }];
}

- (void)copyPost
{
    UMComFeed *feed = self.feed;
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
    
    [[UMComiToast makeText:@"拷贝成功"] show];
}

#pragma mark Cell Actions

- (void)actionForTouchUrl:(NSString *)url
{
    if (!url)
        return;
    UMComWebViewController * webViewController = [[UMComWebViewController alloc] initWithUrl:url];
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)actionForContentCell:(UMComPostContentCell *)cell type:(UMComPostContentActionType)type
{
    if (type == UMComPostContentActionAvatar) {
        [self switchToUser:cell.user];
    } else if (type == UMComPostContentActionLike) {
        [self likePost:cell];
    } else if (type == UMComPostContentActionReply) {
        [self replyPost];
    }
}
- (void)actionForCommentCell:(UMComPostContentCommentCell *)cell type:(UMComPostContentActionType)type
{
    if (type == UMComPostContentActionAvatar) {
        [self switchToUser:cell.user];
    } else if (type == UMComPostContentActionLike) {
        self.currentOpComment = cell.comment;
        [self likeComment:cell];
    } else if (type == UMComPostContentActionReply) {
        self.currentOpComment = cell.comment;
        [self replyComment];
    } else if (type == UMComPostContentActionMenu) {
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        self.currentOpComment = _displayedCommentList[path.row];
        [self displayCommentMenu];
    }
}

- (void)switchToUser:(UMComUser *)user
{
    UMComForumUserCenterViewController *userCenter = [[UMComForumUserCenterViewController alloc] initWithUser:user];
    [self.navigationController pushViewController:userCenter animated:YES];
}

- (void)likePost:(UMComPostContentCell *)postCell
{
//    if (![self checkLoginStatus]) {
//        return;
//    }
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            [UMComPushRequest likeWithFeed:postCell.feed
                                    isLike:![postCell.feed.liked boolValue]
                                completion:^(id responseObject, NSError *error) {
                                    if (error) {
                                        [UMComShowToast showFetchResultTipWithError:error];
                                    } else {
                                        [postCell updateActionButtonStatus];
                                        if (self.delegate && [self.delegate respondsToSelector:@selector(viewController:action:object:)]) {
                                            [_delegate viewController:self action:UMPostContentViewActionUpdateCount object:_feed];
                                        }
                                    }
                                }];
        }
    }];

}

- (void)likeComment:(UMComPostContentCommentCell *)commentCell
{
//    if (![self checkLoginStatus]) {
//        return;
//    }
    __weak typeof(self) ws = self;
    [[UMComAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
        if (!error) {
            [UMComPushRequest likeWithComment:commentCell.comment
                                       isLike:![commentCell.comment.liked boolValue]
                                   completion:^(id responseObject, NSError *error) {
                                       // CommentCell id equals to responds cell id
                                       if (![ws.currentOpComment.commentID isEqualToString:commentCell.comment.commentID]) {
                                           return;
                                       }
                                       if (error) {
                                           // TODO: language or not display
                                           [UMComShowToast showFetchResultTipWithError:error];
                                           
                                           if (error.code == ERR_CODE_FEED_COMMENT_UNAVAILABLE) {
                                               [self deleteCurrentOPComment];
                                           }

                                       } else {
                                           [commentCell updateActionButtonStatus];
                                       }
                                   }];
        }
    }];
}

- (void)replyContent:(NSString *)content toPost:(UMComFeed *)feed fromComment:(UMComComment *)comment imageList:(NSArray *)imageList
{
    if ((content.length == 0 && imageList.count == 0) || !feed) {
        return;
    }
    [UMComPushRequest commentFeedWithFeed:feed
                           commentContent:content
                             replyComment:comment
                     commentCustomContent:nil
                                   images:imageList
                               completion:^(id responseObject, NSError *error) {
                                   if (error) {
                                       [UMComShowToast showFetchResultTipWithError:error];
                                       if (error.code == ERR_CODE_FEED_COMMENT_UNAVAILABLE) {
                                           [self deleteCurrentOPComment];
                                       }
                                   } else {
                                       [[UMComiToast makeText:@"发送成功"] show];
                                       UMComComment *comment = responseObject;
                                       [self insertComment:comment];
                                   }
                               }];
}

#pragma mark - Pre calc cell

- (UMComPostContentCommentCell *)createPostCommentCellWithComment:(UMComComment *)comment
{
    UMComPostContentCommentCell *commentCell = nil;
    if (_cachedCommentCellQueue.count > 0 && _tableviewConsumeCachedCellFlag) {
        commentCell = _cachedCommentCellQueue[0];
        [_cachedCommentCellQueue removeObjectAtIndex:0];
        
        // TODO: test cache validation - heightForCell rewrite element at 0 index always
//        NSLog(@"__%ld", _cachedCommentCellQueue.count);
    }
    
    if (!commentCell) {
        commentCell = [self.tableView dequeueReusableCellWithIdentifier:UMComPostCommentCellIdentifier];
        [commentCell registerCellActionBlock:^(UMComPostContentBaseCell *cell, UMComPostContentActionType type) {
            [self actionForCommentCell:(UMComPostContentCommentCell *)cell type:type];
        }];
        [commentCell registerImageActionBlock:^(UIViewController *viewerViewController, UIImageView *imageView) {
            [self presentViewController:viewerViewController animated:YES completion:nil];
        }];
        commentCell.urlBlock = ^(NSString *url) {
            [self actionForTouchUrl:url];
        };
    }
    
//    if (![commentCell.comment.commentID isEqualToString:comment.commentID]) {
    
        UMComMutiText *commentText = [_commentPrecalcTextCache objectForKey:comment.commentID];
        if (!commentText) {
            
            commentText = [UMComMutiText mutiTextWithSize:CGSizeMake(self.view.frame.size.width - UMComPostContentAvatarSize - UMComPostPad - UMComPostOriginX * 2, INT_MAX)
                                                     font:UMComFontNotoSansLightWithSafeSize(UMComPostFontInnerBody)
                                                   string:comment.content
                                                lineSpace:2.f
                                               checkWords:nil];
            if (!comment.commentID) {
                comment.commentID = [comment description];
            }
            [_commentPrecalcTextCache setObject:commentText forKey:comment.commentID];
        }
        
        [commentCell refreshLayoutWithCalculatedTextObj:commentText
                                             andComment:comment];
//    }
    return commentCell;
}

- (NSUInteger)heightForInitializedPostCommentCellWithIndex:(NSIndexPath *)indexPath
{
    NSUInteger height = 0;
    UMComComment *comment = [_displayedCommentList objectAtIndex:indexPath.row];
    if ([_cacheHeightInfo objectForKey:comment.commentID]) {
        height = [[_cacheHeightInfo objectForKey:comment.commentID] integerValue];
    } else {
        UMComPostContentCommentCell *cell = [self createPostCommentCellWithComment:comment];
        [_cachedCommentCellQueue addObject:cell];
        
        height = cell.cellHeight;
        [_cacheHeightInfo setObject:[NSNumber numberWithInteger:height] forKey:comment.commentID];
    }
//    NSLog(@"height -- %ld", height);
    return height;
}

- (UMComPostContentCell *)createPostBodyCell
{
    if (!_cachedPostBodyCell) {
        UMComPostContentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:UMComPostContentCellIdentifier];
        [cell cleanImageView];
        
        self.cachedPostBodyCell = cell;
        
        [cell registerCellActionBlock:^(UMComPostContentBaseCell *cell, UMComPostContentActionType type) {
            [self actionForContentCell:(UMComPostContentCell *)cell type:type];
        }];
        [cell registerImageActionBlock:^(UIViewController *viewerViewController, UIImageView *imageView) {
            [self presentViewController:viewerViewController animated:YES completion:nil];
        }];
        cell.urlBlock = ^(NSString *url) {
            [self actionForTouchUrl:url];
        };
        
        __weak typeof(self) ws = self;
        [cell registerRefreshActionBlock:^(NSUInteger height){
            NSString *feedKey = [NSString stringWithFormat:@"%@_%@", UMComFeedIdentifierPrefix, _feed.feedID];
            [_cacheHeightInfo setObject:[NSNumber numberWithInteger:height] forKey:feedKey];
            [ws.tableView reloadData];
//            [ws.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }];
    }
    
    if (!_cachedPostBodyCell.feed || ![_cachedPostBodyCell.feed.feedID isEqualToString:_feed.feedID]) {
        UMComMutiText *precalcText = [UMComMutiText mutiTextWithSize:CGSizeMake(self.view.frame.size.width - UMComPostOriginX * 2, INT_MAX)
                                                                font:UMComFontNotoSansLightWithSafeSize(UMComPostFontBody)
                                                              string:_feed.text
                                                           lineSpace:10.f
                                                          checkWords:nil];
        
        [_cachedPostBodyCell refreshLayoutWithCalculatedTextObj:precalcText andFeed:_feed];
    }
    
    return _cachedPostBodyCell;
}

- (NSUInteger)heightForInitializedPostContentCell
{
    NSUInteger height = 0;
    NSString *feedKey = [NSString stringWithFormat:@"%@_%@", UMComFeedIdentifierPrefix, _feed.feedID];
    if ([_cacheHeightInfo objectForKey:feedKey]) {
        height = [[_cacheHeightInfo objectForKey:feedKey] integerValue];
    } else {
        UMComPostContentCell *cell = [self createPostBodyCell];
        
        height = cell.cellHeight;
        [_cacheHeightInfo setObject:[NSNumber numberWithInteger:height] forKey:feedKey];
    }
    
    return height;
}

#pragma mark - Tableview Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count = 0;
    if (section == 0) {
        count = 1;
    }else{
        count = _displayedCommentList.count ;
        self.loadMoreStatusView.hidden = count < BatchSize;
    }
    self.noDataTipLabel.hidden = YES;
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSUInteger height = [self heightForInitializedPostContentCell];
//        if (_displayedCommentList.count == 0) {
////            [self updateNoDataTipPosition:height];
//        }
        return height;
    } else {
        return [self heightForInitializedPostCommentCellWithIndex:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *retCell = nil;
    if (indexPath.section == 0) {
        retCell = [self createPostBodyCell];
    } else {
        _tableviewConsumeCachedCellFlag = YES;
        UMComComment *comment = [_displayedCommentList objectAtIndex:indexPath.row];
        retCell = [self createPostCommentCellWithComment:comment];
    }
    return retCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == 0)
        return;
    
    self.currentOpComment = _displayedCommentList[indexPath.row];
    [self displayCommentMenu];
}


#pragma mark - data handle


- (void)synthesizeCommentList
{
    self.displayedCommentList = [self.dataArray arrayByAddingObjectsFromArray:_sentCommentList];
}

- (void)filterSentComment
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (UMComComment *comment in _sentCommentList) {
        UMComComment *lastComment = [self.dataArray lastObject];
        if ([comment.floor integerValue] >= [lastComment.floor integerValue]) {
            [indexSet addIndex:[_sentCommentList indexOfObject:comment]];
        }
    }
    [_sentCommentList removeObjectsAtIndexes:indexSet];
}

- (void)handleCoreDataDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        self.dataArray = data;
        [_sentCommentList removeAllObjects];
        self.displayedCommentList = self.dataArray;
    }
    if (finishHandler) {
        finishHandler();
    }
}

- (void)handleServerDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        self.dataArray = data;
        [_sentCommentList removeAllObjects];
        self.displayedCommentList = self.dataArray;
    }
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
        [self filterSentComment];
        [self synthesizeCommentList];
    }
    if (finishHandler) {
        finishHandler();
    }
}

- (void)refreshData
{
    [self requestPostData];
    [super refreshData];
}

#pragma mark - Notification
- (void)onReceivePostDeleteNotification:(NSNotification *)note
{
    UMComFeed *feed = [note object];
    if (![feed isKindOfClass:[UMComFeed class]] || ![feed.feedID isEqualToString:_feed.feedID]) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewController:action:object:)]) {
        [_delegate viewController:self action:UMPostContentViewActionDelete object:_feed];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
