//
//  ATDSettingViewController.h
//  ATODE
//
//  Created by himara2 on 2014/07/12.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#define SUPPORT_MAIL_ADDRESS @"himaratsu.dev@gmail.com"

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, kSettingCellType) {
    kSettingCellTypeRequest,
    kSettingCellTypeIntroduce,
    kSettingCellTypeReview,
    kSettingCellTypeLicense,
    kSettingCellTypeVersion
};

@interface ATDSettingViewController : UIViewController

@end
