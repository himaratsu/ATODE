//
//  MKMapView+ATDZoomLevel.h
//  ATODE
//
//  Created by himara2 on 2014/07/13.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (ATDZoomLevel)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;

@end
