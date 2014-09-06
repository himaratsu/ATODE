//
//  ATDPhotoCell.m
//  ATODE
//
//  Created by himara2 on 2014/07/15.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDPhotoCell.h"

@implementation ATDPhotoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(imageTouched)];
    [_photoImageView addGestureRecognizer:tapGesture];
    
    _editButton.layer.masksToBounds = YES;
    _editButton.layer.cornerRadius = 12.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)imageTouched {
    if ([_delegate respondsToSelector:@selector(didTapImage:)]) {
        [_delegate didTapImage:_photoImageView.image];
    }
}

- (IBAction)editBtnTouched:(id)sender {
    // カメラロール出したり
}


@end
