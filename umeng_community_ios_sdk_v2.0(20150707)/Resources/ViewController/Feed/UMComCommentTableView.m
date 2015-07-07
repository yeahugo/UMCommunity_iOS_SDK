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

@interface UMComCommentTableView ()<UITableViewDataSource,  UITableViewDelegate>


@end

@implementation UMComCommentTableView
{
    CGFloat lastPosition;
}
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.reloadComments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"CommentTableViewCell";
    UMComCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
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

    if (self.scrollViewDidScroll) {
        self.scrollViewDidScroll(self,lastPosition);
    }
    lastPosition = scrollView.contentOffset.y;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.scrollViewDidScroll) {
        self.scrollViewDidScroll(self,lastPosition);
    }
}


- (void)reloadCommentTableViewArrWithComments:(NSArray *)reloadComments
{
    NSMutableArray *mutiStyleViewArr = [NSMutableArray array];
    int index = 0;
    for (UMComComment *comment in reloadComments) {
        NSMutableString * replayStr = [NSMutableString stringWithString:@""];
        NSMutableArray *clikDicts = [NSMutableArray arrayWithCapacity:1];
        if (comment.reply_user) {
            [replayStr appendString:@"回复"];
            NSRange range = NSMakeRange(replayStr.length, comment.reply_user.name.length+1);
            NSDictionary *dict = [NSDictionary dictionaryWithObject:comment.reply_user forKey:NSStringFromRange(range)];
            [clikDicts addObject:dict];
            [replayStr appendFormat:@"@%@：",comment.reply_user.name];

        }
        if (comment.content) {
            NSRange range = NSMakeRange(replayStr.length, comment.content.length);
            NSDictionary *dict = [NSDictionary dictionaryWithObject:comment forKey:NSStringFromRange(range)];
            [clikDicts addObject:dict];
            [replayStr appendFormat:@"%@",comment.content];
        }
        UMComMutiStyleTextView *commentStyleView = [UMComMutiStyleTextView rectDictionaryWithSize:CGSizeMake(self.frame.size.width-UMComCommentDeltalWidth, MAXFLOAT) font:UMComCommentTextFont attString:replayStr lineSpace:2 runType:UMComMutiTextRunCommentType clickArray:clikDicts];
        float height = commentStyleView.totalHeight + 5/2 + UMComCommentNamelabelHeght;
        commentStyleView.totalHeight  = height;
        [mutiStyleViewArr addObject:commentStyleView];
        index++;

    }
    self.commentStyleViewArray = mutiStyleViewArr;
    self.reloadComments = reloadComments;
}

@end

