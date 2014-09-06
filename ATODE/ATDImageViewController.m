//
//  ATDImageViewController.m
//  ATODE
//
//  Created by 平松　亮介 on 2014/07/17.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDImageViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <CommonCrypto/CommonCrypto.h>
#import "ATDCoreDataManger.h"

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
    [self showImagePicker];
}

- (void)showImagePicker {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
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
    NSString *filePath = [self saveImageWithImage:image];
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

- (NSString *)todayStr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddhhmmss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    return dateStr;
}

- (NSString *)saveImageWithImage:(UIImage *)image {
    NSString *hashStr = [self hashFromImage:image];
    hashStr = [NSString stringWithFormat:@"%@%@", hashStr, [self todayStr]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DocumentsDirPath = [paths objectAtIndex:0];
    NSString *filePath = [DocumentsDirPath stringByAppendingFormat:@"/%@", hashStr];
    
    // Save image.
    if (![UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES]) {
        NSLog(@"save file error!");
        return nil;
    }
    
    // TODO: SDWebImageでキャッシュ
    // TODO: 保存失敗した時の処理
    
    return filePath;
}

- (NSString *)hashFromImage:(UIImage *)image {
    unsigned char   result[16];
    NSData*         data;
    data = UIImagePNGRepresentation(image);
    CC_MD5([data bytes], [data length], result);
    
    NSString* hashStr =  [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                          result[0], result[1],
                          result[2], result[3],
                          result[4], result[5],
                          result[6], result[7],
                          result[8], result[9],
                          result[10], result[11],
                          result[12], result[13],
                          result[14], result[15]];
    
    return hashStr;
    
}

@end
