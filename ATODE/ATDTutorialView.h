//
//  ATDTutorialView.h
//  ATODE
//
//  Created by 平松　亮介 on 2014/07/29.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *kTutorialDoneFlag;

@interface ATDTutorialView : UIView

@property (nonatomic, assign) BOOL isFirstTutorial;

+ (instancetype)view;
- (void)show;

@end
