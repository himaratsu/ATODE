//
//  ATDTutorialStartView.h
//  ATODE
//
//  Created by himara2 on 2014/08/01.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ATDTutorialStartViewDelegate <NSObject>

- (void)didTouchStartBtn;

@end


@interface ATDTutorialStartView : UIView

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (nonatomic, weak) id<ATDTutorialStartViewDelegate> delegate;
+ (instancetype)view;

@end
