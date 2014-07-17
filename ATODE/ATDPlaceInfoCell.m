//
//  ATDPlaceInfoCell.m
//  ATODE
//
//  Created by himara2 on 2014/07/15.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDPlaceInfoCell.h"

@implementation ATDPlaceInfoCell

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
    _placeImageView.layer.cornerRadius = 5.0f;
    _placeImageView.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(didTapPlaceImage)];
    [_placeImageView addGestureRecognizer:tapGesture];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)didTapPlaceImage {
    if ([_delegate respondsToSelector:@selector(didTapPlaceImage)]) {
        [_delegate didTapPlaceImage];
    }
}


@end
