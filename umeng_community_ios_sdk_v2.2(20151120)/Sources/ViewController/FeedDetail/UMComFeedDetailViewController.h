//
//  UMComFeedDetailViewController.h
//  UMCommunity
//
//  Created by Gavin Ye on 11/13/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

typedef enum {
    UMComShowFromClickDefault = 0,
    UMComShowFromClickRemoteNotice = 1,
    UMComShowFromClickFeedText = 2,
    UMComShowFromClickComment = 3,
}UMComFeedDetailShowType;

#import "UMComFeedTableViewController.h"

@class UMComLikeListView,UMComFeed;

@interface UMComFeedDetailViewController : UMComFeedTableViewController

@property (nonatomic, strong) IBOutlet UIImageView *likeImageView;
@property (nonatomic, assign) UMComFeedDetailShowType showType;

- (id)initWithFeed:(UMComFeed *)feed;

- (id)initWithFeed:(NSString *)feedId
         commentId:(NSString *)commentId
         viewExtra:(NSDictionary *)viewExtra;

- (id)initWithFeed:(UMComFeed *)feed showFeedDetailShowType:(UMComFeedDetailShowType)type;
@property (strong, nonatomic) IBOutlet UIView *menuView;

@property (weak, nonatomic) IBOutlet UILabel *likeStatusLabel;


- (IBAction)didClickOnLike:(UITapGestureRecognizer *)sender;
- (IBAction)didClickOnForward:(UITapGestureRecognizer *)sender;
- (IBAction)didClikeObComment:(UITapGestureRecognizer *)sender;




@end


