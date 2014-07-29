//
//  ATDTutorialView.m
//  ATODE
//
//  Created by 平松　亮介 on 2014/07/29.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDTutorialView.h"
#import "ATDTutorialFinalView.h"
#import "ATDAppDelegate.h"

@interface ATDTutorialView ()
<UIScrollViewDelegate, ATDTutorialFinalViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end



@implementation ATDTutorialView

+ (instancetype)view {
    NSString *className = NSStringFromClass([self class]);
    return [[[NSBundle mainBundle] loadNibNamed:className owner:nil options:0] firstObject];
}

- (void)show {
    ATDAppDelegate *appDelegate = (ATDAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window addSubview:self];
    
    CGAffineTransform zoom = CGAffineTransformMakeScale(0.9, 0.9);
    _scrollView.transform = zoom;
    
    _scrollView.alpha = 0.3;
    
    [UIView animateWithDuration:0.2f
                          delay:0.f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _scrollView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         _scrollView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)awakeFromNib {
    _scrollView.layer.cornerRadius = 6.0f;
    _scrollView.layer.masksToBounds = YES;
    
    [self setUpViews];
}

- (void)setUpViews {
    NSArray *normalNibNames = @[@"ATDTutorialFirstView",
                                @"ATDTutorialSecondView",
                                @"ATDTutorialThirdView"];
    
    [normalNibNames enumerateObjectsUsingBlock:^(NSString *nibName, NSUInteger idx, BOOL *stop) {
        UIView *view = [self viewByNibName:nibName];
        view.frame = CGRectMake(idx*_scrollView.frame.size.width,
                                0,
                                _scrollView.frame.size.width,
                                _scrollView.frame.size.height);
        [_scrollView addSubview:view];
    }];
    
    // 最後は特別扱い
    ATDTutorialFinalView *finalView = [ATDTutorialFinalView view];
    finalView.frame = CGRectMake((normalNibNames.count)*_scrollView.frame.size.width,
                                 0,
                                 _scrollView.frame.size.width,
                                 _scrollView.frame.size.height);
    finalView.delegate = self;
    [_scrollView addSubview:finalView];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * (normalNibNames.count + 1),
                                         _scrollView.frame.size.height);
    
    _scrollView.alpha = 0.0;
}

- (UIView *)viewByNibName:(NSString *)nibName {
    return [[[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:0] firstObject];
}


#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    _pageControl.currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}


#pragma mark -
#pragma mark ATDTutorialFinalViewDelegate

- (void)didTouchDoneBtn {
    [UIView animateWithDuration:0.15f
                     animations:^{
                         // expand animation
                         CGAffineTransform zoom = CGAffineTransformMakeScale(1.05, 1.05);
                         self.transform = zoom;
                         self.alpha = 0.3;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

@end
