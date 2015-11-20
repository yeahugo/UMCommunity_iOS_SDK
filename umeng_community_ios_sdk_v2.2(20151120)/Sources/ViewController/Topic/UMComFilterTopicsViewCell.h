//
//  UMComFilterTopicsViewCell.h
//  UMCommunity
//
//  Created by luyiyuan on 14/9/29.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UMComClickActionDelegate;

@class UMComTopic,UMComImageView;

@interface UMComFilterTopicsViewCell : UITableViewCell
@property (nonatomic,strong) IBOutlet UILabel *labelName;
@property (nonatomic,strong) IBOutlet UILabel *labelDesc;
@property (nonatomic,strong) IBOutlet UIButton *butFocuse;

@property (nonatomic,strong) UMComTopic *topic;


@property (nonatomic,strong) UMComImageView *topicIcon;

@property (nonatomic,assign) BOOL isRecommendTopic;

@property (nonatomic, copy) void (^clickOnTopic)(UMComTopic *topic);

@property (nonatomic, weak) id<UMComClickActionDelegate>delegate;

- (void)setWithTopic:(UMComTopic *)topic;

- (void)setFocused:(BOOL)focused;

- (IBAction)actionFocuse:(id)sender;
@end
