//
//  ATDDetailViewController.m
//  ATODE
//
//  Created by himara2 on 2014/07/13.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDDetailViewController.h"
#import "ATDMapViewController.h"
#import "PlaceMemo.h"
#import "ATDCoreDataManger.h"
#import "ATDPhotoCell.h"
#import "ATDPlaceInfoCell.h"
#import "ATDMemoCell.h"
#import "ATDMapCell.h"
#import "ATDPostDateCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import <MapKit/MapKit.h>


typedef NS_ENUM(NSUInteger, DetailTableCell) {
    DetailTableCellPhoto,
    DetailTableCellMemo,
    DetailTableCellPlace,
    DetailTableCellMap,
    DetailTableCellPostDate
};



@interface ATDDetailViewController ()
<UITableViewDataSource, UITableViewDelegate,
ATDMapCellDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *memoLabel;
@property (weak, nonatomic) IBOutlet UILabel *postdateLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeInfoLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *mapOverlayView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end



@implementation ATDDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

#pragma mark -
#pragma mark UITableViewDelegate / UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    switch (indexPath.row) {
        case DetailTableCellPhoto:
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ATDPhotoCell class])];
            break;
        case DetailTableCellMemo:
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ATDMemoCell class])];
            break;
        case DetailTableCellPlace:
            if (!_memo.placeInfo) {
                return 0;
            }
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ATDPlaceInfoCell class])];
            break;
        case DetailTableCellMap:
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ATDMapCell class])];
            break;
        case DetailTableCellPostDate:
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ATDPostDateCell class])];
            break;
    }
    
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == DetailTableCellPhoto) {
        ATDPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ATDPhotoCell class])];
        [cell.photoImageView setImageWithURL:[NSURL fileURLWithPath:_memo.imageFilePath]];
        return cell;
    }
    else if (indexPath.row == DetailTableCellMemo) {
        ATDMemoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ATDMemoCell class])];
        cell.memoLabel.text = _memo.title;
        return cell;
    }
    else if (indexPath.row == DetailTableCellPlace) {
        ATDPlaceInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ATDPlaceInfoCell class])];
        
        if (!_memo.placeInfo) {
            cell.placeNameLabel.text = @"";
            cell.placeDetailLabel.text = @"";
            cell.placeImageView.alpha = 0.0;
            return cell;
        }
        else {
            cell.placeNameLabel.text = _memo.placeInfo.name;
            cell.placeDetailLabel.text = _memo.placeInfo.address;
            cell.placeImageView.alpha = 1.0;
            [cell.placeImageView setImageWithURL:[NSURL URLWithString:_memo.placeInfo.photoUrls[0]]];
            return cell;
        }
    }
    else if (indexPath.row == DetailTableCellMap) {
        ATDMapCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ATDMapCell class])];
        cell.memo = _memo;
        cell.delegate = self;
        return cell;
    }
    else if (indexPath.row == DetailTableCellPostDate) {
        ATDPostDateCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ATDPostDateCell class])];
        cell.postDateLabel.text = _memo.postdate;
        return cell;
    }
    
    return nil;
}



#pragma mark -
#pragma mark ATDMapCellDelegate

- (void)didTapOverlayView {
    [self performSegueWithIdentifier:@"showMap" sender:nil];
}


#pragma mark -
#pragma mark IBAction

- (IBAction)deleteBtnTouched:(id)sender {
    [UIAlertView showWithTitle:@"確認"
                       message:@"本当に削除しますか？"
             cancelButtonTitle:@"キャンセル"
             otherButtonTitles:@[@"はい"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (alertView.cancelButtonIndex != buttonIndex) {
                              [self deleteMemo];
                          }
                      }];
}

- (void)deleteMemo {
    [[ATDCoreDataManger sharedInstance] deleteMemo:_memo];
    
    [UIAlertView showWithTitle:@"Success!"
                       message:@"削除しました"
             cancelButtonTitle:nil
             otherButtonTitles:@[@"OK"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          [self.navigationController popToRootViewControllerAnimated:YES];
                      }];
}



#pragma mark -
#pragma mark Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showMap"]) {
        UINavigationController *nav = segue.destinationViewController;
        ATDMapViewController *mapVC = nav.viewControllers[0];
        mapVC.latitude = [_memo.latitude doubleValue];
        mapVC.longitude = [_memo.longitude doubleValue];
    }
}

@end
