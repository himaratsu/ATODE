//
//  ATDPhotoSelector.m
//  ATODE
//
//  Created by himara2 on 2014/09/06.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDPhotoSelector.h"
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>

@implementation ATDPhotoSelector

- (void)showImagePicker {
    [UIActionSheet showInView:_parent.view
                    withTitle:NSLocalizedString(@"PHOTO_EDIT", nil)
            cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
       destructiveButtonTitle:nil
            otherButtonTitles:@[NSLocalizedString(@"TAKE_PICTURE", nil),
                                NSLocalizedString(@"SELECT_LIBRARY", nil)]
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                         if (buttonIndex != actionSheet.cancelButtonIndex) {
                             if (buttonIndex == 0) {
                                 [self getPhotoFromCamera];
                             }
                             else if (buttonIndex == 1) {
                                 [self getPhotoFromLibrary];
                             }
                         }
                     }];
}

- (void)getPhotoFromCamera {
#if (TARGET_IPHONE_SIMULATOR)
    // シミュレータで動作中
    UIImage *image = [UIImage imageNamed:@"sample.jpg"];
#else
    // 実機で動作中
    [self showImagePickerView:UIImagePickerControllerSourceTypeCamera];
#endif
    
    //    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    //    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ACTION"
    //                                                          action:@"touch"
    //                                                           label:@"add from camera"
    //                                                           value:nil] build]];
}

- (void)getPhotoFromLibrary {
    [self showImagePickerView:UIImagePickerControllerSourceTypePhotoLibrary];
    
    //    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    //    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ACTION"
    //                                                          action:@"touch"
    //                                                           label:@"add from library"
    //                                                           value:nil] build]];
}

- (void)showImagePickerView:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = _parent;
    picker.sourceType = sourceType;
    picker.allowsEditing = YES;
    [_parent presentViewController:picker animated:YES completion:nil];
}


@end
