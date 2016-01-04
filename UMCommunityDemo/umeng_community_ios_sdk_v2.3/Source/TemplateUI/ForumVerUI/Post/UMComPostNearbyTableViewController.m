//
//  UMComPostNearbyTableViewController.m
//  UMCommunity
//
//  Created by umeng on 15/11/29.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComPostNearbyTableViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "UIViewController+UMComAddition.h"
#import "UMComTools.h"
#import "UMComShowToast.h"
#import "UMComPullRequest.h"

@interface UMComPostNearbyTableViewController ()<CLLocationManagerDelegate>


@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic) CLLocation* location;

@end

@implementation UMComPostNearbyTableViewController



- (instancetype)initWithLocation:(CLLocation *)location title:(NSString *)title
{
    self.location = location;
    self.title = title;
    self.fetchRequest = [[UMComNearbyFeedsRequest alloc]initWithLocation:location count:BatchSize];
    [self refreshNewDataFromServer:nil];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setForumUITitle:self.title];
    self.title = nil;
    if (!self.location) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted
            || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            [[[UIAlertView alloc] initWithTitle:nil message:UMComLocalizedString(@"No location",@"此应用程序没有权限访问地理位置信息，请在隐私设置里启用") delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
        }
        if (NO==[CLLocationManager locationServicesEnabled]) {
            NSLog(@"---------- 未开启定位");
        }
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 50.0f;
        
        [_locationManager startUpdatingLocation];
        
        if (!([CLLocationManager locationServicesEnabled] == YES  && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)){
            
            if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0f) {
                [self.locationManager requestAlwaysAuthorization];
            }
        }
    }
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    self.fetchRequest = [[UMComNearbyFeedsRequest alloc]initWithLocation:manager.location count:BatchSize];
    [self refreshNewDataFromServer:nil];
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [UMComShowToast fetchFailWithNoticeMessage:UMComLocalizedString(@"fail to location",@"定位失败")];
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
