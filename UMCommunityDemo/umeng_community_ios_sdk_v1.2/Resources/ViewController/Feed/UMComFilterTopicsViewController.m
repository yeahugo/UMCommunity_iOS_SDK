//
//  UMComFilterTopicsViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 9/2/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComFilterTopicsViewController.h"
#import "UMComSession.h"
#import "UMComTopicFeedViewController.h"
#import "UMComTopic.h"
#import "UMComFilterTopicsViewCell.h"
#import "UMComBarButtonItem.h"
#import "UMComHttpManager.h"
#import "UMComHttpPagesManager.h"
#import "UMComHttpManager.h"
#import "UMComTopic+UMComManagedObject.h"
#import "UMComShowToast.h"
#import "UIViewController+UMComAddition.h"


@interface UMComFilterTopicsViewController ()

@property (strong,nonatomic) NSArray *filteredCacheTopicsArray;
@property (strong,nonatomic) NSArray *filteredResponseTopicsArray;
@property (strong,nonatomic) UMComHttpPagesTopicsSearch *httpPagesTopicsSearch;

@property (nonatomic,strong) UILabel *noTopicsTip;

@property UISearchBar *searchBar;

@property (nonatomic, copy) NSString *searchText;

@property (nonatomic, assign) BOOL loadFinish;

@end

@implementation UMComFilterTopicsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.filterTopicsViewModel = [[UMComFilterTopicsViewModel alloc] init];
        self.topicRequestType = allTopicType;
        self.isShowNextButton = NO;
        self.loadFinish = NO;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [self.tableView registerNib:[UINib nibWithNibName:@"UMComFilterTopicsViewCell" bundle:nil] forCellReuseIdentifier:@"FilterTopicsViewCell"];
    
    if (self.topicRequestType == allTopicType) {

    }else if (self.topicRequestType == recommendTopicType){
        [self setBackButtonWithTitle:UMComLocalizedString(@"Back", @"返回")];
        [self setTitleViewWithTitle:UMComLocalizedString(@"user_topic_recommend", @"话题推荐")];
        if (self.isShowNextButton == YES) {
            UMComBarButtonItem *rightButtonItem = [[UMComBarButtonItem alloc] initWithTitle:UMComLocalizedString(@"NextStep",@"下一步") target:self action:@selector(onClickNext)];
            [self.navigationItem setRightBarButtonItem:rightButtonItem];
        }
        [self requestRecommendTopicsArray];
    }
    
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height/2-80, self.view.frame.size.width, 40)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = UMComFontNotoSansLightWithSafeSize(17);
    [self.tableView addSubview:label];
    label.hidden = YES;
    self.noTopicsTip = label;
}

- (void)onClickNext
{
    if (self.completion) {
        self.completion(@[self],nil);
    }
}


