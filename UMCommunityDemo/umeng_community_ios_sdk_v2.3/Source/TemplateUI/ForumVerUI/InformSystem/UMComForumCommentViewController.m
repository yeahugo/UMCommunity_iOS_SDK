//
//  UMComForumCommentViewController.m
//  UMCommunity
//
//  Created by umeng on 15/12/22.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumCommentViewController.h"
#import "UMComHorizonCollectionView.h"
#import "UMComForumCommentTableViewController.h"
#import "UMComPullRequest.h"
#import "UMComSession.h"
#import "UMComUnReadNoticeModel.h"

@interface UMComForumCommentViewController ()<UMComHorizonCollectionViewDelegate>

@property (nonatomic, strong) UMComHorizonCollectionView *menuView;

@property (nonatomic, strong) UIViewController *lastViewController;

@end

@implementation UMComForumCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createSubControllers];

    // Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (!self.menuView) {
        UMComHorizonCollectionView *menuView = [[UMComHorizonCollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40) itemCount:2];
        menuView.cellDelegate = self;
        menuView.itemSpace = 0;
        menuView.indicatorLineHeight = 5;
        menuView.scrollIndicatorView.image = UMComImageWithImageName(@"selected");
        [self.view addSubview:menuView];
        self.menuView = menuView;
        [self.view bringSubviewToFront:self.menuView];
    }
}

#pragma mark - UMComHorizonCollectionViewDelegate
- (void)horizonCollectionView:(UMComHorizonCollectionView *)collectionView reloadCell:(UMComHorizonCollectionCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        cell.label.text = UMComLocalizedString(@"Receive_Comment", @"收到的评论");
    }else{
        cell.label.text = UMComLocalizedString(@"Send_Comment", @"发出的评论");
    }
    cell.label.highlightedTextColor = UMComColorWithColorValueString(FontColorBlue);
    cell.label.backgroundColor = UMComColorWithColorValueString(LightGrayColor);
}

- (void)horizonCollectionView:(UMComHorizonCollectionView *)collectionView didSelectedColumn:(NSInteger)column
{
    UMComRequestTableViewController *requestTableVc = self.childViewControllers[column];
    if (requestTableVc.dataArray.count == 0 && requestTableVc.isLoadFinish) {
        [requestTableVc loadAllData:nil fromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            if (column == 0) {
                [UMComSession sharedInstance].unReadNoticeModel.notiByCommentCount = 0;
            }
        }];
    }
    [self transitionFromViewController:self.lastViewController toViewController:requestTableVc];
}


- (void)createSubControllers
{
    CGRect commonFrame = self.view.frame;
    commonFrame.origin.y = 40;
    commonFrame.size.height = commonFrame.size.height - commonFrame.origin.y;
    CGFloat centerY = commonFrame.size.height/2+commonFrame.origin.y;
    UMComForumCommentTableViewController *hotPostListController = [[UMComForumCommentTableViewController alloc] initWithFetchRequest:[[UMComUserCommentsReceivedRequest alloc] initWithCount:BatchSize]];
    hotPostListController.isAutoStartLoadData = YES;
    [hotPostListController loadAllData:nil fromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        [UMComSession sharedInstance].unReadNoticeModel.notiByCommentCount = 0;
    }];
    [self addChildViewController:hotPostListController];
    [self.view addSubview:hotPostListController.view];
    hotPostListController.view.frame = commonFrame;
    
    UMComForumCommentTableViewController *recommendPostListController = [[UMComForumCommentTableViewController alloc] initWithFetchRequest:[[UMComUserCommentsSentRequest alloc]initWithCount:BatchSize]];
    [self addChildViewController:recommendPostListController];
    recommendPostListController.view.frame = commonFrame;
    recommendPostListController.view.center = CGPointMake(commonFrame.size.width * 3 / 2, centerY);
    self.lastViewController = hotPostListController;
}

- (void)transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
    if (fromViewController == toViewController) {
        [self.view bringSubviewToFront:self.menuView];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self transitionFromViewController:fromViewController toViewController:toViewController duration:0.25 options:UIViewAnimationOptionCurveEaseIn animations:^{
        toViewController.view.center = CGPointMake(weakSelf.view.frame.size.width/2, toViewController.view.center.y);
        if (weakSelf.menuView.currentIndex > weakSelf.menuView.previewsIndex) {
            fromViewController.view.center = CGPointMake(-weakSelf.view.frame.size.width*3/2, fromViewController.view.center.y);
        }else if(weakSelf.menuView.currentIndex < weakSelf.menuView.previewsIndex){
            fromViewController.view.center = CGPointMake(weakSelf.view.frame.size.width*3/2, fromViewController.view.center.y);
        }else{
            toViewController.view.center = fromViewController.view.center;
        }
        [weakSelf.view bringSubviewToFront:weakSelf.menuView];
    } completion:^(BOOL finished) {
        weakSelf.lastViewController = toViewController;
    }];
}


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
