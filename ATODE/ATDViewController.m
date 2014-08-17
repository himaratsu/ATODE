//
//  ATDViewController.m
//  ATODE
//
//  Created by himara2 on 2014/06/29.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDViewController.h"
#import "ATDPlaceMemoCell.h"
#import "ATDAddViewController.h"
#import "ATDDetailViewController.h"
#import "ATDCoreDataManger.h"
#import "ATDTabelogSearcher.h"
#import "PlaceMemo.h"
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <ImageIO/ImageIO.h>
#import <MapKit/MapKit.h>
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "MKMapView+ATDZoomLevel.h"
#import "ATDAnnotation.h"
#import "ATDTutorialView.h"
#import "GADBannerView.h"
#import "GAIDictionaryBuilder.h"

static NSString * const kBannerUnitID = @"ca-app-pub-5042077439159662/4239166953";

@interface ATDViewController ()
<UICollectionViewDataSource, UICollectionViewDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate,
CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *noItemView;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray *memos;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, assign) BOOL isLocationLoading;

@property (nonatomic, strong) ALAssetsLibrary *library;

@property (nonatomic, assign) CLLocationCoordinate2D imageCoordinate;


@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSMutableArray *pins;

@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegmentedControl;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;

@property (nonatomic, strong) ATDTabelogSearcher *searcher;

// ad
@property (nonatomic, strong) GADBannerView *bannerView;

@end



@implementation ATDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self registerNib];
    
    [self setUpViews];
    
    [self setUpBannerView];
    
    // 最初はリスト表示
    [self showTypeChanged:YES];
    
    // 初回ならチュートリアル
    BOOL isDoneTutorial = [[NSUserDefaults standardUserDefaults] boolForKey:kTutorialDoneFlag];
    if (!isDoneTutorial) {
        [self showTutorialView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    _isLocationLoading = NO;
    [self startUpdateLocation];

    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_locationManager stopUpdatingLocation];
    [super viewWillDisappear:animated];
}

- (void)startUpdateLocation {
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    
    [self.locationManager startUpdatingLocation];
}

- (void)registerNib {
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([ATDPlaceMemoCell class])
                                               bundle:[NSBundle mainBundle]]
      forCellWithReuseIdentifier:NSStringFromClass([ATDPlaceMemoCell class])];
}

- (void)setUpViews {
    // Refresh Control
    self.refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor grayColor];
    [_refreshControl addTarget:self action:@selector(refershControlAction) forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.showsVerticalScrollIndicator = YES;
    
    FAKFontAwesome *icon = [FAKFontAwesome gearIconWithSize:20];
    self.leftBarButtonItem.image = [icon imageWithSize:CGSizeMake(20, 20)];
}

- (void)setUpBannerView {
    self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    _bannerView.adUnitID = kBannerUnitID;
    _bannerView.rootViewController = self;
    _bannerView.backgroundColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0];
    _bannerView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-50, 320, 50);
    [self.view addSubview:_bannerView];
    
    [_bannerView loadRequest:[GADRequest request]];
}



- (void)setUpMapViews {
    [self resetMapErrorViews];
    
    if (_currentLocation) {
        NSLog(@"setUpMapViews");
        CLLocationCoordinate2D locationCoordinate = _currentLocation.coordinate;
        [_mapView setCenterCoordinate:locationCoordinate zoomLevel:15 animated:NO];
        
        _mapView.showsUserLocation = YES;
        
        // add pins
        [self setUpPins];
    }
    else {
        NSLog(@"setUpMapViews not _currentLoc");
    }
}

- (void)resetMapErrorViews {
    UIView *errorOverlayView = [self.view viewWithTag:1];
    [errorOverlayView removeFromSuperview];
    
    UIView *descLabel = [self.view viewWithTag:2];
    [descLabel removeFromSuperview];
}

