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
#import "ATDPlaceSearchViewController.h"
#import "ATDPlaceholderTextView.h"
#import <CommonCrypto/CommonCrypto.h>
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import <AFNetworking/AFNetworking.h>
#import "GAIDictionaryBuilder.h"

static NSString * const kApiClientID = @"UXFP35M0BBM3BSQS0IEDLDHQECN4PIP5IYE14CD4MBR1VPS2";
static NSString * const kApiClientSecret = @"FWEEVYATFIJXWUOLHBYKDUUVLKEDU2L0DHYJXU5ZA14YCXY2";

@interface ATDAddViewController ()
<UITextFieldDelegate, ATDPlaceSearchViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet ATDPlaceholderTextView *titleTextView;
@property (nonatomic, strong) ATD4sqPlace *placeInfo;
@property (weak, nonatomic) IBOutlet UIButton *placeAddButton;

@property (weak, nonatomic) IBOutlet UIView *titleFrameView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *latlngLabel;

@end



@implementation ATDAddViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _imageView.image = _image;
    
    _titleTextView.placeholder = NSLocalizedString(@"CAN_INPUT_MEMO", nil);
    
    if (_coordinate.latitude != 0 && _coordinate.longitude != 0) {
        _latlngLabel.text = [NSString stringWithFormat:@"%f, %f", _coordinate.latitude, _coordinate.longitude];
    }
    else {
        _latlngLabel.text = NSLocalizedString(@"CANNOT_GET_LOCATION", nil);
    }
    
    [self setUpViews];
    
    [self setBackButton];

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
}

- (void)setBackButton {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                          target:self
                                                                          action:@selector(closeBtnTouched)];
    self.navigationItem.leftBarButtonItem = item;
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
    
    [[ATDCoreDataManger sharedInstance] saveNewMemo:memo];
    
    [UIAlertView showWithTitle:@"Success"
                       message:NSLocalizedString(@"ADD_PLACE", nil)
             cancelButtonTitle:nil
             otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                 if (alertView.cancelButtonIndex != buttonIndex) {
                     [self.navigationController popToRootViewControllerAnimated:YES];
                 }
             }];
    
    
    NSString *logStr = [NSString stringWithFormat:@"4sq[%d] latlng[%d]",
                          (_placeInfo != nil),
                          (_coordinate.latitude != 0 && _coordinate.longitude != 0)];
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ACTION"
                                                          action:@"add"
                                                           label:logStr
                                                           value:nil] build]];
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

- (IBAction)addBtnTouched:(id)sender {
    // タイトル
    NSString *title = _titleTextView.text;
    
    // 画像
    NSString *filePath = [self saveImageWithImage:_image];
    if (!filePath) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil)
                                                        message:NSLocalizedString(@"FAIL_SAVE_IMAGE", nil)
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    
    // 投稿日時
    NSString *postdate = [self postdateFromNow];
    NSLog(@"postdate[%@]", postdate);
    
    // 保存
    [self saveNewMemoWithTitle:title
                      filePath:filePath
                      postdate:postdate
                       siteUrl:@""];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ACTION"
                                                          action:@"add"
                                                           label:title
                                                           value:nil] build]];
}


- (void)reloadMoreVenueInfo {
    NSString *url = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/%@",
                     _placeInfo.venueId];

    NSDictionary *params = @{@"client_id":kApiClientID,
                             @"client_secret":kApiClientSecret,
                             @"v":@"20140707"};

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 4sqページURL
        NSString *shortUrl = responseObject[@"response"][@"venue"][@"shortUrl"];
        _placeInfo.shortUrl = shortUrl;
        NSLog(@"shortUrl is %@", _placeInfo.shortUrl);
        
        // 写真
        NSMutableArray *tmpPhotoUrls = [NSMutableArray array];
        
        NSInteger photoCount = [responseObject[@"response"][@"venue"][@"photos"][@"count"] integerValue];
        if (photoCount > 0) {
            NSArray *items = responseObject[@"response"][@"venue"][@"photos"][@"groups"][0][@"items"];
            [items enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL *stop) {
                NSString *photoUrl = [NSString stringWithFormat:@"%@320x480%@",
                                      item[@"prefix"],
                                      item[@"suffix"]];
                NSLog(@"%@", photoUrl);
                [tmpPhotoUrls addObject:photoUrl];
            }];
        }
        _placeInfo.photoUrls = [NSArray arrayWithArray:tmpPhotoUrls];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error! [%@]", error);
    }];
}


#pragma mark -
#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}


#pragma mark -
#pragma mark ATDPlaceSearchViewControllerDelegate

- (void)didSelectPlace:(ATD4sqPlace *)placeInfo {
    self.placeInfo = placeInfo;
    [_placeAddButton setTitle:_placeInfo.name forState:UIControlStateNormal];
    
    // Venueの画像取得する
    [self reloadMoreVenueInfo];
}


#pragma mark -
#pragma mark IBAction

- (void)closeBtnTouched {
    [UIAlertView showWithTitle:NSLocalizedString(@"CONFIRM", nil)
                       message:NSLocalizedString(@"DELETE_EDITED_OK", nil)
             cancelButtonTitle:NSLocalizedString(@"CANCEL", nik)
             otherButtonTitles:@[NSLocalizedString(@"DESTROY", nil)]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (alertView.cancelButtonIndex != buttonIndex) {
                              [self.navigationController popViewControllerAnimated:YES];
                          }
                      }];
}

#pragma mark -
#pragma mark Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"show4sq"]) {
        ATDPlaceSearchViewController *searchVC = segue.destinationViewController;
        searchVC.delegate = self;
        searchVC.coordinate = _coordinate;
    }
}

@end
