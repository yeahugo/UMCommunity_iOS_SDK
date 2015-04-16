//
//  UMComUserTopicsView.h
//  UMCommunity
//
//  Created by luyiyuan on 14/10/21.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComUserTopicLabel.h"

@class UMComTopic;

@interface UMComUserTopicsView : UIView

- (void)setTopicsData:(NSArray *)data;
- (void)setTipText:(NSString *)tipText;

- (void)setTopicTapHandle:(TopicTapHandle)tapHandle;
@end
