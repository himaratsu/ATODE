//
//  ATDTutorialView.m
//  ATODE
//
//  Created by 平松　亮介 on 2014/07/29.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDTutorialView.h"
#import "ATDTutorialStartView.h"
#import "ATDTutorialFinalView.h"
#import "ATDAppDelegate.h"


NSString *kTutorialDoneFlag = @"kTutorialDoneFlag";

@interface ATDTutorialView ()
<UIScrollViewDelegate,
ATDTutorialStartViewDelegate,
ATDTutorialFinalViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *backOverlayView;

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
    _pageControl.alpha = 0.0;
    
    [UIView animateWithDuration:0.2f
                          delay:0.f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _scrollView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         _scrollView.alpha = 1.0;
                         _pageControl.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                         [defaults setBool:YES forKey:kTutorialDoneFlag];
                         [defaults synchronize];
                     }];
}

- (void)awakeFromNib {
    _scrollView.layer.cornerRadius = 6.0f;
    _scrollView.layer.masksToBounds = YES;
    
    [self setUpViews];
}

- (void)setUpViews {
    // 最初は特別扱い
    ATDTutorialStartView *startView = [ATDTutorialStartView view];
    startView.frame = CGRectMake(0,
                                 0,
                                 _scrollView.frame.size.width,
                                 _scrollView.frame.size.height);
    startView.delegate = self;
    [_scrollView addSubview:startView];
    
    NSArray *normalNibNames = @[@"ATDTutorialFirstView",
                                @"ATDTutorialSecondView",
                                @"ATDTutorialThirdView"];
    
    [normalNibNames enumerateObjectsUsingBlock:^(NSString *nibName, NSUInteger idx, BOOL *stop) {
        UIView *view = [self viewByNibName:nibName];
        view.frame = CGRectMake((idx+1)*_scrollView.frame.size.width,
                                0,
                                _scrollView.frame.size.width,
                                _scrollView.frame.size.height);
        [_scrollView addSubview:view];
    }];
    
    // 最後は特別扱い
    ATDTutorialFinalView *finalView = [ATDTutorialFinalView view];
    finalView.frame = CGRectMake((normalNibNames.count+1)*_scrollView.frame.size.width,
                                 0,
                                 _scrollView.frame.size.width,
                                 _scrollView.frame.size.height);
    finalView.delegate = self;
    [_scrollView addSubview:finalView];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * (normalNibNames.count + 2),
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
#pragma mark ATDTutorialStartViewDelegate

- (void)didTouchStartBtn {
    CGRect frame = CGRectMake(_scrollView.frame.size.width+1,
                              0,
                              _scrollView.frame.size.width,
                              _scrollView.frame.size.height);
    [_scrollView scrollRectToVisible:frame animated:YES];
}

#pragma mark -
#pragma mark ATDTutorialFinalViewDelegate

- (void)didTouchDoneBtn {
    [self exitTutorial];
}

- (void)exitTutorial {
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

#pragma mark -
#pragma mark IBAction

- (IBAction)brankBtnTouched:(id)sender {
    if (!_isFirstTutorial) {
        [self exitTutorial];
    }
}

- (IBAction)pageControllerTouched:(UIPageControl *)sender {
    CGRect frame = CGRectMake(sender.currentPage *_scrollView.frame.size.width+1,
                              0,
                              _scrollView.frame.size.width,
                              _scrollView.frame.size.height);
    [_scrollView scrollRectToVisible:frame animated:YES];
}


@end
