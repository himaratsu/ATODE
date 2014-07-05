//
//  ATDAddViewController.m
//  ATODE
//
//  Created by himara2 on 2014/07/05.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDAddViewController.h"

@interface ATDAddViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end




@implementation ATDAddViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _imageView.image = _image;
}




@end
