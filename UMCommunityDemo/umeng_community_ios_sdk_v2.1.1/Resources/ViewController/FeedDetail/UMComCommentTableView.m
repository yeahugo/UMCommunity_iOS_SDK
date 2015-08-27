//
//  UMComCommentTableView.m
//  UMCommunity
//
//  Created by umeng on 15/5/20.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComCommentTableView.h"
#import "UMComTools.h"
#import "UMComUser.h"
#import "UMComCommentTableViewCell.h"
#import "UMComComment.h"
#import "UMComMutiStyleTextView.h"
#import "UMComClickActionDelegate.h"
#import "UMComScrollViewDelegate.h"

@interface UMComCommentTableView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) CGPoint lastPosition;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation UMComCommentTableView


- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.scrollsToTop = NO;
        self.rowHeight = 56;
        [self registerNib:[UINib nibWithNibName:@"UMComCommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"CommentTableViewCell"];
        self.separatorColor = TableViewSeparatorRGBColor;
        
        if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
            [self setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([self respondsToSelector:@selector(setLayoutMargins:)])
        {
            [self setLayoutMargins:UIEdgeInsetsZero];
        }
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.indicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        self.indicatorView.frame = CGRectMake(self.frame.size.width/2-20, self.frame.size.height/2-20, 40, 40);
        [self addSubview:self.indicatorView];
        self.footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5)];
        self.footView.backgroundColor = TableViewSeparatorRGBColor;
        self.tableFooterView = self.footView;
    }
    return self;
}

#pragma mark - UITableViewDataSource
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didMoveToSuperview
{
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorView.frame = CGRectMake(0, 0, 40, 40);
    indicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    indicatorView.center = CGPointMake(self.superview.frame.size.width/2, kUMComRefreshOffsetHeight/2 + self.frame.origin.y);
    [self.superview addSubview:indicatorView];
    self.refreshIndicatorView = indicatorView;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.reloadComments.count == 0) {
        self.footView.backgroundColor = [UIColor clearColor];
    }else{
        self.footView.backgroundColor = TableViewSeparatorRGBColor;
    }
    return self.reloadComments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"CommentTableViewCell";
    UMComCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UMComComment *comment = self.reloadComments[indexPath.row];
    UMComMutiStyleTextView *styleView = self.commentStyleViewArray[indexPath.row];
    [cell reloadWithComment:comment commentStyleView:styleView];
    __weak typeof(self) weakSelf = self;
    cell.clickOnCommentContent = ^(UMComComment *comment){
        weakSelf.selectedComment = comment;
        weakSelf.replyUserId = comment.creator.uid;
    };
    cell.delegate = self.clickActionDelegate;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat commentTextViewHeight = 0;
 
    if (indexPath.row < self.commentStyleViewArray.count && indexPath.row < self.reloadComments.count) {
        UMComMutiStyleTextView *styleView = self.commentStyleViewArray[indexPath.row];
        commentTextViewHeight = styleView.totalHeight + 12;
    }
    return commentTextViewHeight;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < -65) {
        [self.superview bringSubviewToFront:self.refreshIndicatorView];
        [self.refreshIndicatorView startAnimating];
    }
    if (self.scrollViewDelegate && [self.scrollViewDelegate respondsToSelector:@selector(customScrollViewDidScroll:lastPosition:)]) {
        [self.scrollViewDelegate customScrollViewDidScroll:scrollView lastPosition:self.lastPosition];
    }
    self.lastPosition = scrollView.contentOffset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.scrollViewDelegate && [self.scrollViewDelegate respondsToSelector:@selector(customScrollViewDidEnd:lastPosition:)]) {
        [self.scrollViewDelegate customScrollViewDidEnd:scrollView lastPosition:self.lastPosition];
    }
    self.lastPosition = self.lastPosition;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{

    if (self.scrollViewDelegate && [self.scrollViewDelegate respondsToSelector:@selector(customScrollViewEndDrag:lastPosition:)]) {
        [self.scrollViewDelegate customScrollViewEndDrag:scrollView lastPosition:self.lastPosition];
    }
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
            checkWords = [NSMutableArray arrayWithObject:[NSString stringWithFormat:@"@%@",comment.creator.name]];
            [replayStr appendFormat:@"@%@：",comment.reply_user.name];
        }
        if (comment.content) {
            [replayStr appendFormat:@"%@",comment.content];
        }
        UMComMutiStyleTextView *commentStyleView = [UMComMutiStyleTextView rectDictionaryWithSize:CGSizeMake(self.frame.size.width-UMComCommentDeltalWidth, MAXFLOAT) font:UMComCommentTextFont attString:replayStr lineSpace:2 runType:UMComMutiTextRunCommentType checkWords:checkWords];
        float height = commentStyleView.totalHeight + 5/2 + UMComCommentNamelabelHeght;
        commentStyleView.totalHeight  = height;
        [mutiStyleViewArr addObject:commentStyleView];
        index++;

    }
    self.commentStyleViewArray = mutiStyleViewArr;
    self.reloadComments = reloadComments;
}

@end

