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


@interface UMComFilterTopicsViewController ()

@property (strong,nonatomic) NSMutableArray *filteredCacheTopicsArray;
@property (strong,nonatomic) NSMutableArray *filteredResponseTopicsArray;
@property (strong,nonatomic) UMComHttpPagesTopicsSearch *httpPagesTopicsSearch;
@property (strong,nonatomic) NSMutableArray *allTopicsArray;

@property (nonatomic,strong) UILabel *isRecommendLabel;

@property UISearchBar *searchBar;

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
//        self.filteredTopicsArray = [[NSMutableArray alloc] init];
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
    [self.indicatorView startAnimating];

    [self.tableView registerNib:[UINib nibWithNibName:@"UMComFilterTopicsViewCell" bundle:nil] forCellReuseIdentifier:@"FilterTopicsViewCell"];
    
    if (self.topicRequestType == allTopicType) {
        UIBarButtonItem *leftButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"Backx" target:self action:@selector(onClickClose)];
        [self.navigationItem setLeftBarButtonItem:leftButtonItem];

        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
        self.searchBar.placeholder = UMComLocalizedString(@"Search_Topic", @"查找话题...");
        self.searchBar.backgroundImage = [[UIImage alloc] init];
        self.searchBar.delegate = self;
        self.navigationItem.titleView = self.searchBar;
        self.navigationItem.titleView.backgroundColor = [UIColor clearColor];
        UIBarButtonItem *rightButtonItem = [[UMComBarButtonItem alloc] initWithTitle:UMComLocalizedString(@"Search",@"搜索") target:self action:@selector(onClickSearch:)];
        [self.navigationItem setRightBarButtonItem:rightButtonItem];
        [self requestAllTopicsArray];
    }else{
        self.title = UMComLocalizedString(@"User_Topic", @"话题推荐");
        if (self.isShowNextButton == YES) {
            UMComBarButtonItem *rightButtonItem = [[UMComBarButtonItem alloc] initWithTitle:UMComLocalizedString(@"NextStep",@"下一步") target:self action:@selector(onClickNext)];
            [self.navigationItem setRightBarButtonItem:rightButtonItem];
        }
        [self requestRecommendTopicsArray];
    }
}

- (void)onClickNext
{
    if (self.completion) {
        self.completion(@[self],nil);
    }
}

- (void)requestAllTopicsArray
{
    [self.filterTopicsViewModel loadLocusTopics:^(NSArray *data, NSError *error) {
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
        if (!error && data.count > 0) {
            self.allTopicsArray = [NSMutableArray arrayWithArray:data];
            if ([[[UIDevice currentDevice] systemVersion]floatValue] < 8.0) {
                self.footView.backgroundColor = TableViewSeparatorRGBColor;
            }
        }else{
            [UMComShowToast fetchTopcsFail:error];
        }
        [self.tableView reloadData];
    }];

}

- (void)requestRecommendTopicsArray
{
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
            self.allTopicsArray = [NSMutableArray arrayWithArray:data];
            if ([[[UIDevice currentDevice] systemVersion]floatValue] < 8.0) {
                self.footView.backgroundColor = TableViewSeparatorRGBColor;
            }
            self.isRecommendLabel.hidden = YES;
        }else{
            if (error) {
                self.isRecommendLabel.hidden = YES;
            }else{
                if (self.isRecommendLabel == nil) {
                    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height/2-80, self.view.frame.size.width, 40)];
                    label.backgroundColor = [UIColor clearColor];
                    label.text = UMComLocalizedString(@"There is no topic", @"暂时没有推荐话题咯");
                    label.textAlignment = NSTextAlignmentCenter;
                    [self.tableView addSubview:label];
                    self.isRecommendLabel = label;
                }else{
                    self.isRecommendLabel.hidden = NO;
                }
            }
            [UMComShowToast fetchTopcsFail:error];
        }
        [self.tableView reloadData];
    }];
}

-(void)onClickClose
{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)onClickSearch:(id)sender
{
    [self searchResult:self.searchBar.text];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchResult:self.searchBar.text];
}

- (void)searchResult:(NSString *)keywords
{
    [self.searchBar resignFirstResponder];
    [self.indicatorView startAnimating];
    if([keywords length]>0)
    {
        [self.filterTopicsViewModel searchTopicWithKeywords:keywords completion:^(NSArray *data,  NSError *error) {
            [self.indicatorView stopAnimating];
            if (!error) {
                if (data.count > 0) {
                    [self.filteredCacheTopicsArray removeAllObjects];
                    [self.filteredCacheTopicsArray addObjectsFromArray:data];
                }else{
                    [UMComShowToast fetchFailWithNoticeMessage:UMComLocalizedString(@"no related topics",@"暂无相关话题")];
                }
                [self.tableView reloadData];
            } else {
                [UMComShowToast fetchTopcsFail:error];
            }
        }];
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self.searchBar.text length]>0)
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
    
    if([self.searchBar.text length]>0)
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
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UMComTopic *topic = nil;
    if([self.searchBar.text length]>0)
    {
        if([self.filteredResponseTopicsArray count]>0)
        {
            topic = [self.filteredCacheTopicsArray objectAtIndex:indexPath.row];
        }
        else
        {
           topic = [self.filteredCacheTopicsArray objectAtIndex:indexPath.row];
        }
        
    }
    else
    {
        topic = [self.allTopicsArray objectAtIndex:indexPath.row];
    }
//    UMComTopic *topic = [self.allTopicsArray objectAtIndex:indexPath.row];
//    UMComTopicFeedViewController *oneFeedViewController = [[UMComTopicFeedViewController alloc] initWithTopic:topic];

    UMComTopicFeedViewController *oneFeedViewController = nil;
    oneFeedViewController = [[UMComTopicFeedViewController alloc] initWithTopic:topic];
//    [UIView setAnimationsEnabled:YES]; 
    [self.navigationController pushViewController:oneFeedViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Content Filtering


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;
{
    if (searchText!=nil && searchText.length>0) {
        [self filterContentForSearchText:searchText];
    }
    else
    {
        [self.filteredResponseTopicsArray removeAllObjects];
    }

    [self.tableView reloadData];
}

- (void)filterContentForSearchText:(NSString*)searchText
{
    [self.filteredCacheTopicsArray removeAllObjects];
    
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains %@",searchText];
    NSArray *tempArray = [self.allTopicsArray filteredArrayUsingPredicate:predicate];
    
    self.filteredCacheTopicsArray = [NSMutableArray arrayWithArray:tempArray];
}

@end
