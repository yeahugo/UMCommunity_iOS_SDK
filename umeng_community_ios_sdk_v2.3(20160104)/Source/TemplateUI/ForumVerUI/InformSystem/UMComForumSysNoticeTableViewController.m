//
//  UMComForumSystemNoticeTableViewController.m
//  UMCommunity
//
//  Created by umeng on 15/11/30.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumSysNoticeTableViewController.h"
#import "UMComImageView.h"
#import "UMComNotification.h"
#import "UMComPullRequest.h"
#import "UMComMutiStyleTextView.h"
#import "UMComImageUrl.h"
#import "UMComUser.h"
#import "UMComPostContentViewController.h"
#import "UMComUserCenterViewController.h"
#import "UIViewController+UMComAddition.h"
#import "UMComSession.h"
#import "UMComUnReadNoticeModel.h"


#define kUMCom_NoticeModel_key @"kUMCom_Notice_key"
#define kUMCom_NoticeMutiText_key @"kUMCom_NoticeMutiText_key"

#define UMCom_Forum_SysNotice_CellItems_RightEdge 10

#define UMCom_Forum_SysNotice_Icon_TopEdge 10
#define UMCom_Forum_SysNotice_Icon_LeftEdge 5
#define UMCom_Forum_SysNotice_Icon_Width  45

#define UMCom_Forum_SysNotice_IconName_Space 10
#define UMCom_Forum_SysNotice_Name_TopEdge 10
#define UMCom_Forum_SysNotice_Name_Height 30
#define UMCom_Forum_SysNotice_Name_TextFont 16
#define UMCom_Forum_SysNotice_Name_TextColor @"#333333"
#define UMCom_Forum_SysNotice_Date_TextFont 12
#define UMCom_Forum_SysNotice_Date_TextColor @"#A5A5A5"
#define UMCom_Forum_SysNotice_Date_Width    100
#define UMCom_Forum_SysNotice_Content_TextFont 14
#define UMCom_Forum_SysNotice_Content_LineSpace 2
#define UMCom_Forum_SysNotice_Content_TextColor @"#999999"


@interface UMComForumSysNoticeTableViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *notiList;

@end

@implementation UMComForumSysNoticeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setForumUITitle:UMComLocalizedString(@"UMCom_Forum_SysNotice", @"管理员通知")];
    
    self.notiList = [NSMutableArray array];
    self.tableView.rowHeight = 65;
    self.fetchRequest = [[UMComUserNotificationRequest alloc]initWithCount:BatchSize];
    [self loadAllData:nil fromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        [UMComSession sharedInstance].unReadNoticeModel.notiByAdministratorCount = 0;
    }];
    // Do any additional setup after loading the view.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.notiList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellID";
    UMComForumUserNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UMComForumUserNotificationCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId cellSize:CGSizeMake(tableView.frame.size.width, tableView.rowHeight)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *dict = self.notiList[indexPath.row];
    __weak typeof(self) weakSelf = self;
    cell.clickOnUserIcon = ^(){
        UMComUser *user = [[dict valueForKey:kUMCom_NoticeModel_key] valueForKey:@"creator"];
        UMComUserCenterViewController *userCenter = [[UMComUserCenterViewController alloc]initWithUser:user];
        [weakSelf.navigationController pushViewController:userCenter animated:YES];
    };
    [cell reloadCellWithNotification:[dict valueForKey:kUMCom_NoticeModel_key] styleView:[dict valueForKey:kUMCom_NoticeMutiText_key]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UMComMutiText *mutiText = [self.notiList[indexPath.row] valueForKey:kUMCom_NoticeMutiText_key];
    return mutiText.textSize.height + UMCom_Forum_SysNotice_Icon_TopEdge * 2 + UMCom_Forum_SysNotice_Name_Height + UMCom_Forum_SysNotice_Content_LineSpace;
}


#pragma mark - data handle
- (void)handleCoreDataDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        [self.indicatorView stopAnimating];
        for (UMComNotification *notiModel in data) {
             [self insertCellWithNotiModel:notiModel];;
        }
    }
}

- (void)handleServerDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    [self.indicatorView stopAnimating];
    if (!error && [data isKindOfClass:[NSArray class]]) {
        [self.notiList removeAllObjects];
        [self.tableView reloadData];
        
        for (UMComNotification *notiModel in data) {
            [self insertCellWithNotiModel:notiModel];
        }
    }
}

- (void)handleLoadMoreDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    [self.indicatorView stopAnimating];
    if (!error && [data isKindOfClass:[NSArray class]]) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataArray];
        [tempArray addObjectsFromArray:data];
        for (UMComNotification *notiModel in data) {
            [self insertCellWithNotiModel:notiModel];
        }
    }
}

