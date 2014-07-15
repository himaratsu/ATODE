//
//  ATDMapCell.h
//  ATODE
//
//  Created by himara2 on 2014/07/15.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlaceMemo;

@protocol ATDMapCellDelegate <NSObject>

- (void)didTapOverlayView;

@end



@interface ATDMapCell : UITableViewCell

@property (nonatomic, weak) id<ATDMapCellDelegate> delegate;
@property (nonatomic, strong) PlaceMemo *memo;

@end
