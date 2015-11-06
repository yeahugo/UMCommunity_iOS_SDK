//
//  UMComLocationTableViewController1.m
//  UMCommunity
//
//  Created by umeng on 15/8/7.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComLocationListController.h"
#import <CoreLocation/CoreLocation.h>
#import "UMComLocationTableViewCell.h"
#import "UMComShowToast.h"
#import "UMUtils.h"
#import "UIViewController+UMComAddition.h"
#import "UMComEditViewModel.h"
#import "UMComRefreshView.h"
#import "UMComTableView.h"
#import "UMComLocationModel.h"
#import "UMComPullRequest.h"


@interface UMComLocationListController ()<UMComRefreshViewDelegate,CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, weak) UMComEditViewModel *editViewModel;

@end

@implementation UMComLocationListController
- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self.tableView.indicatorView startAnimating];
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted
        || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [[[UIAlertView alloc] initWithTitle:nil message:UMComLocalizedString(@"No location",@"此应用程序没有权限访问地理位置信息，请在隐私设置里启用") delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
    }
    if (NO==[CLLocationManager locationServicesEnabled]) {
        UMLog(@"---------- 未开启定位");
    }
    [self setBackButtonWithImage];
    [self setTitleViewWithTitle:UMComLocalizedString(@"LocationTitle",@"我的位置")];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 15.0f;
    
    [_locationManager startUpdatingLocation];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"UMComLocationTableViewCell" bundle:nil] forCellReuseIdentifier:@"LocationTableViewCell"];
    
    if (!([CLLocationManager locationServicesEnabled] == YES  && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)){
        
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0f) {
            [self.locationManager requestAlwaysAuthorization];
        }
    }
    self.tableView.rowHeight = LocationCellHeight;
    self.tableView.refreshController.footView = nil;
}

-(id)initWithEditViewModel:(UMComEditViewModel *)editViewModel
{
    self = [super init];
    self.editViewModel = editViewModel;
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataArray.count == 0) {
        return 0;
    }
    return self.dataArray.count + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"LocationTableViewCell";
    UMComLocationTableViewCell *cell = (UMComLocationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        cell.locationName.center = CGPointMake(cell.locationName.center.x, tableView.rowHeight/2);
        cell.locationName.text = @"不显示位置";
        cell.locationDetail.hidden = YES;
        cell.locationName.textColor = [UMComTools colorWithHexString:FontColorBlue];
    }else{
        UMComLocationModel *locationModel = self.dataArray[indexPath.row-1];
        cell.locationName.textColor = [UIColor blackColor];
        cell.locationName.center = CGPointMake(cell.locationName.center.x, (tableView.rowHeight-cell.locationDetail.frame.size.height)/2);
        cell.locationDetail.hidden = NO;
        [cell reloadFromLocationModel:locationModel];
    }
    return cell;
}

#pragma mark - locationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    self.editViewModel.location = manager.location;
    self.fetchRequest = [[UMComLocationRequest alloc]initWithLocation:manager.location];
    [self.tableView refreshNewDataFromServer:nil];
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [UMComShowToast fetchFailWithNoticeMessage:UMComLocalizedString(@"fail to location",@"定位失败")];
    [self.tableView.indicatorView stopAnimating];
    
}


//#pragma mark - refresh
//- (void)refreshData:(UMComRefreshView *)refreshView loadingFinishHandler:(RefreshDataLoadFinishHandler)handler
//{
//    [self.tableView refreshNewDataFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
//        if (handler) {
//            handler(error);
//        }
//    }];
//}
//
//- (void)loadMoreData:(UMComRefreshView *)refreshView loadingFinishHandler:(RefreshDataLoadFinishHandler)handler
//{
//    if (handler) {
//        handler(nil);
//    }
//}

//- (void)refreshNewDataFromServer:(LoadSeverDataCompletionHandler)complection
//{
//    __weak typeof(self) weakSelf = self;
//    [UMComHttpManager getLocationNames:self.editViewModel.location.coordinate response:^(id responseObject, NSError *error) {
//        [weakSelf.tableView.indicatorView stopAnimating];
//        if (complection) {
//            complection(nil,NO,nil);
//        }
//        if (!error) {
//            NSMutableArray * locationArray = [NSMutableArray array];
//            UMComLocationModel *locationModel = nil;
//            NSArray *pois = [responseObject valueForKey:@"pois"];
//            if ([pois isKindOfClass:[NSArray class]] && [pois count] > 0) {
//                for (NSDictionary *locationDict in pois) {
//                       locationModel = [UMComLocationModel locationWithLocationDict:locationDict];
//                    [locationArray addObject:locationModel];
//
//                }
//            }
//            weakSelf.dataArray = locationArray;
//            if (locationArray.count == 0) {
//                [UMComShowToast showFetchResultTipWithError:nil];
//            } else {
//                [weakSelf.tableView reloadData];
//            }
//        }else{
//            [UMComShowToast showFetchResultTipWithError:error];
//        }
//    }];
//}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row > 0) {
        UMComLocationModel *locationModel = self.dataArray[indexPath.row-1];
        self.editViewModel.locationDescription = locationModel.name;
    }else{
        self.editViewModel.locationDescription = @"";
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
