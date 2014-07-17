//
//  ATDPlaceholderTextView.h
//  ATODE
//
//  Created by 平松　亮介 on 2014/07/17.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATDPlaceholderTextView : UITextView

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;

- (void)textChanged:(NSNotification*)notification;

@end
