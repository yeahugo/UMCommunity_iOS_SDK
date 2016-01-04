//
//  UMComPostEditViewController.h
//  UMCommunity
//
//  Created by umeng on 15/11/19.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComViewController.h"

@class UMComImageView, UMComAddedImageView, UMComLocationView, UMComEditTextView,UMComEditForwardView;
@class UMComFeedEntity, UMComFeed, UMComTopic;

@interface UMComPostingViewController : UMComViewController

@property (nonatomic, strong) UMComFeedEntity *editFeedEntity;

@property (nonatomic, copy) void (^postCreatedFinish)(UMComFeed *feed);


- (id)initWithTopic:(UMComTopic *)topic;

- (void)postContent;


@end

