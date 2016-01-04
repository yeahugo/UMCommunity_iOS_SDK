//
//  UMComPostCommentCell.h
//  UMCommunity
//
//  Created by umeng on 12/3/15.
//  Copyright © 2015 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComPostContentBaseCell.h"

@interface UMComPostContentCommentCell : UMComPostContentBaseCell

- (void)refreshLayoutWithCalculatedTextObj:(UMComMutiText *)textObj
                                andComment:(UMComComment *)comment;

- (void)updateActionButtonStatus;

@end
