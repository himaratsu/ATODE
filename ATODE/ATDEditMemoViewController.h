//
//  ATDEditMemoViewController.h
//  ATODE
//
//  Created by 平松　亮介 on 2014/07/17.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceMemo.h"

@protocol ATDEditMemoViewControllerDelegate <NSObject>

- (void)didChangeMemo:(PlaceMemo *)memo;

@end


@interface ATDEditMemoViewController : UIViewController

@property (nonatomic, assign) id<ATDEditMemoViewControllerDelegate> delegate;
@property (nonatomic, strong) PlaceMemo *memo;

@end
