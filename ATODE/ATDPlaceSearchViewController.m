//
//  ATDPlaceSearchViewController.m
//  ATODE
//
//  Created by himara2 on 2014/07/06.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDPlaceSearchViewController.h"
#import <AFNetworking/AFNetworking.h>


static NSString * const kApiClientID = @"UXFP35M0BBM3BSQS0IEDLDHQECN4PIP5IYE14CD4MBR1VPS2";
static NSString * const kApiClientSecret = @"FWEEVYATFIJXWUOLHBYKDUUVLKEDU2L0DHYJXU5ZA14YCXY2";

@interface ATDPlaceSearchViewController ()
<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *places;

@end



@implementation ATDPlaceSearchViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reloadData];
}


- (void)reloadData {
    self.places = @[@"aaa", @"bbb", @"ccc"];
    
    NSDictionary *params = @{@"client_id":kApiClientID,
                             @"client_secret":kApiClientSecret,
                             @"v":@"20140707",
                             @"near":@"Tokyo"};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"https://api.foursquare.com/v2/venues/explore"
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             NSLog(@"Success:[%@]", responseObject);
             
             NSArray *venues = responseObject[@"response"][@"groups"][0][@"items"][0][@"venue"];
             
             NSLog(@"venues[%@]", venues);
             
             [_tableView reloadData];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"error:[%@]", error);
         }];

}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = _places[indexPath.row];
    return cell;
}

@end