- (void)setUpMapErrorViews {
    [self resetMapErrorViews];
    
    UIView *errorOverlayView = [[UIView alloc] initWithFrame:_mapView.bounds];
    errorOverlayView.backgroundColor = [UIColor blackColor];
    errorOverlayView.alpha = 0.7;
    errorOverlayView.tag = 1;
    [_mapView addSubview:errorOverlayView];
    
    UILabel *descLabel = [[UILabel alloc] initWithFrame:_mapView.bounds];
    descLabel.text = NSLocalizedString(LOCATION_SETTING_NOTICE, nil);
    descLabel.numberOfLines = 0;
    descLabel.tag = 2;
    descLabel.font = [UIFont systemFontOfSize:13.0f];
    descLabel.textAlignment = NSTextAlignmentCenter;
    descLabel.textColor = [UIColor whiteColor];
    [_mapView addSubview:descLabel];
}

- (void)resetPins {
    NSMutableArray * annotationsToRemove = [_mapView.annotations mutableCopy];
    [annotationsToRemove removeObject:_mapView.userLocation];
    [_mapView removeAnnotations:annotationsToRemove];
}

- (void)setUpPins {
    [self resetPins];
    
    [_memos enumerateObjectsUsingBlock:^(PlaceMemo *memo, NSUInteger idx, BOOL *stop) {
        if ([memo.latitude floatValue] != 0
            && [memo.longitude floatValue] != 0) {
            CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake([memo.latitude floatValue],
                                                                                   [memo.longitude floatValue]);
            
            // 空欄対策
            NSString *pinTitle = @"メモなし";
            NSString *pinSubTitle = @"";
            if (memo.title) {
                pinTitle = memo.title;
            }
            
            if (memo.placeInfo.address) {
                pinSubTitle = memo.placeInfo.address;
            }

            
            ATDAnnotation *annotation = [[ATDAnnotation alloc] initWithCoordinate:locationCoordinate
                                                                            title:pinTitle
                                                                         subtitle:pinSubTitle];
            annotation.memo = memo;
            
            [_mapView addAnnotation:annotation];
            
            NSLog(@"add pin [%@ - %@]", memo.latitude, memo.longitude);
        }
    }];
}

- (void)reloadData {
    _isLocationLoading = NO;
    NSArray *memos = [[ATDCoreDataManger sharedInstance] getAllMemos];
    self.memos = [self sortMemoByDistance:memos];
    
    if (_memos.count == 0) {
        _noItemView.hidden = NO;
    }
    else {
        _noItemView.hidden = YES;
    }
    
    [_collectionView reloadData];
    
    [_refreshControl endRefreshing];
}


- (NSArray *)sortMemoByDistance:(NSArray *)memos {
    if (!_currentLocation) {
        return memos;
    }
    
    NSArray *sorterdMemos =
    [memos sortedArrayUsingComparator:^NSComparisonResult(PlaceMemo *memo1, PlaceMemo *memo2) {
        CLLocation *location1 = [[CLLocation alloc] initWithLatitude:[memo1.latitude doubleValue]
                                                           longitude:[memo1.longitude doubleValue]];
        CLLocation *location2 = [[CLLocation alloc] initWithLatitude:[memo2.latitude doubleValue]
                                                           longitude:[memo2.longitude doubleValue]];
        
        CLLocationDistance distance1 = [_currentLocation distanceFromLocation:location1];
        CLLocationDistance distance2 = [_currentLocation distanceFromLocation:location2];
        
        return distance1 > distance2;
    }];
    
    return sorterdMemos;
}

// 写真撮影画面へ遷移
- (void)showImagePickerView:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = sourceType;
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark -
#pragma mark IBAction

- (IBAction)addBtnTouched:(id)sender {
    [UIActionSheet showInView:self.view
                    withTitle:NSLocalizedString(PHOTO, nil)
            cancelButtonTitle:NSLocalizedString(CANCEL, nil)
       destructiveButtonTitle:nil
            otherButtonTitles:@[NSLocalizedString(TAKE_PICTURE, nil),
                                NSLocalizedString(SELECT_LIBRARY, nil),
                                @"食べログから追加 (コピー中のURLを使用)"]
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                         if (buttonIndex != actionSheet.cancelButtonIndex) {
                             if (buttonIndex == 0) {
                                 [self getPhotoFromCamera];
                             }
                             else if (buttonIndex == 1) {
                                 [self getPhotoFromLibrary];
                             }
                             else if (buttonIndex == 2) {
                                 [self getInfoFromTabelog];
                             }
                         }
                     }];
}


