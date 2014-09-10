//
//  ATDPhotoSelector.h
//  ATODE
//
//  Created by himara2 on 2014/09/06.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATDPhotoSelector : NSObject

@property (nonatomic, strong) UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate> *parent;

- (void)showImagePicker;

@end
