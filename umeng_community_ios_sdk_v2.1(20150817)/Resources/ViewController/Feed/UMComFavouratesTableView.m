//
//  UMComFavouratesTableView.m
//  UMCommunity
//
//  Created by Gavin Ye on 8/12/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import "UMComFavouratesTableView.h"
#import "UMComFeedsTableViewCell.h"
#import "UMComFeedStyle.h"

@implementation UMComFavouratesTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (NSArray *)transformFeedDatasToFeedStylesData:(NSArray *)dataArr
{
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:1];
    for (UMComFeed *feed in dataArr) {
        UMComFeedStyle *feedStyle = [UMComFeedStyle feedStyleWithFeed:feed viewWidth:self.frame.size.width feedType:feedFavourateType];
        [tempArr addObject:feedStyle];
    }
    return tempArr;
}


@end
