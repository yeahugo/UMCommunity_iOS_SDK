//
//  UMComEditTopicsViewController.m
//  UMCommunity
//
//  Created by luyiyuan on 14/9/22.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComEditTopicsViewController.h"
#import "UMComSession.h"
#import "UMComTopic.h"
#import "UMComEditTopicsTableViewCell.h"
#import "UMComEditViewModel.h"
#import "UMComPullRequest.h"
#import "UMComShowToast.h"

@interface UMComEditTopicsViewController ()
@property (nonatomic, weak) UMComEditViewModel *editViewModel;

@property (nonatomic, strong) NSMutableArray *topicsArray;
@end

@implementation UMComEditTopicsViewController

-(id)initWithEditViewModel:(UMComEditViewModel *)editViewModel
{
    self = [self init];
    
    if(self)
    {
        self.editViewModel = editViewModel;
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"UMComEditTopicsTableViewCell" bundle:nil] forCellReuseIdentifier:@"EditTopicsCell"];
    self.tableView.delegate = self;
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    self.tableView.rowHeight = 45;
    
    UMComAllTopicsRequest *allTopicsController = [[UMComAllTopicsRequest alloc] initWithCount:TotalTopicSize];
    [UMComSession sharedInstance].isFocus = YES;
    [allTopicsController fetchRequestFromCoreData:^(NSArray *data, NSError *error) {
        
        if (!error && data.count > 0) {
            if ([[[UIDevice currentDevice] systemVersion]floatValue] < 8.0) {
                self.footView.backgroundColor = TableViewSeparatorRGBColor;
            }
            self.topicsArray = [NSMutableArray arrayWithArray:data];
            [self.tableView reloadData];
        }
        [allTopicsController fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            if (!error && data.count > 0) {
                if ([[[UIDevice currentDevice] systemVersion]floatValue] < 8.0) {
                    self.footView.backgroundColor = TableViewSeparatorRGBColor;
                }
                self.topicsArray = [NSMutableArray arrayWithArray:data];
                [self.tableView reloadData];
            }else {
                [UMComShowToast fetchTopcsFail:error];
            }
        }];
    }];
    
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.topicsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"EditTopicsCell";
    UMComEditTopicsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UMComEditTopicsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = @"";
    [cell setWithTopic:self.topicsArray[indexPath.row]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if(indexPath.row<[self.topicsArray count])
    {
        UMComTopic *topic = (UMComTopic *)self.topicsArray[indexPath.row];
        
        if (topic.topicID) {
            [self.editViewModel.topics addObject:topic];
        }
        
        [self.editViewModel editContentAppendKvoString:[NSString stringWithFormat:@"#%@#",topic.name]];
    }
    else
    {
        UMComAllTopicsRequest *allTopicsController = [[UMComAllTopicsRequest alloc] initWithCount:TotalTopicSize];
        [allTopicsController fetchRequestFromCoreData:^(NSArray *data, NSError *error) {
            if (data) {
                self.topicsArray = [NSMutableArray arrayWithArray:data];
                [self.tableView reloadData];
            } else {

                [allTopicsController fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
                    self.topicsArray = [NSMutableArray arrayWithArray:data];
                    [self.tableView reloadData];
                }];
            }
        }];
    }
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