-(void)onClickClose
{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self.searchText length]>0)
    {
        if([self.filteredResponseTopicsArray count]>0)
        {
            return [self.filteredResponseTopicsArray count];
        }
        else
        {
            return [self.filteredCacheTopicsArray count];
        }

    }
    else
    {
        return self.allTopicsArray.count;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"FilterTopicsViewCell";
    UMComFilterTopicsViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (self.topicRequestType == recommendTopicType) {
        cell.isRecommendTopic = YES;
        CGRect recommendFrame = CGRectMake(cell.butFocuse.frame.origin.x+2.5, cell.butFocuse.frame.origin.y+1.5, cell.butFocuse.frame.size.width-5, cell.butFocuse.frame.size.height-3);
        cell.butFocuse.frame = recommendFrame;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell == nil) {
        cell = [[UMComFilterTopicsViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if([self.searchText length]>0)
    {
        if([self.filteredResponseTopicsArray count]>0)
        {
            [cell setWithTopic:[self.filteredResponseTopicsArray objectAtIndex:indexPath.row]];
        }
        else
        {
            [cell setWithTopic:[self.filteredCacheTopicsArray objectAtIndex:indexPath.row]];
        }
    }
    else
    {
        UMComTopic *topic = [self.allTopicsArray objectAtIndex:indexPath.row];
        [cell setWithTopic:topic];
    }
    __weak UMComFilterTopicsViewController *weakSelf = self;
    cell.clickOnTopic = ^(UMComTopic *topic){
        [weakSelf didSelectRowAtTopic:topic];
    };
    return cell;
}

- (void)didSelectRowAtTopic:(UMComTopic *)topic
{
    UMComTopicFeedViewController *oneFeedViewController = nil;
    oneFeedViewController = [[UMComTopicFeedViewController alloc] initWithTopic:topic];
    [self.navigationController pushViewController:oneFeedViewController animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.scrollViewScroll) {
        self.scrollViewScroll(scrollView);
    }
    if (scrollView.contentOffset.y < -65) {
        if (self.loadFinish == YES && self.topicRequestType == recommendTopicType) {
            self.indicatorView.center = CGPointMake(self.tableView.frame.size.width/2, self.tableView.frame.origin.y-self.indicatorView.frame.size.height/2-5);
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y < -65) {
        if (self.loadFinish == YES && self.topicRequestType == recommendTopicType) {
            [self refreshAllTopics];
        }
    }
}



#pragma requestDataMethod


- (void)refreshAllTopics
{
    if (self.topicRequestType == allTopicType) {
        [self requestAllTopicsArray];
    }else if (self.topicRequestType == recommendTopicType){
        [self requestRecommendTopicsArray];
    }else {
        if (self.searchText.length > 0) {
            [self searchWhenClickAtSearchButtonResult:self.searchText];
        }
    }
}
- (void)requestAllTopicsArray
{
    self.noTopicsTip.hidden = YES;
    [self.indicatorView startAnimating];
    [self.filterTopicsViewModel loadLocusTopics:^(NSArray *data, NSError *error) {
        if (data.count > 0) {
            [self.indicatorView stopAnimating];
            self.allTopicsArray = data;
            if ([[[UIDevice currentDevice] systemVersion]floatValue] < 8.0) {
                self.footView.backgroundColor = TableViewSeparatorRGBColor;
            }
        }
        [self.tableView reloadData];
    } serverCompletion:^(NSArray *data, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.indicatorView stopAnimating];
        if (!error && data.count > 0) {
            self.allTopicsArray = data;
        }
        [self showNoTopicTipWithArr:self.allTopicsArray error:error notice:UMComLocalizedString(@"no related topics",@"暂无相关话题")];
        [self.tableView reloadData];
    }];
    
}


- (void)requestRecommendTopicsArray
{
    [self.indicatorView startAnimating];
    self.noTopicsTip.hidden = YES;
    [self.filterTopicsViewModel loadLocusRecommendTopics:^(NSArray *data, NSError *error) {
        if (data.count > 0) {
            [self.indicatorView stopAnimating];
            self.allTopicsArray = [NSMutableArray arrayWithArray:data];
            if ([[[UIDevice currentDevice] systemVersion]floatValue] < 8.0) {
                self.footView.backgroundColor = TableViewSeparatorRGBColor;
            }
        }
        
        [self.tableView reloadData];
    } serverCompletion:^(NSArray *data, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.indicatorView stopAnimating];
        if (data.count > 0) {
            self.allTopicsArray = data;
        }
        [self showNoTopicTipWithArr:self.allTopicsArray error:error notice: UMComLocalizedString(@"There is no topic", @"暂时没有推荐话题咯")];
        [self.tableView reloadData];
        self.loadFinish = YES;
    }];
}


- (void)searchWhenClickAtSearchButtonResult:(NSString *)keywords
{
    self.searchText = keywords;
    [self.searchBar resignFirstResponder];
    [self.indicatorView startAnimating];
    if([keywords length]>0)
    {
        [self.filterTopicsViewModel searchTopicWithKeywords:keywords completion:^(NSArray *data,  NSError *error) {
            [self.indicatorView stopAnimating];
            if (!error) {
                self.filteredCacheTopicsArray = data;
            }
            [self showNoTopicTipWithArr:data error:error notice:UMComLocalizedString(@"no related topics",@"暂无相关话题")];
            [self.tableView reloadData];
        }];
    }
}
- (void)showNoTopicTipWithArr:(NSArray *)topicArr error:(NSError *)error notice:(NSString *)noticeMassege
{
    if (topicArr.count > 0) {
        if ([[[UIDevice currentDevice] systemVersion]floatValue] < 8.0) {
            self.footView.backgroundColor = TableViewSeparatorRGBColor;
        }
        self.noTopicsTip.hidden = YES;
    }else{
        if (error) {
            self.noTopicsTip.hidden = YES;
        }else{
            self.noTopicsTip.hidden = NO;
            self.noTopicsTip.text = noticeMassege;
        }
        [UMComShowToast fetchTopcsFail:error];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText
{
    self.noTopicsTip.hidden = YES;
    self.searchText = searchText;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains %@",searchText];
    NSArray *tempArray = [self.allTopicsArray filteredArrayUsingPredicate:predicate];
    self.filteredCacheTopicsArray = tempArray;
    [self.tableView reloadData];
}

- (void)reloadTopicsDataWithSearchText:(NSString *)searchText
{
    self.searchText = searchText;
    if (searchText!=nil && searchText.length>0) {
        [self filterContentForSearchText:searchText];
    }
    else
    {
        [self requestAllTopicsArray];
    }
    [self.tableView reloadData];
}

@end
