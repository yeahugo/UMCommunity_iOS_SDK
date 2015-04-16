//
//  UMComOneFeedViewController.h
//  UMCommunity
//
//  Created by Gavin Ye on 9/12/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComFeedTableViewController.h"
#import "UMComTopic.h"

@interface UMComTopicFeedViewController : UMComFeedTableViewController
<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *topicDescription;

@property (nonatomic, weak) IBOutlet UIButton *followButton;

@property (nonatomic, strong) IBOutlet UIView * followViewBackground;

@property (nonatomic, strong) UMComTopic *topic;

-(IBAction)onClickFollow:(id)sender;

-(id)initWithTopic:(UMComTopic *)topic;

@property (weak, nonatomic) IBOutlet UIButton *editButton;

- (IBAction)onClickEdit:(id)sender;



- (IBAction)onClickTopicFeedsButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *topicFeedBt;

- (IBAction)onClickHotUserFeedsButton:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *hotUserBt;


@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;

@property (weak, nonatomic) IBOutlet UIView *selectedBgView;


@property (weak, nonatomic) IBOutlet UIView *focuBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *selectedSuperView;


@end
