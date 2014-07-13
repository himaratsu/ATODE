//
//  ATDPlaceSearchViewController.h
//  ATODE
//
//  Created by himara2 on 2014/07/06.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class ATD4sqPlace;


@protocol ATDPlaceSearchViewControllerDelegate <NSObject>

- (void)didSelectPlace:(ATD4sqPlace *)placeInfo;

@end


@interface ATDPlaceSearchViewController : UIViewController

@property (nonatomic, weak) id<ATDPlaceSearchViewControllerDelegate> delegate;
@property (nonatomic, strong) CLLocation *location;

@end
