//
//  ATDDetailViewController.m
//  ATODE
//
//  Created by himara2 on 2014/07/13.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDDetailViewController.h"
#import "PlaceMemo.h"
#import "ATDCoreDataManger.h"
#import "MKMapView+ATDZoomLevel.h"
#import "ATDAnnotation.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import <MapKit/MapKit.h>

@interface ATDDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *memoLabel;
@property (weak, nonatomic) IBOutlet UILabel *postdateLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeInfoLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end



@implementation ATDDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpMapView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadData];
}

- (void)setUpMapView {
    double lat = [_memo.latitude doubleValue];
    double lng = [_memo.longitude doubleValue];
    
    CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(lat, lng);
    [_mapView setCenterCoordinate:locationCoordinate zoomLevel:15 animated:YES];
    
    ATDAnnotation *annotation = [[ATDAnnotation alloc] initWithCoordinate:locationCoordinate
                                                                    title:_memo.placeInfo.name
                                                                 subtitle:_memo.title];
    [_mapView addAnnotation:annotation];
}

- (void)reloadData {
    [_imageView setImageWithURL:[NSURL fileURLWithPath:_memo.imageFilePath]];
    _memoLabel.text = _memo.title;
    _postdateLabel.text = _memo.postdate;
    if (_memo.placeInfo) {
        _placeInfoLabel.text = _memo.placeInfo.name;
    }
    else {
        _placeInfoLabel.text = @"";
    }
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





@end
