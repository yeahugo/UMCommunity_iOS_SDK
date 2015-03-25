//
//  UMComFeedViewModel.h
//  UMCommunity
//
//  Created by Gavin Ye on 10/22/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComViewModel.h"
#import "UMComPullRequest.h"

@interface UMComFeedViewModel : UMComViewModel
{
    int _startNum;
    BOOL _haveEnoughLocalData;
}
@property (nonatomic, copy) LoadDataCompletion completion;

@property (nonatomic, strong) NSMutableArray * feedsArray;

@property (nonatomic, strong) UMComPullRequest * fetchedFeedsController;

@property (nonatomic, assign) UITableView *tableView;


-(void)postCommentContent:(NSString *)content
                   feedID:(NSString *)feedID
               commentUid:(NSString *)commentUid
               completion:(LoadDataCompletion)completion;

@end
