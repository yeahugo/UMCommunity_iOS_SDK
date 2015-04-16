//
//  UMComOneFeedViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 9/12/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComTopicFeedViewController.h"
#import "UMComFeedsTableViewCell.h"
#import "UMComTopic+UMComManagedObject.h"
#import "UMComFeedsTableView.h"
#import "UMComAction.h"
#import "UMComSession.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComShowToast.h"
#import "UMComUserRecommendViewController.h"
@interface UMComTopicFeedViewController ()

@property (nonatomic, strong) NSMutableArray *resultArray;

@property (strong, nonatomic) UIButton *editedButton;

@property (nonatomic, strong) UMComUserRecommendViewController *recommendUsersVc;

@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation UMComTopicFeedViewController

-(id)initWithTopic:(UMComTopic *)topic
{
    self = [super initWithNibName:@"UMComTopicFeedViewController" bundle:nil];
    if (self) {
        self.navigationItem.title = [NSString stringWithFormat:@"#%@#",topic.name];
        self.topic = topic;
        UMComTopicFeedsRequest *topicFeedsController = [[UMComTopicFeedsRequest alloc] initWithTopicId:topic.topicID  count:TotalTopicSize];
        self.fetchFeedsController = topicFeedsController;
   }
    return self;
}

- (void)setFocused:(BOOL)focused
{
    CALayer * downButtonLayer = [self.followButton layer];
    
    UIColor *bcolor = [UIColor colorWithRed:15.0/255.0 green:121.0/255.0 blue:254.0/255.0 alpha:1];
    
    [downButtonLayer setBorderWidth:1.0];
    
    if([self isInclude:self.topic]){
        [downButtonLayer setBorderColor:[bcolor CGColor]];
        [self.followButton setTitleColor:bcolor forState:UIControlStateNormal];
        [self.followButton setTitle:UMComLocalizedString(@"Has_Focused",@"取消关注") forState:UIControlStateNormal];
    }else{
        [downButtonLayer setBorderColor:[[UIColor grayColor] CGColor]];
        [self.followButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.followButton setTitle:UMComLocalizedString(@"No_Focused",@"关注") forState:UIControlStateNormal];
    }
}

- (BOOL)isInclude:(UMComTopic *)topic
{
    BOOL isInclude = NO;
    for (UMComTopic *topicItem in [UMComSession sharedInstance].focus_topics) {
        if ([topic.name isEqualToString:topicItem.name]) {
            isInclude = YES;
            break;
        }
    }
    return isInclude;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    UITapGestureRecognizer *tapToHidenKeyboard = [[UITapGestureRecognizer alloc]initWithTarget:self.feedsTableView action:@selector(dismissAllEditView)];
    [self.view addGestureRecognizer:tapToHidenKeyboard];
    
    [self.feedsTableView setFeedTableViewController:self];
    
    [self setFocused:[self.topic isFocus]];
    
    if (self.topic.descriptor) {
        self.topicDescription.text = self.topic.descriptor;
    } else {
        self.topicDescription.text = self.topic.name;
    }
    
    [self.feedsTableView registerNib:[UINib nibWithNibName:@"UMComFeedsTableViewCell" bundle:nil] forCellReuseIdentifier:@"FeedsTableViewCell"];
    self.feedsTableView.dataSource = self;
    self.feedsTableView.delegate = self;
    [self.topicFeedBt setTitleColor:[UMComTools colorWithHexString:FontColorBlue] forState:UIControlStateNormal];
    self.recommendUsersVc = [[UMComUserRecommendViewController alloc]init];
    self.recommendUsersVc.topicId = self.topic.topicID;
    self.recommendUsersVc.viewController = self;
    [self.view addSubview:self.recommendUsersVc.view];
    
    self.editButton.hidden = YES;
    
    self.editedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.editedButton.frame = CGRectMake(0, 0, 50, 50);
    [self.editedButton setImage:[UIImage imageNamed:@"new"] forState:UIControlStateNormal];
    [self.editedButton setImage:[UIImage imageNamed:@"new+"] forState:UIControlStateSelected];
    [self.editedButton addTarget:self action:@selector(onClickEdit:) forControlEvents:UIControlEventTouchUpInside];
    self.currentPage = 0;
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.feedsTableView.hidden = NO;
    self.recommendUsersVc.view.hidden = NO;
    if (self.currentPage == 0) {
        self.recommendUsersVc.view.frame = CGRectMake(self.feedsTableView.frame.size.width, self.feedsTableView.frame.origin.y, self.feedsTableView.frame.size.width, self.feedsTableView.frame.size.height);

        [self onClickTopicFeedsButton:self.topicFeedBt];
    }else{
        [self onClickHotUserFeedsButton:self.hotUserBt];
    }
    
    self.editedButton.frame = CGRectMake(self.view.frame.size.width-70, self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height, 50, 50);
    [[UIApplication sharedApplication].keyWindow addSubview:self.editedButton];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.feedsTableView dismissAllEditView];
    self.feedsTableView.hidden = YES;
    self.recommendUsersVc.view.hidden = YES;
    [self.editedButton removeFromSuperview];
}


