//
//  ATDAddViewController.m
//  ATODE
//
//  Created by himara2 on 2014/07/05.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDAddViewController.h"
#import "ATDCoreDataManger.h"
#import "ATDPlaceMemo.h"
#import <CommonCrypto/CommonCrypto.h>

@interface ATDAddViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *titleField;


@end




@implementation ATDAddViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _imageView.image = _image;
}

- (void)saveNewMemoWithTitle:(NSString *)title
                    filePath:(NSString *)filePath
                    postdate:(NSString *)postdate
                     siteUrl:(NSString *)siteUrl {
    ATDPlaceMemo *memo = [ATDPlaceMemo new];
    memo.title = @"Sample Memo";
    memo.imageFilePath = @"image/path";
    memo.postdate = @"2014/04/10";
    memo.siteUrl = @"http://yahoo.co.jp";
    
    [[ATDCoreDataManger sharedInstance] saveNewMemo:memo];
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

- (NSString *)saveImageWithImage:(UIImage *)image {
    NSString *hashStr = [self hashFromImage:image];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DocumentsDirPath = [paths objectAtIndex:0];
    NSString *filePath = [DocumentsDirPath stringByAppendingFormat:@"/%@", hashStr];
    
    NSLog(@"imagePath[%@]", filePath);
    
    // Save image.
    if (![UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES]) {
        NSLog(@"save file error!");
        return nil;
    }
    
    // TODO: SDWebImageでキャッシュ
    // TODO: 保存失敗した時の処理
    
    return hashStr;
}

- (NSString *)postdateFromNow {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    return [dateFormatter stringFromDate:[NSDate date]];
    
}

- (IBAction)addBtnTouched:(id)sender {
    // タイトル
    NSString *title = _titleField.text;
    
    // 画像
    NSString *filePath = [self saveImageWithImage:_image];
    if (!filePath) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                        message:@"画像の保存に失敗しました"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    
    // 投稿日時
    NSString *postdate = [self postdateFromNow];
    NSLog(@"postdate[%@]", postdate);
    
    // TODO: siteUrl（オプション）
    
    // 保存
    [self saveNewMemoWithTitle:title
                      filePath:filePath
                      postdate:postdate
                       siteUrl:@""];
}

@end
