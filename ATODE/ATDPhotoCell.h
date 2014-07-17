//
//  ATDPhotoCell.h
//  ATODE
//
//  Created by himara2 on 2014/07/15.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ATDPhotoCellDelegate <NSObject>

- (void)didTapImage:(UIImage *)image;

@end


@interface ATDPhotoCell : UITableViewCell

@property (nonatomic, weak) id<ATDPhotoCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@end