-(IBAction)onClickFollow:(id)sender
{
    __weak UMComTopicFeedViewController *weakSelf = self;
    [self.topic setFocused:![self.topic isFocus] block:^(NSError * error) {
        if (!error) {
            [weakSelf setFocused:[weakSelf.topic isFocus]];
        }else{
            [UMComShowToast fetchFeedFail:error];
        }
    }];
}



- (IBAction)onClickEdit:(id)sender
{
   [[UMComEditAction action] performActionAfterLogin:self.topic viewController:self completion:nil];
}

- (IBAction)onClickTopicFeedsButton:(id)sender {
//    [UIView setAnimationsEnabled:YES];
    self.currentPage = 0;
    CGFloat feedViewOriginY = self.followViewBackground.frame.origin.y + self.followViewBackground.frame.size.height;
    [UIView animateWithDuration:0.5 animations:^{
        self.feedsTableView.frame = CGRectMake(0, feedViewOriginY, self.feedsTableView.frame.size.width, self.feedsTableView.frame.size.height);
        self.recommendUsersVc.view.frame = CGRectMake(self.feedsTableView.frame.size.width, feedViewOriginY, self.feedsTableView.frame.size.width, self.feedsTableView.frame.size.height);
        self.selectedImageView.frame = CGRectMake(0, self.selectedImageView.frame.origin.y, self.topicFeedBt.frame.size.width, self.selectedImageView.frame.size.height);
        [self.topicFeedBt setTitleColor:[UMComTools colorWithHexString:FontColorBlue] forState:UIControlStateNormal];
        [self.hotUserBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)onClickHotUserFeedsButton:(id)sender {
//    [UIView setAnimationsEnabled:YES];
    self.currentPage = 1;
    CGFloat feedViewOriginY = self.followViewBackground.frame.origin.y + self.followViewBackground.frame.size.height;
    [UIView animateWithDuration:0.5 animations:^{
        self.feedsTableView.frame = CGRectMake(-self.feedsTableView.frame.size.width, feedViewOriginY, self.feedsTableView.frame.size.width, self.feedsTableView.frame.size.height);
        self.recommendUsersVc.view.frame = CGRectMake(0, feedViewOriginY, self.feedsTableView.frame.size.width, self.feedsTableView.frame.size.height);
        self.selectedImageView.frame = CGRectMake(self.topicFeedBt.frame.size.width, self.selectedImageView.frame.origin.y, self.topicFeedBt.frame.size.width, self.selectedImageView.frame.size.height);
        [self.hotUserBt setTitleColor:[UMComTools colorWithHexString:FontColorBlue] forState:UIControlStateNormal];
        [self.topicFeedBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        
    }];
}


- (void)loadDataFromCoreDataWithCompletion:(LoadDataCompletion)completion
{
    [self.fetchFeedsController fetchRequestFromCoreData:^(NSArray *data, NSError *error) {
        completion(data,error);
//        NSOrderedSet *feeds = [self.topic performSelector:@selector(feeds)];
//        if (completion) {
//            completion(feeds.array, error);
//        }
    }];
}

- (void)loadDataFromWebWithCompletion:(LoadDataCompletion)completion
{
    [self.fetchFeedsController fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        completion(data,error);
//        NSOrderedSet *feeds = [self.topic performSelector:@selector(feeds)];
//        completion(feeds.array, error);
    }];
}

- (void)loadMoreDataWithCompletion:(LoadDataCompletion)completion getDataFromWeb:(LoadServerDataCompletion)fromWeb
{
//    [self.fetchFeedsController fetchNextPageFromCoreData:^(NSArray *data, NSError *error) {
//        NSOrderedSet *feeds = [self.topic performSelector:@selector(feeds)];
//        completion(feeds.array,error);
//    }];
    [self.fetchFeedsController fetchNextPageFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        fromWeb(data, haveNextPage, error);

//        NSOrderedSet *feeds = [self.topic performSelector:@selector(feeds)];
//        if (fromWeb) {
//            fromWeb(feeds.array, haveNextPage, error);
//        }
    }];
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [(UMComFeedsTableView *)self.feedsTableView dismissAllEditView];
}

#pragma mark UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     return  [(UMComFeedsTableView *)self.feedsTableView tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.feedsTableView scrollViewDidScroll:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.feedsTableView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
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