- (void)getPhotoFromCamera {
#if (TARGET_IPHONE_SIMULATOR)
    // シミュレータで動作中
    UIImage *image = [UIImage imageNamed:@"sample.jpg"];
    [self performSegueWithIdentifier:@"showAdd" sender:image];
#else
    // 実機で動作中
    [self showImagePickerView:UIImagePickerControllerSourceTypeCamera];
#endif
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ACTION"
                                                          action:@"touch"
                                                           label:@"add from camera"
                                                           value:nil] build]];
}

- (void)getPhotoFromLibrary {
    [self showImagePickerView:UIImagePickerControllerSourceTypePhotoLibrary];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ACTION"
                                                          action:@"touch"
                                                           label:@"add from library"
                                                           value:nil] build]];
}

- (void)getInfoFromTabelog {
    // Pasteboardをチェックして
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    NSString *url = [board valueForPasteboardType:@"public.text"];
    
    // パターンにマッチすれば提案を出す
    NSString *host = [[NSURL URLWithString:url] host];
    if ([host isEqualToString:@"tabelog.com"]
        || [host isEqualToString:@"s.tabelog.com"]
        || [host isEqualToString:@"r.gnavi.co.jp"]) {
        self.searcher = [ATDTabelogSearcher new];
        [_searcher searchInfoWithTabelogUrl:url
                                    handler:^(NSString *title, CLLocation *location, NSString *imageUrl, NSString *errorMsg) {
                                        if (errorMsg) {
                                            [UIAlertView showWithTitle:@"エラー"
                                                               message:errorMsg
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:@[@"OK"]
                                                              tapBlock:nil];
                                            return;
                                        }
                                        
                                        NSLog(@"===== success =====");
                                        NSLog(@"title[%@]", title);
                                        NSLog(@"coordinate[%f-%f]", location.coordinate.latitude, location.coordinate.longitude);
                                        NSLog(@"imageUrl[%@]", imageUrl);
                                        
                                        NSDictionary *params = @{@"title":title,
                                                                 @"location":location,
                                                                 @"imageUrl":imageUrl};
                                        [self performSegueWithIdentifier:@"showAddFromSite" sender:params];
                                        
                                    }];
    }
    else {
        [UIAlertView showWithTitle:@"コピーされている文字列がありません"
                           message:@"食べログのURLをコピーして再度お試しください"
                 cancelButtonTitle:nil
                 otherButtonTitles:@[@"OK"]
                          tapBlock:nil];
    }
}

- (void)gotoAddViewWithAsset:(NSURL *)assetURL image:(UIImage *)image {
    self.library = [[ALAssetsLibrary alloc] init];
    [_library assetForURL:assetURL
             resultBlock:^(ALAsset *asset) {
                 
                 //画像があればYES、無ければNOを返す
                 if(asset){
                     NSLog(@"データがあります");
                     ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
                     NSDictionary *metadata = [assetRepresentation metadata];
                     
                     if ([[metadata allKeys] containsObject:@"{GPS}"]) {
                         NSDictionary *gpsInfo = metadata[@"{GPS}"];
                         
                         double lat = [gpsInfo[@"Latitude"] doubleValue];
                         double lng = [gpsInfo[@"Longitude"] doubleValue];

                         self.imageCoordinate = CLLocationCoordinate2DMake(lat, lng);
                         [self performSegueWithIdentifier:@"showAdd" sender:image];
                     }
                     else {
                         NSLog(@"GPSデータがありません");
                         self.imageCoordinate = CLLocationCoordinate2DMake(0, 0);
                         [self performSegueWithIdentifier:@"showAdd" sender:image];
                         
                     }
                 }else{
                     NSLog(@"データがありません");
                     self.imageCoordinate = CLLocationCoordinate2DMake(0, 0);
                     [self performSegueWithIdentifier:@"showAdd" sender:image];
                 }
                 
             } failureBlock: nil];
}

