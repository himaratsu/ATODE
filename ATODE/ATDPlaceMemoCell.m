//
//  ATDPlaceMemoCell.m
//  ATODE
//
//  Created by himara2 on 2014/07/05.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDPlaceMemoCell.h"

@interface ATDPlaceMemoCell ()

@property (weak, nonatomic) IBOutlet UIView *gradientBackgroundView;

@end



@implementation ATDPlaceMemoCell

- (void)awakeFromNib {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    CGFloat cellSize = ([UIScreen mainScreen].bounds.size.width - 30) / 2;
    gradient.frame = CGRectMake(0, 0, cellSize, cellSize);
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
    [self.gradientBackgroundView.layer insertSublayer:gradient atIndex:0];
    self.gradientBackgroundView.alpha = 0.6f;
}

@end
