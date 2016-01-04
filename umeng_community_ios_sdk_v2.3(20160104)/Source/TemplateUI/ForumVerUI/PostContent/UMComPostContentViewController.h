//
//  UMComPostContentViewController.h
//  UMCommunity
//
//  Created by umeng on 12/2/15.
//  Copyright © 2015 Umeng. All rights reserved.
//

#import "UMComRequestTableViewController.h"

typedef NS_ENUM(NSUInteger, UMComPostContentViewActionType)
{
    UMPostContentViewActionDelete,
    UMPostContentViewActionUpdateCount
};

@class UMComPostContentViewController;
@protocol UMComPostContentViewControllerDelegate <NSObject>

- (void)viewController:(UMComPostContentViewController *)viewController action:(UMComPostContentViewActionType)type object:(id)object;

@end

@class UMComFeed;
@interface UMComPostContentViewController : UMComRequestTableViewController

@property (nonatomic, weak) id<UMComPostContentViewControllerDelegate> delegate;

- (instancetype)initWithFeedID:(NSString *)feedID andCommentID:(NSString *)commentID;

- (instancetype)initWithFeed:(UMComFeed *)feed;

@end