- (void)gotoAddViewWithCoordinate:(CLLocationCoordinate2D)coordinate image:(UIImage *)image {
    self.imageCoordinate = coordinate;
    [self performSegueWithIdentifier:@"showAdd" sender:image];
}


- (void)refershControlAction {
    NSLog(@"refresh!");
    [self reloadData];
}


- (IBAction)typeChanged:(UISegmentedControl *)control {
    NSString *btnName;
    if (control.selectedSegmentIndex == 0) {
        [self showTypeChanged:YES];
        btnName = @"list";
    }
    else {
        [self showTypeChanged:NO];
        btnName = @"map";
    }
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ACTION"
                                                         action:@"touch"
                                                          label:btnName
                                                           value:nil] build]];
}


- (void)showTypeChanged:(BOOL)isList {
    if (isList) {
        // リスト形式に
        _collectionView.hidden = NO;
        _mapView.hidden = YES;
    }
    else {
        // マップ形式に
        _collectionView.hidden = YES;
        _mapView.hidden = NO;
    }
}



#pragma mark -
#pragma mark Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showAdd"]) {
        ATDAddViewController *addVC = segue.destinationViewController;
        addVC.image = sender;
        addVC.coordinate = _imageCoordinate;
    }
    else if ([segue.identifier isEqualToString:@"showAddFromSite"]) {
        NSDictionary *params = (NSDictionary *)sender;
        
        ATDAddViewController *addVC = segue.destinationViewController;
        addVC.isRegistFromSite = YES;   // このフラグをたてる
        addVC.defaultMemoStr = params[@"title"];
        addVC.imageUrl = params[@"imageUrl"];
        
        CLLocation *location = params[@"location"];
        addVC.coordinate = location.coordinate;
    }
    else if ([segue.identifier isEqualToString:@"showDetail"]) {
        ATDDetailViewController *detailVC = segue.destinationViewController;
        detailVC.memo = sender;
    }
}


#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        NSURL *assetURL = (NSURL *)info[UIImagePickerControllerReferenceURL];
        [self gotoAddViewWithAsset:assetURL image:image];
    }
    else if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *originImage = info[UIImagePickerControllerOriginalImage];
        
        NSMutableDictionary *metadata = (NSMutableDictionary *)[info objectForKey:UIImagePickerControllerMediaMetadata];
        if (_locationManager.location.coordinate.latitude != 0
            && _locationManager.location.coordinate.longitude != 0) {
            metadata[(NSString *)kCGImagePropertyGPSDictionary] = [self GPSDictionaryForLocation:self.locationManager.location];
        }
        
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary writeImageToSavedPhotosAlbum:originImage.CGImage metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                NSLog(@"Save image failed. %@", error);
            }
            else {
                [self gotoAddViewWithCoordinate:self.locationManager.location.coordinate image:image];
            }
        }];
    }

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage*)rotateImage:(UIImage*)img angle:(int)angle
{
    CGImageRef      imgRef = [img CGImage];
    CGContextRef    context;
    
    switch (angle) {
        case 90:
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(img.size.height, img.size.width), YES, img.scale);
            context = UIGraphicsGetCurrentContext();
            CGContextTranslateCTM(context, img.size.height, img.size.width);
            CGContextScaleCTM(context, 1, -1);
            CGContextRotateCTM(context, M_PI_2);
            break;
        case 180:
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(img.size.width, img.size.height), YES, img.scale);
            context = UIGraphicsGetCurrentContext();
            CGContextTranslateCTM(context, img.size.width, 0);
            CGContextScaleCTM(context, 1, -1);
            CGContextRotateCTM(context, -M_PI);
            break;
        case 270:
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(img.size.height, img.size.width), YES, img.scale);
            context = UIGraphicsGetCurrentContext();
            CGContextScaleCTM(context, 1, -1);
            CGContextRotateCTM(context, -M_PI_2);
            break;
        default:
            return img;
            break;
    }
    
    CGContextDrawImage(context, CGRectMake(0, 0, img.size.width, img.size.height), imgRef);
    UIImage*    result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}


