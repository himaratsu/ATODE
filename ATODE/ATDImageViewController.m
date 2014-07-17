//
//  ATDImageViewController.m
//  ATODE
//
//  Created by 平松　亮介 on 2014/07/17.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDImageViewController.h"

@interface ATDImageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end



@implementation ATDImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _imageView.image = _image;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(didTapView)];
    [self.view addGestureRecognizer:tapGesture];
}

- (IBAction)closeBtnTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapView {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
