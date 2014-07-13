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
#import "PlaceMemo.h"
#import <CoreLocation/CoreLocation.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <FontAwesome-iOS/NSString+FontAwesome.h>


@interface ATDViewController ()
<UICollectionViewDataSource, UICollectionViewDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate,
CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray *memos;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, assign) BOOL isLocationLoading;

@end



@implementation ATDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self startUpdateLocation];

    [self registerNib];
    
    [self setUpViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [self reloadData];
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
}

- (void)reloadData {
    NSArray *memos = [[ATDCoreDataManger sharedInstance] getAllMemos];
    self.memos = [self sortMemoByDistance:memos];
    
    [_collectionView reloadData];
    
    [_refreshControl endRefreshing];
}


- (NSArray *)sortMemoByDistance:(NSArray *)memos {
    if (!_currentLocation) {
        NSLog(@"no lcoation");
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
        
        NSLog(@"distance [%f] < [%f]", distance1, distance2);
        
        return distance1 < distance2;
    }];
    
    return sorterdMemos;
}

// 写真撮影画面へ遷移
- (void)showImagePickerView {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark -
#pragma mark IBAction

- (IBAction)addBtnTouched:(id)sender {
#if (TARGET_IPHONE_SIMULATOR)
    // シミュレータで動作中
    UIImage *image = [UIImage imageNamed:@"sample.jpg"];
    [self performSegueWithIdentifier:@"showAdd" sender:image];
#else
    // 実機で動作中
    [self showImagePickerView];
#endif
}


- (void)refershControlAction {
    NSLog(@"refresh!");
    _isLocationLoading = YES;
    [self reloadData];
}



#pragma mark -
#pragma mark Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showAdd"]) {
        ATDAddViewController *addVC = segue.destinationViewController;
        addVC.image = sender;
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
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    [self performSegueWithIdentifier:@"showAdd" sender:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (!_isLocationLoading) {
        _isLocationLoading = YES;
        self.currentLocation = [locations lastObject];
        [self reloadData];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"locationManager_error[%@]", error);
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
    
    NSLog(@"%@, %@", memo.latitude, memo.longitude);
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"select! [%d-%d]", indexPath.section, indexPath.row);
    
    PlaceMemo *memo = _memos[indexPath.row];
    [self performSegueWithIdentifier:@"showDetail" sender:memo];
    
}

@end
