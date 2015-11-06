//
//  UMComLikeUserViewController.m
//  UMCommunity
//
//  Created by umeng on 15/5/27.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComLikeUserViewController.h"
#import "UMComUser.h"
#import "UMComTools.h"
#import "UIViewController+UMComAddition.h"
#import "UMComAction.h"
#import "UMComPullRequest.h"
#import "UMComLike.h"
#import "UMComImageView.h"
#import "UMComFeed.h"
#import "UMComUserCenterViewController.h"
#import "UMComTableView.h"


@interface UMComLikeUserViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation UMComLikeUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setBackButtonWithImage];
    [self setTitleViewWithTitle:UMComLocalizedString(@"Like_User_List", @"点赞狂们")];
    // Do any additional setup after loading the view from its nib.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.likeUserList.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UMComLikeUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UMComLikeUserTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.portrait.layer.cornerRadius = cell.portrait.frame.size.width/2;
    cell.portrait.clipsToBounds = YES;
    if (indexPath.row == 0) {
        cell.contentView.backgroundColor = [UMComTools colorWithHexString:ViewGrayColor];
        cell.portrait.layer.cornerRadius = 0;
        cell.portrait.frame = CGRectMake(20, cell.frame.size.height/2-7.5, 16, 15);
        cell.portrait.image = [UIImage imageNamed:@"um_like+"];
        cell.nameLabel.text = [NSString stringWithFormat:@"%d",(int)[self.feed.likes_count  intValue]];
        cell.nameLabel.textColor = [UIColor blackColor];
    }else{
        cell.contentView.backgroundColor = [UIColor whiteColor];
        UMComUser *user = self.likeUserList[indexPath.row-1];
        cell.nameLabel.text = user.name;
        cell.nameLabel.textColor = [UMComTools colorWithHexString:FontColorBlue];
        NSString *iconUrl = [user.icon_url valueForKey:@"240"];
        CGFloat imageWidth = 25;
        CGFloat imageOriginX = 15;
        CGFloat imageOriginY = cell.frame.size.height/2-imageWidth/2;
        cell.portrait.frame = CGRectMake(imageOriginX, imageOriginY, imageWidth, imageWidth);
        [cell.portrait setImageURL:iconUrl placeHolderImage:[UMComImageView placeHolderImageGender:user.gender.integerValue]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > 0) {
        UMComUser *user = self.likeUserList[indexPath.row-1];
        [[UMComAction action] performActionAfterLogin:user viewController:self completion:^(NSArray *data, NSError *error) {
            if (!error) {
                UMComUserCenterViewController *userCenterVc = [[UMComUserCenterViewController alloc]initWithUser:user];
                [self.navigationController pushViewController:userCenterVc animated:YES];
            }
        }];
    }
}

#pragma mark - handle data

- (void)handleCoreDataDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if ([data isKindOfClass:[NSArray class]] && data.count > 0) {
        NSMutableArray *likeData = [NSMutableArray array];
        for (UMComLike *like in data) {
            if (like.creator) {
                [likeData addObject:like.creator];
            }
            
        }
        self.dataArray = data;
        self.likeUserList = likeData;
        if (finishHandler) {
            finishHandler();
        }else{
            [self.tableView reloadData];
        }
    }
}

- (void)handleServerDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if ([data isKindOfClass:[NSArray class]] && data.count > 0) {
        NSMutableArray *likeData = [NSMutableArray array];
        for (UMComLike *like in data) {
            if (like.creator) {
                [likeData addObject:like.creator];
            }
            
        }
        self.dataArray = data;
        self.likeUserList = likeData;
        if (finishHandler) {
            finishHandler();
        }else{
            [self.tableView reloadData];
        }
    }
}

- (void)handleLoadMoreDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if ([data isKindOfClass:[NSArray class]] && data.count > 0) {
        NSMutableArray *likeData = [NSMutableArray array];
        NSMutableArray *tempData = [NSMutableArray array];
        [tempData addObjectsFromArray:self.dataArray];
        [likeData addObjectsFromArray:self.likeUserList];
        for (UMComLike *like in data) {
            if (like.creator) {
                [likeData addObject:like.creator];
            }
            [tempData addObject:like];
        }
        self.likeUserList = likeData;
        self.dataArray = tempData;
        [self.tableView reloadData];
    }
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


@implementation UMComLikeUserTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat imageWidth = 25;
        CGFloat imageOriginX = 15;
        CGFloat imageOriginY = self.frame.size.height/2-imageWidth/2;
        self.portrait = [[[UMComImageView imageViewClassName] alloc]initWithFrame:CGRectMake(imageOriginX, imageOriginY, imageWidth, imageWidth)];
        [self.contentView addSubview:self.portrait];
        
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(imageOriginX+imageWidth+10, imageOriginY, self.contentView.frame.size.width-imageWidth-2*imageOriginX-10, imageWidth)];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [UMComTools colorWithHexString:FontColorBlue];
        self.nameLabel.font = UMComFontNotoSansLightWithSafeSize(15);
        [self.contentView addSubview:self.nameLabel];
    }
    return self;
}

@end
