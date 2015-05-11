//
//  UMComLocationTableViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 9/9/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComLocationTableViewController.h"
#import "UMComHttpManager.h"
#import <CoreLocation/CoreLocation.h>
#import "UMComLocationTableViewCell.h"
#import "UMComShowToast.h"
#import "UMUtils.h"
#import "UIViewController+UMComAddition.h"

@interface UMComLocationTableViewController ()

@property (nonatomic, strong) NSArray *locationDics;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, weak) UMComEditViewModel *editViewModel;

@end

@implementation UMComLocationTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.indicatorView startAnimating];
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted
        || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [[[UIAlertView alloc] initWithTitle:nil message:UMComLocalizedString(@"No location",@"此应用程序没有权限访问地理位置信息，请在隐私设置里启用") delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
    }
    if (NO==[CLLocationManager locationServicesEnabled]) {
        UMLog(@"---------- 未开启定位");
    }
    [self setBackButtonWithTitle:UMComLocalizedString(@"Back",@"返回")];
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
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//    self.tableView.separatorColor = TableViewSeparatorRGBColor;
    self.tableView.rowHeight = LocationCellHeight;
 
}

-(id)initWithEditViewModel:(UMComEditViewModel *)editViewModel
{
    self = [super initWithNibName:@"UMComLocationTableViewController" bundle:nil];
    self.editViewModel = editViewModel;
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.locationDics.count == 0) {
        return 0;
    }
    return self.locationDics.count + 1;
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
        cell.locationName.textColor = [UIColor blackColor];
        cell.locationName.center = CGPointMake(cell.locationName.center.x, (tableView.rowHeight-cell.locationDetail.frame.size.height)/2);
        cell.locationDetail.hidden = NO;
        [cell reloadFromLocationDic:[self.locationDics objectAtIndex:indexPath.row-1]];
    }

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return LocationCellHeight;
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    self.editViewModel.location = manager.location;
    [UMComHttpManager locationNames:manager.location.coordinate response:^(id responseObject, NSError *error) {
        [self.indicatorView stopAnimating];
        if (!error) {
            if ([responseObject valueForKey:@"pois"] && [[responseObject valueForKey:@"pois"] count] > 0) {
                if ([[[UIDevice currentDevice] systemVersion]floatValue] < 8.0) {
                    self.footView.backgroundColor = TableViewSeparatorRGBColor;
                }
                self.locationDics = [responseObject valueForKey:@"pois"];
                [self.tableView reloadData];
            }else{
                [UMComShowToast fetchLocationsFail:nil];
            }
            
        }else{
            [UMComShowToast fetchLocationsFail:error];
        }
    }];
    
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [UMComShowToast fetchFailWithNoticeMessage:UMComLocalizedString(@"fail to location",@"定位失败")];
    [self.indicatorView stopAnimating];

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


#pragma mark - Table view delegate
// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    if (indexPath.row > 0) {
         self.editViewModel.locationDescription = [[self.locationDics objectAtIndex:indexPath.row-1] valueForKey:@"name"];
    }else{
        self.editViewModel.locationDescription = @"";
    }
    [self.navigationController popViewControllerAnimated:YES];
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
