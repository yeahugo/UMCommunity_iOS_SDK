//
//  UMComPrivateLetterTableViewController.m
//  UMCommunity
//
//  Created by umeng on 15/11/30.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumPrivateLetterTableViewController.h"
#import "UMComImageView.h"
#import "UMComPullRequest.h"
#import "UMComSession.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComPrivateLetter.h"
#import "UMComPrivateMessage.h"
#import "UMComForumPrivateChatTableViewController.h"
#import "UMComUser+UMComManagedObject.h"
#import "UIViewController+UMComAddition.h"
#import "UMComImageUrl.h"
#import "UMComShowToast.h"


#define UMCom_Forum_LetterList_Cell_Height 65
#define UMCom_Forum_LetterList_IconName_Space 10
#define UMCom_Forum_LetterList_Icon_TopEdge 10
#define UMCom_Forum_LetterList_Icon_LeftEdge 10
#define UMCom_Forum_LetterList_Name_TextFont 16
#define UMCom_Forum_LetterList_Name_TextColor @"#333333"
#define UMCom_Forum_LetterList_Message_TextFont 13
#define UMCom_Forum_LetterList_Message_TextColor @"#999999"
#define UMCom_Forum_LetterList_Date_TextFont 12
#define UMCom_Forum_LetterList_Date_TextColor @"#A5A5A5"
#define UMCom_Forum_LetterList_DateLabel_Width 100
#define UMCom_Forum_LetterList_RedDot_Diameter 20
#define UMCom_Forum_LetterList_RedDot_TextFont 11
#define UMCom_Forum_letterList_RedDot_TextColor @"#FFFFFF"
#define UMCom_Forum_letterList_CellItems_RightEdge 10


@interface UMComForumPrivateLetterTableViewController ()

@end

@implementation UMComForumPrivateLetterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = UMCom_Forum_LetterList_Cell_Height;
    
    [self setForumUITitle:UMComLocalizedString(@"UM_Forum_Private_Letter_Title", @"私信管理员")];
    self.fetchRequest = [[UMComPrivateLetterRequest alloc]initWithCount:BatchSize];
    [self loadAllData:nil fromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
    }];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UMComForumSysNoticeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UMComForumSysNoticeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID cellSize:CGSizeMake(tableView.frame.size.width, tableView.rowHeight)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell reloadCellWithPrivateLetter:self.dataArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UMComForumPrivateChatTableViewController *privateViewController = [[UMComForumPrivateChatTableViewController alloc]initWithPrivateLetter:self.dataArray[indexPath.row]];//
    [self.navigationController pushViewController:privateViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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



@implementation UMComForumSysNoticeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)size
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat iconLeftEdge = UMCom_Forum_LetterList_Icon_LeftEdge;
        CGFloat icoTopEdge = UMCom_Forum_LetterList_Icon_TopEdge;
        CGFloat iconWidth = size.height - icoTopEdge*2;
        self.iconImageView = [[[UMComImageView imageViewClassName] alloc]initWithFrame:CGRectMake(iconLeftEdge, icoTopEdge, iconWidth, iconWidth)];
        self.iconImageView.clipsToBounds = YES;
        self.iconImageView.layer.cornerRadius = iconWidth/2;
        [self.contentView addSubview:self.iconImageView];
        CGFloat v_ImageWidth = 15;
        UIImageView *v_imageView = [[UIImageView alloc]initWithFrame:CGRectMake(iconLeftEdge+iconWidth - v_ImageWidth, iconLeftEdge+iconWidth - v_ImageWidth, v_ImageWidth, v_ImageWidth)];
        v_imageView.image = UMComImageWithImageName(@"um_forum_v_blue");
        [self.iconImageView addSubview:v_imageView];
        
        CGFloat subViewsRightEdge = UMCom_Forum_letterList_CellItems_RightEdge;
        CGFloat dataLabelWidth = UMCom_Forum_LetterList_DateLabel_Width;
        CGFloat redDotWidth = UMCom_Forum_LetterList_RedDot_Diameter;
        CGFloat nameLabelLeftEdge = iconLeftEdge+iconWidth+UMCom_Forum_LetterList_IconName_Space;
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabelLeftEdge, UMCom_Forum_LetterList_Icon_TopEdge, size.width-nameLabelLeftEdge-subViewsRightEdge-dataLabelWidth, (size.height - UMCom_Forum_LetterList_Icon_TopEdge)/2)];
        self.nameLabel.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_LetterList_Name_TextFont);
        self.nameLabel.textColor = UMComColorWithColorValueString(UMCom_Forum_LetterList_Name_TextColor);
        [self.contentView addSubview:self.nameLabel];
        
        self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLabel.frame.size.width+self.nameLabel.frame.origin.x, self.nameLabel.frame.origin.y, dataLabelWidth, self.nameLabel.frame.size.height)];
        self.dateLabel.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_LetterList_Date_TextFont);
        self.dateLabel.numberOfLines = 0;
        self.dateLabel.textAlignment = NSTextAlignmentRight;
        self.dateLabel.textColor = UMComColorWithColorValueString(UMCom_Forum_LetterList_Date_TextColor);
        [self.contentView addSubview:self.dateLabel];
        
        self.detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLabel.frame.origin.x, self.nameLabel.frame.size.height+self.nameLabel.frame.origin.y, size.width-iconWidth-iconLeftEdge*2-redDotWidth-subViewsRightEdge,  (size.height - UMCom_Forum_LetterList_Icon_TopEdge*2) - self.nameLabel.frame.size.height)];
        self.detailLabel.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_LetterList_Message_TextFont);
        self.detailLabel.textColor = UMComColorWithColorValueString(UMCom_Forum_LetterList_Message_TextColor);
        [self.contentView addSubview:self.detailLabel];
        
        self.redDotLabel = [[UILabel alloc]initWithFrame:CGRectMake(size.width - redDotWidth - subViewsRightEdge,0, redDotWidth, redDotWidth)];
        self.redDotLabel.center = CGPointMake(self.redDotLabel.center.x, self.detailLabel.center.y);
        self.redDotLabel.backgroundColor = [UIColor redColor];
        self.redDotLabel.layer.cornerRadius = redDotWidth/2;
        self.redDotLabel.clipsToBounds = YES;
        self.redDotLabel.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_LetterList_RedDot_TextFont);
        self.redDotLabel.textColor = UMComColorWithColorValueString(UMCom_Forum_letterList_RedDot_TextColor);
        self.redDotLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.redDotLabel];
        
    }
    return self;
}


- (void)reloadCellWithPrivateLetter:(UMComPrivateLetter *)privateLetter
{
    [self.iconImageView setImageURL:privateLetter.user.icon_url.small_url_string placeHolderImage:UMComImageWithImageName(@"um_forum_user_smile_gray")];
    self.nameLabel.text = privateLetter.user.name?privateLetter.user.name:@"无名客";
    self.dateLabel.text = privateLetter.update_time? privateLetter.update_time:[[NSDate date] description];
    self.detailLabel.text = privateLetter.last_message.content?privateLetter.last_message.content:@"这本该是最后一条信息的";
    int unreadCount = [privateLetter.unread_count intValue];
    if (unreadCount > 0) {
        self.redDotLabel.hidden = NO;
        NSString *unreadText = [NSString stringWithFormat:@"%d",unreadCount];
        self.redDotLabel.text = privateLetter.unread_count?unreadText:@"12";
    }else{
        self.redDotLabel.hidden = YES;
    }

}

@end

