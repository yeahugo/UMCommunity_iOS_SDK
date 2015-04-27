//
//  UMComFilterTopicsViewCell.h
//  UMCommunity
//
//  Created by luyiyuan on 14/9/29.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UMComTopic;

@interface UMComFilterTopicsViewCell : UITableViewCell
@property (nonatomic,strong) IBOutlet UILabel *labelName;
@property (nonatomic,strong) IBOutlet UILabel *labelDesc;
@property (nonatomic,strong) IBOutlet UIButton *butFocuse;

@property (nonatomic,assign) BOOL isRecommendTopic;

- (void)setWithTopic:(UMComTopic *)topic;

- (IBAction)actionFocuse:(id)sender;
@end
