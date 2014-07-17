//
//  ATDPlaceInfoCell.h
//  ATODE
//
//  Created by himara2 on 2014/07/15.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ATDPlaceInfoCellDelegate <NSObject>

- (void)didTapPlaceImage;

@end


@interface ATDPlaceInfoCell : UITableViewCell

@property (nonatomic, weak) id<ATDPlaceInfoCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *placeImageView;
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeDetailLabel;

@end
