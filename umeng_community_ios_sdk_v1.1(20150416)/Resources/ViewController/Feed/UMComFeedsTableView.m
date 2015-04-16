//
//  UMComFeedsTableView.m
//  UMCommunity
//
//  Created by Gavin Ye on 12/5/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComFeedsTableView.h"
#import "UMComFeedsTableViewCell.h"
#import "UMComUser.h"
#import "UMComFeedTableViewController.h"
#import "UMComShowToast.h"
#import "UMComAction.h"

//评论内容长度
#define kCommentLenght 140

@interface UMComFeedsTableView()
{
    BOOL _loadingMore;
}



@end

#define kFetchLimit 20

@implementation UMComFeedsTableView
{
    BOOL keyboardHiden;
    UILabel *noticeLabel;
    UILabel *noRecommendTip;
    
}
static int HeaderOffSet = -90;//-120

- (void)initTableView
{
    NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"UMComCommentInput" owner:self options:nil];
    //得到第一个UIView
    UIView *commentInputView = [nib objectAtIndex:0];
    self.commentInputView = commentInputView;
    self.commentTextField = [commentInputView.subviews objectAtIndex:0];
    self.commentTextField.delegate = self;
    
    [self registerNib:[UINib nibWithNibName:@"UMComFeedsTableViewCell" bundle:nil] forCellReuseIdentifier:@"FeedsTableViewCell"];
    
    self.delegate = self;
    self.resultArray = [NSMutableArray arrayWithCapacity:1];
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.center = CGPointMake(self.frame.size.width/2, -20);
    [self addSubview:self.indicatorView];
    
    self.heightDictionary = [[NSMutableDictionary alloc] init];
    self.showCommentDictionary = [[NSMutableDictionary alloc] init];
    
    self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, BottomLineHeight)];
    self.footView.backgroundColor = [UIColor clearColor];
    self.tableFooterView = self.footView;
    keyboardHiden = YES;
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initTableView];
    }
    return self;
}

-(void)awakeFromNib
{
    [self initTableView];
    [super awakeFromNib];
}

