//
//  ATDAddViewController.h
//  ATODE
//
//  Created by himara2 on 2014/07/05.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ATDAddViewController : UIViewController

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

// ----- 食べログなどのサイトから登録する場合
@property (nonatomic, assign) BOOL isRegistFromSite;
@property (nonatomic, strong) NSString *defaultMemoStr;
@property (nonatomic, strong) NSString *imageUrl;

@end
