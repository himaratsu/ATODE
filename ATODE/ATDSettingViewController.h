//
//  ATDSettingViewController.h
//  ATODE
//
//  Created by himara2 on 2014/07/12.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#define SUPPORT_MAIL_ADDRESS    @"himaratsu.dev@gmail.com"
#define APP_STORE_URL           @"http://itunes.apple.com/ja/app/id903841654?mt=8"
#define DEVELOPER_TWITTER_URL   @"https://twitter.com/himara2"

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, kSettingCellType) {
    kSettingCellTypeHowToUse,
    kSettingCellTypeRequest,
    kSettingCellTypeIntroduce,
    kSettingCellTypeReview,
    kSettingCellTypeLicense,
    kSettingCellTypeVersion
};

@interface ATDSettingViewController : UIViewController

@end