- (NSString *)stringFromGpsDate:(NSDate *)date {
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy:MM:dd";
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    }
    
    return [dateFormatter stringFromDate:date];
}

- (NSString *)stringFromGpsTime:(NSDate *)date {
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"HH:mm:ss.SSSSSS";
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    }
    
    return [dateFormatter stringFromDate:date];
}



- (NSDictionary *)GPSDictionaryForLocation:(CLLocation *)location
{
    NSMutableDictionary *gps = [NSMutableDictionary new];
    
    // 日付
    gps[(NSString *)kCGImagePropertyGPSDateStamp] = [self stringFromGpsDate:location.timestamp];
    gps[(NSString *)kCGImagePropertyGPSTimeStamp] = [self stringFromGpsTime:location.timestamp];
    
    // 緯度
    CGFloat latitude = location.coordinate.latitude;
    NSString *gpsLatitudeRef;
    if (latitude < 0) {
        latitude = -latitude;
        gpsLatitudeRef = @"S";
        } else {
            gpsLatitudeRef = @"N";
            }
    gps[(NSString *)kCGImagePropertyGPSLatitudeRef] = gpsLatitudeRef;
    gps[(NSString *)kCGImagePropertyGPSLatitude] = @(latitude);
    
    // 経度
    CGFloat longitude = location.coordinate.longitude;
    NSString *gpsLongitudeRef;
    if (longitude < 0) {
        longitude = -longitude;
            gpsLongitudeRef = @"W";
        } else {
            gpsLongitudeRef = @"E";
        }
    gps[(NSString *)kCGImagePropertyGPSLongitudeRef] = gpsLongitudeRef;
    gps[(NSString *)kCGImagePropertyGPSLongitude] = @(longitude);
    
    // 標高
    CGFloat altitude = location.altitude;
    if (!isnan(altitude)){
        NSString *gpsAltitudeRef;
        if (altitude < 0) {
            altitude = -altitude;
            gpsAltitudeRef = @"1";
        } else {
            gpsAltitudeRef = @"0";
        }
        gps[(NSString *)kCGImagePropertyGPSAltitudeRef] = gpsAltitudeRef;
        gps[(NSString *)kCGImagePropertyGPSAltitude] = @(altitude);
    }
    
    return gps;
}


#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (!_isLocationLoading) {
        _isLocationLoading = YES;
        self.currentLocation = [locations lastObject];
        
        NSLog(@"location update");
        [self setUpMapViews];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"locationManager_error[%@]", error);
    
    if (_currentLocation) {
        [self setUpMapViews];
    }
    else {
        [self setUpMapErrorViews];
    }
}


#pragma mark -
#pragma mark UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_memos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ATDPlaceMemoCell *cell = [collectionView
                                  dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ATDPlaceMemoCell class])
                                  forIndexPath:indexPath];
    PlaceMemo *memo = _memos[indexPath.row];
    
    cell.nameLabel.text = memo.title;
    [cell.imageView setImageWithURL:[NSURL fileURLWithPath:memo.imageFilePath]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PlaceMemo *memo = _memos[indexPath.row];
    [self performSegueWithIdentifier:@"showDetail" sender:memo];
}


#pragma mark -
#pragma mark MapView

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    // add detail disclosure button to callout
    [views enumerateObjectsUsingBlock:^(MKAnnotationView *obj, NSUInteger idx, BOOL* stop) {
        if ([obj.annotation isKindOfClass:[MKUserLocation class]]) {
            // do nothing
        }
        else {
            obj.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
    }];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    ATDAnnotation *annotation = (ATDAnnotation *)view.annotation;
    PlaceMemo *selectedMemo = annotation.memo;
    
    [self performSegueWithIdentifier:@"showDetail" sender:selectedMemo];
}

- (void)showTutorialView {
    ATDTutorialView *view = [ATDTutorialView view];
    view.center = self.view.center;
    view.isFirstTutorial = YES;
    [view show];
}

@end
