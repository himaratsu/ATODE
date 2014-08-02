//
//  ATDTutorialStartView.m
//  ATODE
//
//  Created by himara2 on 2014/08/01.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDTutorialStartView.h"

@implementation ATDTutorialStartView

+ (instancetype)view {
    NSString *className = NSStringFromClass([self class]);
    return [[[NSBundle mainBundle] loadNibNamed:className owner:nil options:0] firstObject];
}

- (void)awakeFromNib {
    _startButton.layer.cornerRadius = 4.0f;
    _startButton.layer.masksToBounds = YES;
}

- (IBAction)startBtnTouched:(id)sender {
    if ([_delegate respondsToSelector:@selector(didTouchStartBtn)]) {
        [_delegate didTouchStartBtn];
    }
}




@end
