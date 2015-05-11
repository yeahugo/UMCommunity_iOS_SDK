//
//  UMComUserCenterViewController.h
//  UMCommunity
//
//  Created by Gavin Ye on 9/10/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComUser.h"
#import "UMComImageView.h"
#import "UMComFeedTableViewController.h"
#import "UMComUserTopicsView.h"
#import "UMComUserCenterViewModel.h"

@interface UMComUserCenterViewController :UMComFeedTableViewController
//<UITableViewDataSource,UITableViewDelegate>

//上部
@property (strong, nonatomic) UMComImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIButton *focus;
@property (weak, nonatomic) IBOutlet UMComUserTopicsView *topicsView;

//中部
@property (weak, nonatomic) IBOutlet UILabel *feedNumber;
@property (weak, nonatomic) IBOutlet UIButton *feedButton;
@property (weak, nonatomic) IBOutlet UILabel *followerNumber;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *fanNumber;
@property (weak, nonatomic) IBOutlet UIButton *fanButton;

//下部
@property (weak, nonatomic) IBOutlet UMComFeedsTableView *feedsTableView;


@property (nonatomic, strong) UMComUserCenterViewModel *feedViewModel;

-(IBAction)onClickFoucus:(id)sender;

- (id)initWithUid:(NSString *)uid;

-(id)initWithUser:(UMComUser *)user;

-(IBAction)onClickFollowers:(id)sender;

-(IBAction)onClickFans:(id)sender;

@end
