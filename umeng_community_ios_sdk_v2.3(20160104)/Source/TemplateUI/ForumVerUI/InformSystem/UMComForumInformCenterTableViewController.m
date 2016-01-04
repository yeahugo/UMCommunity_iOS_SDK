//
//  UMComNotificationCenterTableViewViewController.m
//  UMCommunity
//
//  Created by umeng on 15/11/30.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumInformCenterTableViewController.h"
#import "UMComTools.h"
#import "UIViewController+UMComAddition.h"
#import "UMComPushRequest.h"
#import "UMComSession.h"
#import "UMComUnReadNoticeModel.h"

#define UMCom_Forum_InfoCenter_Cell_Height 65//Cell的高度
#define UMCom_Forum_InfoCenter_IconText_Space 10//icon跟文字的间距
#define UMCom_Forum_InfoCenter_DotArrow_Space 10//红点跟箭头的间距
#define UMCom_Forum_InfoCenter_Arrow_Width 13   //箭头的宽度
#define UMCom_Forum_InfoCenter_Arrow_RightEdge 20//箭头跟右边缘的距离
#define UMCom_Forum_InfoCenter_Dot_Diameter 10//红点的直径
#define UMCom_Forum_InfoCenter_Icon_TopEdge 10//icon的上下边距
#define UMCom_Forum_InfoCenter_Text_Font 16 //文字大小
#define UMCom_Forum_InfoCenter_CellLine_Color  @"#EEEFF3" //分割线颜色
#define UMCom_Forum_InfoCenter_Text_Color  @"#333333" //文字内容颜色
#define UMCom_Forum_InfoCenter_TableView_BgColor @"#F5F6FA" //当前页面的背景颜色

@interface UMComForumInformCenterTableViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, strong) NSArray *images;

@property (nonatomic, strong) NSArray *viewControllerClasses;

@property (nonatomic, strong)  UITableView *tableView;


@end

@implementation UMComForumInformCenterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setForumUIBackButton];
    [self setForumUITitle:UMComLocalizedString(@"UM_Forum_Notification", @"消息")];
    
    self.titles = [NSArray arrayWithObjects:@"评论",@"赞",@"通知",@"管理员私信", nil];
    self.images = [NSArray arrayWithObjects:@"um_forum_notice_comment",@"um_forum_notice_like",@"um_forum_notice_systemnotice",@"um_forum_notice_privateletter", nil];
    self.viewControllerClasses = [NSArray arrayWithObjects:@"UMComForumCommentViewController",@"UMComForumLikesTableViewController",@"UMComForumSysNoticeTableViewController",@"UMComForumPrivateLetterTableViewController", nil];
    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
    tableView.rowHeight = UMCom_Forum_InfoCenter_Cell_Height;
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    [tableView reloadData];
    tableView.tableFooterView = [UIView new];
    tableView.backgroundColor = UMComColorWithColorValueString(UMCom_Forum_InfoCenter_TableView_BgColor);
    _tableView = tableView;
    [self refreshMessageData:nil];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)refreshMessageData:(id)sender
{
    __weak typeof (self) weakSelf = self;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [UMComPushRequest requestConfigDataWithResult:^(id responseObject, NSError *error) {
        [weakSelf.tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUMComUnreadNotificationRefreshNotification object:nil userInfo:responseObject];
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UMComInformListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UMComInformListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId cellSize:CGSizeMake(tableView.frame.size.width, tableView.rowHeight)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    UMComUnReadNoticeModel *unreadMessage = [UMComSession sharedInstance].unReadNoticeModel;
    BOOL isShowNotice = NO;
    if (indexPath.row == 0 && unreadMessage.notiByCommentCount > 0) {
        isShowNotice = YES;
    }else if (indexPath.row == 1 && unreadMessage.notiByLikeCount > 0){
        isShowNotice = YES;
    }else if (indexPath.row == 2 && unreadMessage.notiByAdministratorCount > 0){
        isShowNotice = YES;
    }else if (indexPath.row == 3 && unreadMessage.notiByPriMessageCount > 0){
        isShowNotice = YES;
    }
    [cell reloadCellWithImage:UMComImageWithImageName(self.images[indexPath.row])
                        title:self.titles[indexPath.row]
                     isNotice:isShowNotice];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Class class = NSClassFromString(self.viewControllerClasses[indexPath.row]);
    UIViewController *viewController = [[class alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
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



@implementation UMComInformListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                     cellSize:(CGSize)size
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat imageStart = UMCom_Forum_InfoCenter_Icon_TopEdge;
        CGFloat imageWidth = size.height-imageStart*2;
        self.iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, imageStart, imageWidth, imageWidth)];
        self.iconImageView.layer.cornerRadius = imageWidth/2;
        self.iconImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.iconImageView];
        
        CGFloat titleLeftEgde = self.iconImageView.frame.origin.x+self.iconImageView.frame.size.width + UMCom_Forum_InfoCenter_IconText_Space;
        CGFloat dotAndArrowWidt = UMCom_Forum_InfoCenter_Dot_Diameter + UMCom_Forum_InfoCenter_DotArrow_Space + UMCom_Forum_InfoCenter_Arrow_Width + UMCom_Forum_InfoCenter_Arrow_RightEdge;
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(titleLeftEgde, 0, size.width-titleLeftEgde-dotAndArrowWidt, size.height)];
        self.titleLabel.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_InfoCenter_Text_Font);
        [self.contentView addSubview:self.titleLabel];
        
        CGFloat indicatorWidth = UMCom_Forum_InfoCenter_Dot_Diameter;
        self.noticeIndicator = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, indicatorWidth, indicatorWidth)];
        self.noticeIndicator.layer.cornerRadius = indicatorWidth/2;
        self.noticeIndicator.clipsToBounds = YES;
        self.noticeIndicator.center = CGPointMake(self.titleLabel.frame.size.width+self.titleLabel.frame.origin.x, size.height/2);
        self.noticeIndicator.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:self.noticeIndicator];
        

        UIImage *acceImage = UMComImageWithImageName(@"um_forum_arrow_gray");
        CGFloat acceImageWidth = UMCom_Forum_InfoCenter_Arrow_Width;
        CGFloat accessoryViewHeight = acceImage.size.height * acceImageWidth/acceImage.size.width;
        
        UIImageView *accessoryView = [[UIImageView alloc]initWithFrame:CGRectMake(self.noticeIndicator.frame.origin.x+self.noticeIndicator.frame.size.width + UMCom_Forum_InfoCenter_DotArrow_Space, size.height/2-accessoryViewHeight/2, acceImageWidth, accessoryViewHeight)];
        accessoryView.image = UMComImageWithImageName(@"um_forum_arrow_gray");
        self.accessoryView = accessoryView;

    }
    return self;
}

- (void)reloadCellWithImage:(UIImage *)image
                      title:(NSString *)title
                   isNotice:(BOOL)isNotice
{
    self.iconImageView.image = image;
    self.titleLabel.text = title;
    self.noticeIndicator.hidden = !isNotice;

}

@end
