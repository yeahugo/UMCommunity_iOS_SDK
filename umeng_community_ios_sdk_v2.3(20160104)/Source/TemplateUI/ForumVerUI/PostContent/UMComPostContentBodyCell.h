//
//  UMComPostContentBodyCell.h
//  UMCommunity
//
//  Created by umeng on 12/8/15.
//  Copyright © 2015 Umeng. All rights reserved.
//

#import "UMComPostContentBaseCell.h"

typedef void (^UMComRefreshCellEventCallback)(NSUInteger height);

@interface UMComPostContentCell : UMComPostContentBaseCell

@property (nonatomic, strong) UMComRefreshCellEventCallback refreshBlock;

- (void)refreshLayoutWithCalculatedTextObj:(UMComMutiText *)textObj
                                   andFeed:(UMComFeed *)feed;

- (void)registerRefreshActionBlock:(UMComRefreshCellEventCallback)block;

- (void)updateActionButtonStatus;

- (void)cleanImageView;

@end
