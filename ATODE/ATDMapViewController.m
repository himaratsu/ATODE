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



@end
