//
//  ATDImageViewController.m
//  ATODE
//
//  Created by 平松　亮介 on 2014/07/17.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDImageViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>
#import "ATDCoreDataManger.h"
#import "ATDPhotoSelector.h"
#import "ATDSavePhotoHandler.h"

@interface ATDImageViewController ()
<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

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

- (IBAction)editBtnTouched:(id)sender {
    ATDPhotoSelector *photoSelector = [[ATDPhotoSelector alloc] init];
    photoSelector.parent = self;
    [photoSelector showImagePicker];
}


- (void)didTapView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        [self saveNewPhoto:image];
    }
    else if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *originImage = info[UIImagePickerControllerOriginalImage];
        
        NSMutableDictionary *metadata = (NSMutableDictionary *)[info objectForKey:UIImagePickerControllerMediaMetadata];
        
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary writeImageToSavedPhotosAlbum:originImage.CGImage metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                NSLog(@"Save image failed. %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                                message:@"写真保存時にエラーが発生しました。申し訳ありませんが再度撮影してください"
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
                [alert show];
            }
            else {
                [self saveNewPhoto:image];
            }
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark Update Memo Info

- (void)saveNewPhoto:(UIImage *)image {
    NSLog(@"新しい画像に差し替えます");
    
    // 画像の保存
    ATDSavePhotoHandler *saveHandler = [[ATDSavePhotoHandler alloc] init];
    NSString *filePath = [saveHandler saveImageWithImage:image];
    if (!filePath) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil)
                                                        message:NSLocalizedString(@"FAIL_SAVE_IMAGE", nil)
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    
    // CoreDataに編集しているデータの変更
    PlaceMemo *newMemo = [[ATDCoreDataManger sharedInstance] updateMemo:_memo imageFilePath:filePath];
    
    // UI update
    self.image = image;
    
    if ([_delegate respondsToSelector:@selector(didChangeMemo:)]) {
        [_delegate didChangeMemo:newMemo];
    }
}

@end
