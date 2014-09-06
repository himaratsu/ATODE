//
//  ATDDetailViewController.m
//  ATODE
//
//  Created by himara2 on 2014/07/13.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDDetailViewController.h"
#import "ATDImageViewController.h"
#import "ATDMapViewController.h"
#import "ATDEditMemoViewController.h"
#import "PlaceMemo.h"
#import "ATDCoreDataManger.h"
#import "ATDPhotoCell.h"
#import "ATDPlaceInfoCell.h"
#import "ATDMemoCell.h"
#import "ATDMapCell.h"
#import "ATDPostDateCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import <MapKit/MapKit.h>
#import <MWPhotoBrowser/MWPhotoBrowser.h>
#import "GAIDictionaryBuilder.h"


typedef NS_ENUM(NSUInteger, DetailTableCell) {
    DetailTableCellPhoto,
    DetailTableCellMemo,
    DetailTableCellPlace,
    DetailTableCellMap,
    DetailTableCellPostDate
};



@interface ATDDetailViewController ()
<UITableViewDataSource, UITableViewDelegate,
ATDPhotoCellDelegate, ATDMapCellDelegate,
ATDPlaceInfoCellDelegate,
ATDDetailMemoProtocol,
MWPhotoBrowserDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *foursquarePhotos;

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
            if ([_memo.latitude floatValue] == 0
                && [_memo.longitude floatValue] == 0) {
                return 0;
            }
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
        cell.delegate = self;
        [cell.photoImageView setImageWithURL:[NSURL fileURLWithPath:_memo.imageFilePath]];
        return cell;
    }
    else if (indexPath.row == DetailTableCellMemo) {
        ATDMemoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ATDMemoCell class])];
        if (_memo.title && ![_memo.title isEqualToString:@""]) {
            cell.memoLabel.text = _memo.title;
            cell.brankLabel.hidden = YES;
        }
        else {
            cell.memoLabel.text = @"";
            cell.brankLabel.hidden = NO;
        }
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
            cell.delegate = self;
            cell.placeNameLabel.text = _memo.placeInfo.name;
            cell.placeDetailLabel.text = _memo.placeInfo.address;
            cell.placeImageView.alpha = 1.0;
            
            if ([_memo.placeInfo.photoUrls count] > 0) {
                [cell.placeImageView setImageWithURL:[NSURL URLWithString:_memo.placeInfo.photoUrls[0]]];
            }
            else {
                cell.placeImageView.image = nil;
            }
            return cell;
        }
    }
    else if (indexPath.row == DetailTableCellMap) {
        if ([_memo.latitude floatValue] == 0
            && [_memo.longitude floatValue] == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            return cell;
        }
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
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark ATDPhotoCellDelegate

- (void)didTapImage:(UIImage *)image {
    [self performSegueWithIdentifier:@"showImage" sender:image];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ACTION"
                                                          action:@"touch"
                                                           label:@"show user photo"
                                                           value:nil] build]];
}


#pragma mark -
#pragma mark ATDMapCellDelegate

- (void)didTapOverlayView {
    [self performSegueWithIdentifier:@"showMap" sender:nil];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ACTION"
                                                          action:@"touch"
                                                           label:@"show map"
                                                           value:nil] build]];
}


#pragma mark -
#pragma mark ATDEditMemoViewController

- (void)didChangeMemo:(PlaceMemo *)memo {
    _memo = memo;
    [_tableView reloadData];
}


#pragma mark -
#pragma mark ATDPlaceInfoCellDelegate

- (void)didTapPlaceImage {
    self.foursquarePhotos = [NSMutableArray array];
    
    NSArray *photoUrls = _memo.placeInfo.photoUrls;
    
    if ([photoUrls count] <= 0) {
        return;
    }
    
    [photoUrls enumerateObjectsUsingBlock:^(NSString *photoUrl, NSUInteger idx, BOOL *stop) {
        [_foursquarePhotos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:photoUrl]]];
    }];
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];    
    // Present
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:browser];
    [self presentViewController:nav animated:YES completion:nil];
    
    // Manipulate
    [browser showNextPhotoAnimated:YES];
    [browser showPreviousPhotoAnimated:YES];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ACTION"
                                                          action:@"touch"
                                                           label:@"show 4sq photos"
                                                           value:nil] build]];
}

#pragma mark -
#pragma mark MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.foursquarePhotos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.foursquarePhotos.count)
        return [self.foursquarePhotos objectAtIndex:index];
    return nil;
}


#pragma mark -
#pragma mark IBAction

- (IBAction)deleteBtnTouched:(id)sender {
    [UIActionSheet showInView:self.view withTitle:NSLocalizedString(@"DELETE_CONFIRM", nil)
            cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
       destructiveButtonTitle:NSLocalizedString(@"GO_DELETE", nil)
            otherButtonTitles:nil
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                         if (actionSheet.destructiveButtonIndex == buttonIndex) {
                             [self deleteMemo];
                         }
                     }];
}

- (void)deleteMemo {
    [[ATDCoreDataManger sharedInstance] deleteMemo:_memo];
    
    [UIAlertView showWithTitle:@"Success!"
                       message:NSLocalizedString(@"DELETE_DONE", nil)
             cancelButtonTitle:nil
             otherButtonTitles:@[@"OK"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          [self.navigationController popToRootViewControllerAnimated:YES];
                      }];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ACTION"
                                                          action:@"touch"
                                                           label:@"delete memo"
                                                           value:nil] build]];
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
    else if ([segue.identifier isEqualToString:@"showImage"]) {
        ATDImageViewController *imageVC = segue.destinationViewController;
        imageVC.delegate = self;
        imageVC.image = sender;
        imageVC.memo = _memo;
    }
    else if ([segue.identifier isEqualToString:@"editMemo"]) {
        ATDEditMemoViewController *editVC = segue.destinationViewController;
        editVC.delegate = self;
        editVC.memo = _memo;
        
        id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ACTION"
                                                              action:@"touch"
                                                               label:@"edit memo"
                                                               value:nil] build]];
    }
}

@end
