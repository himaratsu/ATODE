//
//  ATDEditMemoViewController.h
//  ATODE
//
//  Created by 平松　亮介 on 2014/07/17.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceMemo.h"
#import "ATDDetailViewController.h"

@interface ATDEditMemoViewController : UIViewController

@property (nonatomic, assign) id<ATDDetailMemoProtocol> delegate;
@property (nonatomic, strong) PlaceMemo *memo;

@end
