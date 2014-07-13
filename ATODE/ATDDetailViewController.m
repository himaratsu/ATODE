//
//  ATDDetailViewController.m
//  ATODE
//
//  Created by himara2 on 2014/07/13.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDDetailViewController.h"
#import "ATDPlaceMemo.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ATDDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *memoLabel;
@property (weak, nonatomic) IBOutlet UILabel *postdateLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeInfoLabel;

@end



@implementation ATDDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadData];
}

- (void)reloadData {
    [_imageView setImageWithURL:[NSURL fileURLWithPath:_memo.imageFilePath]];
    _memoLabel.text = _memo.title;
    _postdateLabel.text = _memo.postdate;
    if (_memo.placeInfo) {
        _placeInfoLabel.text = _memo.placeInfo.name;
    }
    else {
        _placeInfoLabel.text = @"";
    }
}




@end
