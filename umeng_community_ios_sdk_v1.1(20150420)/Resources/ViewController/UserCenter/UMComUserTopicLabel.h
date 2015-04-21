//
//  UMComUserTopicLabel.h
//  UMCommunity
//
//  Created by luyiyuan on 14/10/21.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UMComTopic;

typedef void (^TopicTapHandle)(UMComTopic *topic);

@interface UMComUserTopicLabel : UIView

- (id)initWithText:(UMComTopic *)topic maxWidth:(CGFloat)maxWidth;
- (void)setTopicTapHandle:(TopicTapHandle)tapHandle;
@end