- (void)reloadRowAtIndex:(NSIndexPath *)indexPath
{
    [self.heightDictionary removeAllObjects];
    if ([self cellForRowAtIndexPath:indexPath]) {
        [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (BOOL)isShowAllComment:(int)indexRow
{
    BOOL returnResult = NO;
    NSString *key = [NSString stringWithFormat:@"%d",indexRow];
    if ([self.showCommentDictionary valueForKey:key]) {
        returnResult = YES;
    }
    return returnResult;
}

- (void)setShowAllComment:(int)indexRow
{
    NSString *key = [NSString stringWithFormat:@"%d",indexRow];
    [self.showCommentDictionary setValue:@YES forKey:key];
}


- (void)dismissAllEditView
{
    keyboardHiden = YES;
    [self.commentInputView removeFromSuperview];
    [self.commentTextField removeFromSuperview];
    [self.commentTextField resignFirstResponder];
    [self dismissAllEditBackGround];
}

-(void)dismissAllEditBackGround
{
    //消除弹出的编辑按钮
    for (int i = 0; i < [self numberOfRowsInSection:0]; i++) {
        UMComFeedsTableViewCell *cell = (UMComFeedsTableViewCell *)[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [cell dissMissEditBackGround];
    }
}

-(void)presentEditView:(id)object selectedCell:(UMComFeedsTableViewCell *)cell
{
    if ([object isKindOfClass:[NSString class]]) {
        [self presentEditView:(NSString *)object];
  
    }else if ([object isKindOfClass:[UMComComment class]]){
        [self presentReplyView:(UMComComment *)object];
    }
    self.selectedCell = cell;
}


-(void)presentEditView:(NSString *)feedId
{
    self.commentTextField.delegate = self;
    self.commentTextField.text = @"";
    if (keyboardHiden) {
        self.commentTextField.center = CGPointMake(self.frame.size.width/2, self.frame.size.height);
    }
    [self.window addSubview:self.commentInputView];
    [self.window addSubview:self.commentTextField];
    self.commentFeedId = feedId;
    
    self.commentUserId = nil;
    NSString *chContent = [NSString stringWithFormat:@"评论内容不能超过%d个字符",kCommentLenght];
    NSString *enContent = [NSString stringWithFormat:@"Content must not exceed %d characters",kCommentLenght];
    self.commentTextField.placeholder = UMComLocalizedString(enContent,chContent);
    
    [self.commentTextField becomeFirstResponder];
    self.commentTextField.hidden = NO;
}

- (void)presentReplyView:(UMComComment *)comment;
{

    self.commentTextField.delegate = self;
    self.commentTextField.text = @"";
    self.commentTextField.placeholder = [NSString stringWithFormat:@"回复%@",[[comment creator] name]];
    if (keyboardHiden) {
        self.commentTextField.center = CGPointMake(self.frame.size.width/2, self.frame.size.height);
    }
    [self.window addSubview:self.commentInputView];
    [self.window addSubview:self.commentTextField];
    self.commentFeedId = comment.feed.feedID;
    self.commentUserId = comment.creator.uid;
    self.commentTextField.hidden = NO;
    [self.commentTextField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //2015.01.27 djx add [用户输入内容长度判断] start
    if (textField.text == nil || textField.text.length == 0) {
         [[[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"Sorry",@"抱歉") message:UMComLocalizedString(@"Empty_Text",@"内容不能为空") delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK",@"好") otherButtonTitles:nil] show];
        return NO;
    }
    if (textField.text.length > kCommentLenght) {
        NSString *chContent = [NSString stringWithFormat:@"评论内容不能超过%d个字符",kCommentLenght];
        NSString *enContent = [NSString stringWithFormat:@"Content must not exceed %d characters",kCommentLenght];
        [[[UIAlertView alloc]
          initWithTitle:UMComLocalizedString(@"Sorry",@"抱歉") message:UMComLocalizedString(enContent,chContent) delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK",@"好") otherButtonTitles:nil] show];
        return NO;
    }
    UMComFeedTableViewController *feedTableViewController = (UMComFeedTableViewController *)self.feedTableViewController;
    [feedTableViewController postCommentContent:textField.text feedID:self.commentFeedId
                                commentUid:self.commentUserId completion:^(NSError *error) {
                                    [self refreshFeedsComments:self.commentFeedId];
                                }];
    [self.commentTextField removeFromSuperview];
    [self.commentInputView removeFromSuperview];
    [self.commentTextField resignFirstResponder];
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length != 0 && textField.text.length >= kCommentLenght) {
        if (!noticeLabel) {
            noticeLabel = [[UILabel alloc]initWithFrame:textField.frame];
            [textField.superview addSubview:noticeLabel];
            noticeLabel.text = [NSString stringWithFormat:@"评论内容不能超过%d个字符",kCommentLenght];
            noticeLabel.backgroundColor = [UIColor clearColor];
            noticeLabel.textAlignment = NSTextAlignmentCenter;
     
        }
        string=@"";
        noticeLabel.hidden = NO;
        self.commentTextField.hidden = YES;
        [self performSelector:@selector(hidenNoticeLabel) withObject:nil afterDelay:0.8f];
        return NO;
    }
    return YES;
}

- (void)hidenNoticeLabel
{
    noticeLabel.hidden = YES;
    self.commentTextField.hidden = NO;
}

- (void)refreshFeedsLike:(NSString *)feedId selectedCell:(UMComFeedsTableViewCell *)cell
{
    self.selectedCell = cell;
    _loadingMore = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    UMComFeedLikesRequest *feedLikesController = [[UMComFeedLikesRequest alloc] initWithFeedId:feedId count:TotalLikesSize];
    [feedLikesController fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        if ([data isKindOfClass:[NSArray class]]) {
            [self reloadRowAtIndex:cell.indexPath];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

- (void)refreshFeedsComments:(NSString *)feedId
{
    UMComFeedCommentsRequest *allCommentsController = [[UMComFeedCommentsRequest alloc] initWithFeedId:feedId count:TotalCommentsSize];
    [allCommentsController fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        if (data.count >= 5) {
            [self.selectedCell showMoreComments];
        }else{
            [self reloadRowAtIndex:self.selectedCell.indexPath];
        }
    }];
}

- (void)addFootView{

    self.footerIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.footerIndicatorView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height+60);
    //暂时隐藏
    self.footerIndicatorView.hidden = YES;
    [self addSubview:self.footerIndicatorView];
}

-(void)refreshFeedsData
{
    _loadingMore = YES;
    
    UMComFeedTableViewController *feedTableViewController = (UMComFeedTableViewController *)self.feedTableViewController;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [feedTableViewController.fetchFeedsController fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        _loadingMore = NO;
        [feedTableViewController.indicatorView stopAnimating];
        self.resultArray = [NSMutableArray arrayWithArray:data];
        [self.showCommentDictionary removeAllObjects];
        [self.heightDictionary removeAllObjects];
        if (data.count > 0) {
            noRecommendTip.hidden = YES;
            self.footView.backgroundColor = TableViewSeparatorRGBColor;
        }else{
            if (error) {
                noRecommendTip.hidden = YES;
                [UMComShowToast fetchFeedFail:error];
            }else{
                if ([feedTableViewController.fetchFeedsController isKindOfClass:[UMComRecommendFeedsRequest class]]) {
                    if (noRecommendTip == nil) {
                        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height/2-20, self.frame.size.width,40)];
                        label.backgroundColor = [UIColor clearColor];
                        label.text = @"暂时没有推荐消息咯";
                        label.textAlignment = NSTextAlignmentCenter;
                        [self addSubview:label];
                        noRecommendTip = label;
                    }else{
                        noRecommendTip.hidden = NO;
                    }
  
                }else{
                    noRecommendTip.hidden = YES;
                }
                
            }
            self.footView.backgroundColor = [UIColor clearColor];
        }
        [self reloadData];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}


- (void)reloadData
{
    [self.heightDictionary removeAllObjects];
    [super reloadData];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    keyboardHiden = NO;
    
    float endheight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self.commentInputView.frame = CGRectMake(0, self.commentInputView.frame.origin.y, self.frame.size.width, self.commentInputView.frame.size.height);
    self.commentTextField.frame = CGRectMake(10, self.commentTextField.frame.origin.y, self.commentInputView.frame.size.width-20, self.commentTextField.frame.size.height);
    
    self.commentInputView.center = CGPointMake(self.frame.size.width/2, self.window.frame.size.height - endheight - self.commentInputView.frame.size.height/2);
    self.commentTextField.center = self.commentInputView.center;
}



- (void)keyboardHiden:(NSNotification*)notification {
    keyboardHiden = YES;
}


- (UMComFeedTableViewController *)feedTableViewController
{
    UMComFeedTableViewController * feedTableViewController = (UMComFeedTableViewController *)self.dataSource;
    return feedTableViewController;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float cellHeight = 0;
    NSString *key = [NSString stringWithFormat:@"%d",(int)indexPath.row];
    if (self.heightDictionary.count > 0 && self.heightDictionary.count >= indexPath.row && [self.heightDictionary valueForKey:key]) {
        cellHeight = [[self.heightDictionary valueForKey:key] floatValue];
    } else {
        UMComFeed *feed = [self.resultArray objectAtIndex:indexPath.row];
        BOOL isShowAll = [(UMComFeedsTableView *)self isShowAllComment:(int)indexPath.row];
        cellHeight = [UMComFeedsTableViewCell getCellHeightWithFeed:feed isShowComment:isShowAll tableViewWidth:self.frame.size.width];
        if ([UIDevice currentDevice].systemVersion.floatValue < 7.0) {
            if (feed.likes.count == 1 && feed.comments.count ==
                0) {
                cellHeight = cellHeight + 10;
            }
        }
        [self.heightDictionary setValue:[NSNumber numberWithFloat:cellHeight] forKey:key];
    }
    return cellHeight;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [(UMComFeedsTableView *)self dismissAllEditView];
    float offset = scrollView.contentOffset.y;
    if (offset < HeaderOffSet) {
        [self.indicatorView startAnimating];
    }
    else if (self.resultArray.count >= kFetchLimit && offset + self.superview.frame.size.height > self.contentSize.height){
        [self.footerIndicatorView startAnimating];
    }
}



- (void)addTableViewData:(NSArray *)data
{
    NSInteger indexStart = self.resultArray.count;
    NSMutableArray * reloadArray = [NSMutableArray array];
    for (int i = 0; i < data.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(indexStart+i)  inSection:0];
        [reloadArray addObject:indexPath];
    }
    if (data.count> 0) {
        [self.heightDictionary removeAllObjects];
        [self.resultArray addObjectsFromArray:data];
        [self insertRowsAtIndexPaths:reloadArray withRowAnimation:UITableViewRowAnimationFade];
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.resultArray.count == 0) {
        self.footView.backgroundColor = [UIColor clearColor];
    }
    [(UMComFeedsTableView *)self dismissAllEditBackGround];
    float offset = scrollView.contentOffset.y;
    //下拉刷新
    if (offset < HeaderOffSet) {
        [self.indicatorView stopAnimating];
        [self refreshFeedsData];
    }
    //上拉加载更多
    else if (offset > 0 && scrollView.contentOffset.y > scrollView.contentSize.height - (scrollView.superview.frame.size.height - 65)) {
        if (!_loadingMore) {
            
            _loadingMore = YES;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
              UMComFeedTableViewController *feedTableViewController = (UMComFeedTableViewController *)self.feedTableViewController;
            [feedTableViewController loadMoreDataWithCompletion:^(NSArray *data,NSError *error) {
            } getDataFromWeb:^(NSArray *data, BOOL haveNextPage, NSError *error) {
                [self.footerIndicatorView stopAnimating];
                if (error) {
                    [UMComShowToast fetchMoreFeedFail:error];
                }
                _loadingMore = NO;
                [self addTableViewData:data];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                if (!haveNextPage) {
                    self.footerIndicatorView.hidden = YES;
                }
                if (!data) {
                    [UMComShowToast showNoMore];
                }
            }];
        }
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