- (void)insertCellWithNotiModel:(UMComNotification *)notiModel
{
    CGFloat textWidth = self.view.frame.size.width-(UMCom_Forum_SysNotice_IconName_Space+UMCom_Forum_SysNotice_Icon_Width + UMCom_Forum_SysNotice_CellItems_RightEdge + UMCom_Forum_SysNotice_Icon_LeftEdge);
    UMComMutiText *mutiText = [UMComMutiText mutiTextWithSize:CGSizeMake(textWidth, MAXFLOAT) font:UMComFontNotoSansLightWithSafeSize(UMCom_Forum_SysNotice_Content_TextFont) string:notiModel.content lineSpace:UMCom_Forum_SysNotice_Content_LineSpace checkWords:nil textColor:UMComColorWithColorValueString(UMCom_Forum_SysNotice_Content_TextColor)];
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setValue:notiModel forKey:kUMCom_NoticeModel_key];
    [dataDict setValue:mutiText forKey:kUMCom_NoticeMutiText_key];
    [self.notiList addObject:dataDict];
    NSInteger index = self.notiList.count - 1;
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ClickActionDelegate
- (void)customObj:(id)obj clickOnFeedText:(UMComFeed *)feed
{
    UMComPostContentViewController *postContent = [[UMComPostContentViewController alloc]initWithFeed:feed];
    [self.navigationController pushViewController:postContent animated:YES];
}

- (void)customObj:(id)obj clickOnUser:(UMComUser *)user
{
    UMComUserCenterViewController *userCenter = [[UMComUserCenterViewController alloc]initWithUser:user];
    [self.navigationController pushViewController:userCenter animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

@interface UMComForumUserNotificationCell ()


@end

@implementation UMComForumUserNotificationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)size
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat iconLeftEdge = UMCom_Forum_SysNotice_Icon_LeftEdge;
        CGFloat icoTopEdge = UMCom_Forum_SysNotice_Icon_TopEdge;
        CGFloat iconWidth = UMCom_Forum_SysNotice_Icon_Width;
        self.iconImageView = [[[UMComImageView imageViewClassName] alloc]initWithFrame:CGRectMake(iconLeftEdge, icoTopEdge, iconWidth, iconWidth)];
        self.iconImageView.clipsToBounds = YES;
        self.iconImageView.layer.cornerRadius = iconWidth/2;
        [self.contentView addSubview:self.iconImageView];
        self.iconImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didClickIcon:)];
        [self.iconImageView addGestureRecognizer:tap];
        
        CGFloat subViewsRightEdge = UMCom_Forum_SysNotice_CellItems_RightEdge;
        CGFloat nameLabelHeight = UMCom_Forum_SysNotice_Name_Height;
        CGFloat dataLabelWidth = UMCom_Forum_SysNotice_Date_Width;
        CGFloat nameLabelLeftEdge = iconLeftEdge+iconWidth+UMCom_Forum_SysNotice_IconName_Space;
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabelLeftEdge, UMCom_Forum_SysNotice_Name_TopEdge, size.width-nameLabelLeftEdge-subViewsRightEdge-dataLabelWidth, nameLabelHeight)];
        self.nameLabel.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_SysNotice_Name_TextFont);
        self.nameLabel.textColor = UMComColorWithColorValueString(UMCom_Forum_SysNotice_Name_TextColor);
        [self.contentView addSubview:self.nameLabel];
        
        self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLabel.frame.size.width+self.nameLabel.frame.origin.x, self.nameLabel.frame.origin.y, dataLabelWidth, self.nameLabel.frame.size.height)];
        self.dateLabel.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_SysNotice_Date_TextFont);
        self.dateLabel.numberOfLines = 0;
        self.dateLabel.textAlignment = NSTextAlignmentRight;
        self.dateLabel.textColor = UMComColorWithColorValueString(UMCom_Forum_SysNotice_Date_TextColor);
        [self.contentView addSubview:self.dateLabel];
        
        self.contentTextView = [[UMComMutiStyleTextView alloc]init];
        _contentTextView.backgroundColor =[UIColor clearColor];
        [self.contentView addSubview:_contentTextView];
    }
    return self;
}


- (void)reloadCellWithNotification:(UMComNotification *)notification styleView:(UMComMutiText *)mutiText
{
    UMComUser *user = notification.creator;
    NSString *iconUrl = user.icon_url.small_url_string;
    [self.iconImageView setImageURL:iconUrl placeHolderImage:[UMComImageView placeHolderImageGender:user.gender.integerValue]];
    self.nameLabel.text = user.name;
    self.dateLabel.text = createTimeString(notification.create_time);
    self.contentTextView.frame = CGRectMake(self.nameLabel.frame.origin.x, self.nameLabel.frame.size.height + self.nameLabel.frame.origin.y, mutiText.textSize.width, mutiText.textSize.height);
    [self.contentTextView setMutiStyleTextViewWithMutiText:mutiText];
    self.contentTextView.clickOnlinkText = ^(UMComMutiStyleTextView *styleView,UMComMutiTextRun *run){
    };
}

- (void)didClickIcon:(id)user
{
    if (self.clickOnUserIcon) {
        self.clickOnUserIcon();
    }
}

@end
