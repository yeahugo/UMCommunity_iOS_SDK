//
//  UMComFriendsTableViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 9/9/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComFriendsTableViewController.h"
#import "UMComUser.h"
#import "UMComSession.h"
#import "UMComPullRequest.h"
#import "UMComFriendTableViewCell.h"
#import "UMComShowToast.h"
#import "UIViewController+UMComAddition.h"

#define kFetchLimit 20

@interface UMComFriendsTableViewController ()

@property (nonatomic, weak) UMComEditViewModel *editViewModel;
@property (nonatomic, strong) NSArray *followers;
@property (nonatomic,strong) UMComHttpPagesUserFollowings *httpPagesUserFollowings;
@property (nonatomic, strong) UMComPullRequest *fetchedFollowersController;

@end

@implementation UMComFriendsTableViewController

-(id)initWithEditViewModel:(UMComEditViewModel *)editViewModel
{
    self = [super initWithNibName:@"UMComFriendsTableViewController" bundle:nil];
    self.editViewModel = editViewModel;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setBackButtonWithTitle:UMComLocalizedString(@"Back",@"返回")];
    [self setTitleViewWithTitle: UMComLocalizedString(@"FriendTitle",@"我的好友")];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"UMComFriendTableViewCell" bundle:nil] forCellReuseIdentifier:@"FriendTableViewCell"];
//    self.tableView.delegate = self;

    self.indicatorView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height/2);
    [self.indicatorView startAnimating];
    self.fetchedFollowersController = [[UMComFollowersRequest alloc] initWithUid:[UMComSession sharedInstance].uid count:TotalFriendSize];
    [self.fetchedFollowersController fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        if (!error) {
            if (data.count > 0) {
                if ([[[UIDevice currentDevice] systemVersion]floatValue] < 8.0) {
                    self.footView.backgroundColor = TableViewSeparatorRGBColor;
                }
                self.followers = [NSArray arrayWithArray:data];
                [self.tableView reloadData];
            }else{
                [UMComShowToast fetchFriendsFail:nil];
            }

        }else{
            [UMComShowToast fetchFriendsFail:error];
        }
        [self.indicatorView stopAnimating];
    }];
    
    self.tableView.rowHeight = 50;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.followers.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FriendTableViewCell";
    UMComFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UMComUser *follower = [self.followers objectAtIndex:indexPath.row];
    NSString *iconUrl = [follower.icon_url valueForKey:@"240"];

    [cell.profileImageView setImageURL:iconUrl placeHolderImage:[UMComImageView placeHolderImageGender:follower.gender.integerValue]];
    cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width/2;
    cell.profileImageView.clipsToBounds = YES;

    [cell.nameLabel setText:follower.name];
    return cell;
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UMComUser *user = [self.followers objectAtIndex:indexPath.row];
    [self.editViewModel.followers addObject:user];
    [self.editViewModel editContentAppendKvoString:[NSString stringWithFormat:@"@%@ ",user.name]];
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
