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
@interface UMComActionStyleTableView ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *imageNames;
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
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.layer.cornerRadius = 4;
    cell.layer.cornerRadius = 4;
    cell.backgroundColor = [UIColor whiteColor];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    if (indexPath.row == 0) {
        if (self.titles.count > 0 && self.imageNames > 0) {
            NSString *title = [self.titles objectAtIndex:0];
            NSString *imageName = [self.imageNames objectAtIndex:0];
            UIView *cellView = [self createCellViewWithTitle:title imageName:imageName];
            cellView.center = CGPointMake(tableView.frame.size.width/2, 20);
            [cell.contentView addSubview:cellView];
        }
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, cell.contentView.frame.size.height-10, tableView.frame.size.width, 7)];
        view.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:view];
    }else if (indexPath.row == 1){
        cell.contentView.backgroundColor = TableViewSeparatorRGBColor;
        
    }else if (indexPath.row == 2){
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0,0, tableView.frame.size.width, 7)];
        view.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:view];
        if (self.titles.count > 1 && self.imageNames.count > 1) {
            NSString *title = [self.titles objectAtIndex:1];
            NSString *imageName = [self.imageNames objectAtIndex:1];
            UIView *cellView = [self createCellViewWithTitle:title imageName:imageName];
            cellView.center = CGPointMake(tableView.frame.size.width/2, 20);
            [cell.contentView addSubview:cellView];
        }
    }else if (indexPath.row == 3){
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }else if (indexPath.row == 4){
        cell.textLabel.text = UMComLocalizedString(@"cancel", @"取消");
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = UMComFontNotoSansLightWithSafeSize(17);
        cell.textLabel.textColor = [UMComTools colorWithHexString:FontColorGray];
    }
    return cell;
}

- (UIView *)createCellViewWithTitle:(NSString *)title imageName:(NSString *)imageName
{
    
    UIView *cellView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 20, 20)];
    imageView.image = [UIImage imageNamed:imageName];
    [cellView addSubview:imageView];
    cellView.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, 40, 40)];
    label.font = UMComFontNotoSansLightWithSafeSize(17);
    label.textColor = [UMComTools colorWithHexString:FontColorGray];
    label.backgroundColor = [UIColor clearColor];
    [cellView addSubview:label];
    label.text = title;
    return cellView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3) {
        return 10;
    }
    if (indexPath.row == 1) {
        return 2;
    }
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == 0) {
//        if (![self.feed.creator.uid isEqualToString:[UMComSession sharedInstance].loginUser.uid]) {
//            if (self.clickActionDelegate && [self.clickActionDelegate respondsToSelector:@selector(customObj:clickOnSpam:)]) {
//                [self.clickActionDelegate customObj:self clickOnSpam:self.feed];
//            }
//        } else {
//            if (self.clickActionDelegate && [self.clickActionDelegate respondsToSelector:@selector(customObj:clickOnDeleted:)]) {
//                [self.clickActionDelegate customObj:self clickOnDeleted:self.feed];
//            }
//        }
//    }else if (indexPath.row == 2){
//        
//        if (self.clickActionDelegate && [self.clickActionDelegate respondsToSelector:@selector(customObj:clickOnCopy:)]) {
//            [self.clickActionDelegate customObj:self clickOnCopy:self.feed];
//        }
//    }
    
    if (self.didSelectedAtIndexPath) {
        self.didSelectedAtIndexPath(self,indexPath);
    }
    self.selectedIndex = indexPath.row;
}


- (void)setImageNameList:(NSArray *)imageNameList titles:(NSArray *)titles
{
    self.titles = titles;
    self.imageNames = imageNameList;
    [self reloadData];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
