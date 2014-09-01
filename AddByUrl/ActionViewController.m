//
//  ActionViewController.m
//  AddByUrl
//
//  Created by 平松　亮介 on 2014/08/28.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <CommonCrypto/CommonCrypto.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "ATODEFramework.h"
#import "ATDCoreDataManger.h"
#import "ATDPlaceholderTextView.h"
#import "ATD4sqPlace.h"
#import "ATDTabelogSearcher.h"
#import "ATDPlaceMemo.h"


@interface ActionViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet ATDPlaceholderTextView *titleTextView;
@property (nonatomic, strong) ATD4sqPlace *placeInfo;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (weak, nonatomic) IBOutlet UIButton *placeAddButton;

@property (weak, nonatomic) IBOutlet UIView *titleFrameView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UILabel *latlngLabel;

@end


@interface ActionViewController ()

@property (nonatomic, strong) ATDTabelogSearcher *searcher;

@end



@implementation ActionViewController


// 見た目の設定
- (void)setAppearance {
    UINavigationBar *navBar = self.navigationController.navigationBar;
    
    navBar.barTintColor = [UIColor colorWithRed:70/255.0 green:171/255.0 blue:235/255.0 alpha:1.0];
    navBar.tintColor = [UIColor whiteColor];
    NSDictionary *attributes = @{
                                 NSFontAttributeName : [UIFont systemFontOfSize:18],
                                 NSForegroundColorAttributeName : [UIColor whiteColor]
                                 };
    navBar.titleTextAttributes = attributes;
}

- (void)setUpViews {
    _titleFrameView.layer.cornerRadius = 3.0f;
    _titleFrameView.layer.masksToBounds = YES;
    
    _placeAddButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _placeAddButton.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    
    _placeAddButton.layer.cornerRadius = 3.0f;
    _placeAddButton.layer.masksToBounds = YES;
    
    _doneButton.layer.cornerRadius = 3.0f;
    _doneButton.layer.masksToBounds = YES;
    
    _cancelButton.layer.cornerRadius = 3.0f;
    _cancelButton.layer.masksToBounds = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setAppearance];
    
    [self setUpViews];
    
    _titleTextView.placeholder = @"メモを追加（オプション）";
    
    // Get the item[s] we're handling from the extension context.
    NSExtensionItem *urlItem = [self.extensionContext.inputItems firstObject];
    NSItemProvider *urlItemProvider = [[urlItem attachments] firstObject];
    
    if ([urlItemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
        [urlItemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL
                                           options:nil
                                 completionHandler:^(NSURL *item, NSError *error) {
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         if (error) {
                                             _urlLabel.text = [NSString stringWithFormat:@"エラー %@", error];
                                         }
                                         else {
                                             _urlLabel.text = item.absoluteString;
                                         }
                                         [_urlLabel sizeToFit];
                                         
                                         [self searchTabelogInfoFromUrl:item.absoluteString];
                                     });
                                 }];
    }
    else {
        _urlLabel.text = @"形式が異なります";
    }
}

- (void)searchTabelogInfoFromUrl:(NSString *)url {
    self.searcher = [ATDTabelogSearcher new];
    [_searcher searchInfoWithTabelogUrl:url
                                handler:^(NSString *title, CLLocation *location, NSString *imageUrl, NSString *errorMsg) {
                                    if (errorMsg) {
                                        _urlLabel.text = [NSString stringWithFormat:@"エラー %@", errorMsg];
                                        return;
                                    }
                                    
                                    if (!imageUrl) {
                                        imageUrl = @"";
                                    }
                                    
                                    _titleTextView.text = title;
                                    _imageView.backgroundColor = [UIColor yellowColor]; // TODO:
                                    [_imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                             if (error) {
                                                                 _imageView.image = nil;
                                                             }
                                                             else {
                                                                 _imageView.image = image;
                                                             }
                                                         }];
                                    
                                    self.coordinate = location.coordinate;
                                    _latlngLabel.text = [NSString stringWithFormat:@"%f, %f",
                                                         _coordinate.latitude,
                                                         _coordinate.longitude];
                                    
                                }];
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
    
    // Save image.
    if (![UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES]) {
        NSLog(@"save file error!");
        return nil;
    }
    
    // TODO: SDWebImageでキャッシュ
    // TODO: 保存失敗した時の処理
    
    return filePath;
}

- (NSString *)postdateFromNow {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    
    return [dateFormatter stringFromDate:[NSDate date]];
    
}

- (void)saveNewMemo {
    // タイトル
    NSString *title = _titleTextView.text;
    
    // 画像
    NSString *filePath = [self saveImageWithImage:_imageView.image];
    if (!filePath) {
        _urlLabel.text = NSLocalizedString(@"FAIL_SAVE_IMAGE", nil);
        return;
    }
    
    // 投稿日時
    NSString *postdate = [self postdateFromNow];
    
    // 保存
    [self saveNewMemoWithTitle:title
                      filePath:filePath
                      postdate:postdate
                       siteUrl:@""];
    
//    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
//    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ACTION"
//                                                          action:@"add"
//                                                           label:title
//                                                           value:nil] build]];
    
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

- (void)saveNewMemoWithTitle:(NSString *)title
                    filePath:(NSString *)filePath
                    postdate:(NSString *)postdate
                     siteUrl:(NSString *)siteUrl {
    ATDPlaceMemo *memo = [ATDPlaceMemo new];
    
    memo.title = title;
    memo.imageFilePath = filePath;
    memo.postdate = postdate;
    memo.siteUrl = siteUrl;
    
    if (_placeInfo) {
        memo.placeInfo = _placeInfo;
    }
    
    if (_coordinate.latitude != 0 && _coordinate.longitude != 0) {
        memo.latitude = _coordinate.latitude;
        memo.longitude = _coordinate.longitude;
    }

    NSLog(@"とうろくするよ！");
    
    [[ATDCoreDataManger sharedInstance] saveNewMemo:memo];
    
    [SVProgressHUD showSuccessWithStatus:@"登録しました"];
    NSLog(@"とうろく完了");
    
//    NSString *logStr = [NSString stringWithFormat:@"4sq[%d] latlng[%d]",
//                        (_placeInfo != nil),
//                        (_coordinate.latitude != 0 && _coordinate.longitude != 0)];
//    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
//    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ACTION"
//                                                          action:@"add"
//                                                           label:logStr
//                                                           value:nil] build]];
}


- (IBAction)doneBtnTouched:(id)sender {
    [self saveNewMemo];
}

- (IBAction)cancelBtnTouched:(id)sender {
        [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}


@end
