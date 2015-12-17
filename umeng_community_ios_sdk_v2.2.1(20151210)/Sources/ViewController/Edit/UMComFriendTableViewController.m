//
//  UMComFriendsTableViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 9/9/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComFriendTableViewController.h"
#import "UMComUser.h"
#import "UMComSession.h"
#import "UMComPullRequest.h"
#import "UMComFriendTableViewCell.h"
#import "UMComShowToast.h"
#import "UIViewController+UMComAddition.h"
#import "UMComEditViewModel.h"
#import "UMComImageView.h"
#import "UMComRefreshView.h"
#import "UMComTableView.h"
#import "UMComUser+UMComManagedObject.h"


#define kFetchLimit 20

typedef void(^FriendsDataLoadFinishHandler)(NSArray *data, NSError *error);

@interface UMComFriendTableViewController ()< UMComRefreshViewDelegate>

@property (nonatomic, weak) UMComEditViewModel *editViewModel;

@end

@implementation UMComFriendTableViewController

-(id)initWithEditViewModel:(UMComEditViewModel *)editViewModel
{
    self = [super init];
    self.editViewModel = editViewModel;
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self setBackButtonWithImage];
    [self setTitleViewWithTitle: UMComLocalizedString(@"FriendTitle",@"我的好友")];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"UMComFriendTableViewCell" bundle:nil] forCellReuseIdentifier:@"FriendTableViewCell"];
    [self.tableView.indicatorView startAnimating];
    
    self.fetchRequest = [[UMComFollowersRequest alloc] initWithUid:[UMComSession sharedInstance].uid count:TotalFriendSize];
    
    [self.tableView loadAllData:nil fromServer:nil];
    self.tableView.rowHeight = 50;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FriendTableViewCell";
    UMComFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UMComUser *follower = [self.dataArray objectAtIndex:indexPath.row];
    NSString *iconUrl = [follower iconUrlStrWithType:UMComIconSmallType];

    [cell.profileImageView setImageURL:iconUrl placeHolderImage:[UMComImageView placeHolderImageGender:follower.gender.integerValue]];
    cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width/2;
    cell.profileImageView.clipsToBounds = YES;

    [cell.nameLabel setText:follower.name];
    return cell;
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UMComUser *user = [self.dataArray objectAtIndex:indexPath.row];
    [self.editViewModel.followers addObject:user];
    NSString *atFriendStr = @"";
    if (self.isShowFromAtButton == YES) {
        atFriendStr = @"@";
    }
    [self.editViewModel editContentAppendKvoString:[NSString stringWithFormat:@"%@%@ ",atFriendStr,user.name]];
    [self.navigationController popViewControllerAnimated:YES];
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
