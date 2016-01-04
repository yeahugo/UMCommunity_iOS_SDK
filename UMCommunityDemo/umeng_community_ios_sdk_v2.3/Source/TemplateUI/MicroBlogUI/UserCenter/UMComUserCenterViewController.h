//
//  UMComUserCenterViewController.h
//  UMCommunity
//
//  Created by Gavin Ye on 9/10/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComViewController.h"


@class UMComUser,UMComImageView,UMComUserTopicsView,UMComUserCenterViewModel;

@interface UMComUserCenterViewController :UMComViewController

//上部
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UMComImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIButton *focus;
@property (weak, nonatomic) IBOutlet UIView *topLine;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UILabel *albumLabel;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;

//中部
@property (weak, nonatomic) IBOutlet UILabel *feedNumber;
@property (weak, nonatomic) IBOutlet UIButton *feedButton;
@property (weak, nonatomic) IBOutlet UILabel *followerNumber;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *fanNumber;
@property (weak, nonatomic) IBOutlet UIButton *fanButton;

//下部

-(IBAction)onClickFoucus:(id)sender;

-(IBAction)onClickAlbum:(id)sender;

-(IBAction)onClickTopic:(id)sender;

-(id)initWithUser:(UMComUser *)user;

-(IBAction)onClickFollowers:(id)sender;

-(IBAction)onClickFans:(id)sender;



@end
