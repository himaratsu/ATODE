//
//  ATDMapViewController.m
//  ATODE
//
//  Created by himara2 on 2014/07/14.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDMapViewController.h"
#import "MKMapView+ATDZoomLevel.h"
#import "ATDAnnotation.h"
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>

@interface ATDMapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end


@implementation ATDMapViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpMapView];
}

- (void)setUpMapView {
    CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(_latitude, _longitude);
    [_mapView setCenterCoordinate:locationCoordinate zoomLevel:15 animated:YES];
    
    ATDAnnotation *annotation = [[ATDAnnotation alloc] initWithCoordinate:locationCoordinate
                                                                    title:@"Place"
                                                                 subtitle:@""];
    [_mapView addAnnotation:annotation];
    
    _mapView.showsUserLocation = YES;
}



#pragma mark -
#pragma mark IBAction

- (IBAction)closeBtnTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionBtnTouched:(id)sender {
[UIActionSheet showInView:self.view
                withTitle:NSLocalizedString(@"OPEN_OTHER_APP", nil)
        cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
   destructiveButtonTitle:nil
        otherButtonTitles:@[NSLocalizedString(@"OPEN_IOS_MAP", nil),
                            NSLocalizedString(@"OPEN_GOOGLE_MAP", nil)]
                 tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                     if (actionSheet.cancelButtonIndex != buttonIndex) {
                         if (buttonIndex == 0) {
                             [self openNativeMap];
                         }
                         else if (buttonIndex == 1) {
                             [self openGoogleMap];
                         }
                     }
                 }];
}


- (void)openNativeMap {
    NSString *urlStr = [NSString stringWithFormat:@"http://maps.apple.com/maps?q=%f,%f&z=15",
                        _latitude, _longitude];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
}

- (void)openGoogleMap {
    NSString *urlStr = [NSString stringWithFormat:@"comgooglemaps://?q=%f,%f&zoom=15",
                        _latitude, _longitude];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    }
    else {
        NSLog(@"google map not installed");
    }
}



@end
