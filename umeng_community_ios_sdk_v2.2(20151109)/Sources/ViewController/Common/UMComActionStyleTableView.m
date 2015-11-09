//
//  UMComActionStyleTableView.m
//  UMCommunity
//
//  Created by umeng on 15/5/27.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComActionStyleTableView.h"
#import "UMComUser.h"
#import "UMComSession.h"
#import "UMComClickActionDelegate.h"
#import "UMComTools.h"


@interface UMComActionStyleTableView ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *imageNames;
@property (nonatomic, strong) UIView *bgView;
@end

@implementation UMComActionStyleTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 4;
        self.separatorColor = [UIColor clearColor];
        self.scrollEnabled = NO;
        self.scrollsToTop = NO;
        
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIApplication sharedApplication].keyWindow.frame.size.width, [UIApplication sharedApplication].keyWindow.frame.size.height)];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.2;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(actionSheetViewHidden)];
        [bgView addGestureRecognizer:tap];
        self.bgView = bgView;
        
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.layer.cornerRadius = 4;
    cell.layer.cornerRadius = 4;
    cell.backgroundColor = [UIColor whiteColor];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    if (indexPath.row == self.titles.count + 1){
        cell.textLabel.text = UMComLocalizedString(@"cancel", @"取消");
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = UMComFontNotoSansLightWithSafeSize(17);
        cell.textLabel.textColor = [UMComTools colorWithHexString:FontColorGray];
    }else if (indexPath.row == self.titles.count){
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        if (indexPath.row == 1) {
            cell.contentView.backgroundColor = TableViewSeparatorRGBColor;
        }
    }else {
        NSString *title = nil;
        NSString *imageName = nil;
        if (self.titles.count > 0 && self.imageNames > 0) {
            if (indexPath.row < self.titles.count) {
                title = [self.titles objectAtIndex:indexPath.row];
                imageName = [self.imageNames objectAtIndex:indexPath.row];
            }
            UIView *cellView = [self createCellViewWithTitle:title imageName:imageName];
            [cell.contentView addSubview:cellView];
        }
    }
    return cell;
}

- (UIView *)createCellViewWithTitle:(NSString *)title imageName:(NSString *)imageName
{
    
    UIView *cellContentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 38)];
    UIView *cellView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 38)];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 20, 20)];
    imageView.image = UMComImageWithImageName(imageName);
    [cellView addSubview:imageView];
    cellView.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, 40, 38)];
    label.font = UMComFontNotoSansLightWithSafeSize(17);
    label.textColor = [UMComTools colorWithHexString:FontColorGray];
    label.backgroundColor = [UIColor clearColor];
    [cellView addSubview:label];
    label.text = title;
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 38, self.frame.size.width, 2)];
    lineView.backgroundColor = TableViewSeparatorRGBColor;
    [cellContentView addSubview:cellView];
    cellView.center = CGPointMake(cellContentView.frame.size.width/2, 20);
    [cellContentView addSubview:lineView];
    cellContentView.center = CGPointMake(self.frame.size.width/2, 20);
    return cellContentView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.titles.count) {
        return 10;
    }
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self actionSheetViewHidden];
    if (indexPath.row < self.titles.count) {
        self.selectedTitle = self.titles[indexPath.row];
        if (self.didSelectedAtIndexPath) {
            self.didSelectedAtIndexPath(self.selectedTitle,indexPath);
        }
    }
    self.selectedIndex = indexPath.row;
}


- (void)setImageNameList:(NSArray *)imageNameList titles:(NSArray *)titles
{
    self.titles = titles;
    self.imageNames = imageNameList;
    [self reloadData];
}

- (void)showActionSheet
{
    CGFloat heigth = self.contentSize.height;
    [self removeFromSuperview];
    [self.bgView removeFromSuperview];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.bgView.hidden = NO;
    [window addSubview:self.bgView];
    [window addSubview:self];
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(self.frame.origin.x, window.frame.size.height-heigth, self.frame.size.width,heigth);
    }];
}

- (void)actionSheetViewHidden
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [UIView animateWithDuration:0.2 animations:^{
        self.bgView.hidden = YES;
        self.frame = CGRectMake(self.frame.origin.x, window.frame.size.height, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.bgView removeFromSuperview];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
