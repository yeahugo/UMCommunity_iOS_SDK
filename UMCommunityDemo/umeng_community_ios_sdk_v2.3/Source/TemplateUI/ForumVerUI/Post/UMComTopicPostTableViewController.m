//
//  UMComTopicPostTableViewController.m
//  UMCommunity
//
//  Created by umeng on 15/12/30.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComTopicPostTableViewController.h"
#import "UMComPullRequest.h"
#import "UMComTopic.h"
#import "UMComFeed.h"

@interface UMComTopicPostTableViewController ()

@end

@implementation UMComTopicPostTableViewController

- (instancetype)initWithTopic:(UMComTopic *)topic
{
    self = [super init];
    if (self) {
        self.topic = topic;
    }
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


#pragma mark - data handle

//- (void)handleCoreDataDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
//{
//    if (!error && [data isKindOfClass:[NSArray class]]) {
//        if ([self.fetchRequest isKindOfClass:[UMComTopicFeedsRequest class]]) {
//            self.showTopMark = YES;//显示置顶按钮
//            self.dataArray = data;
//
//        }else{
//            self.showTopMark = NO;
//            self.dataArray = data;
//        }
//    }
//    if (finishHandler) {
//        finishHandler();
//    }
//}
//
//- (void)handleServerDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
//{
//    if (!error && [data isKindOfClass:[NSArray class]]) {
//        if ([self.fetchRequest isKindOfClass:[UMComTopicFeedsRequest class]]) {
//            self.showTopMark = YES;//显示置顶按钮
//            
//        }else{
//            self.showTopMark = NO;
//            self.dataArray = data;
//        }
//    }
//    if (finishHandler) {
//        finishHandler();
//    }
//}
//
//- (void)handleLoadMoreDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
//{
//    if (!error && [data isKindOfClass:[NSArray class]]) {
//        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataArray];
//        [tempArray addObjectsFromArray:data];
//        self.dataArray = tempArray;
//    }
//    if (finishHandler) {
//        finishHandler();
//    }
//}


//- (NSArray *)getResultArrayData:(NSArray *)data
//{
//    if ([data isKindOfClass:[NSArray class]] && data.count > 0) {
//        NSMutableArray *resultArray = [NSMutableArray array];
//        UMComTopicFeedsRequest *topRequest = (UMComTopicFeedsRequest *)self.fetchRequest;
//        if (topRequest.topic_top_items.count > 0) {
//            for (UMComFeed *feed in topRequest.topic_top_items) {
//                feed.is_top = @1;
//            }
//            [resultArray addObjectsFromArray:topRequest.topic_top_items];
//        }
//        for (UMComFeed *feed in data) {
//            if (![resultArray containsObject:feed]) {
//                [resultArray addObject:feed];
//            }
//        }
//        return resultArray;
//    }
//    return nil;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
