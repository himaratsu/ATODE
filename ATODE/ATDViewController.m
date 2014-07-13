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
#import <SDWebImage/UIImageView+WebCache.h>
#import <FontAwesome-iOS/NSString+FontAwesome.h>


@interface ATDViewController ()
<UICollectionViewDataSource, UICollectionViewDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray *memos;

@end



@implementation ATDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self registerNib];
    
    [self setUpViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [self reloadData];
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
    [self.collectionView addSubview:_refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
}

- (void)reloadData {
    self.memos = [[ATDCoreDataManger sharedInstance] getAllMemos];
    [_collectionView reloadData];
    
    [_refreshControl endRefreshing];
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
    [self performSegueWithIdentifier:@"showAdd" sender:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
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
//    cell.imageView.alpha = 0.0;
    [cell.imageView setImageWithURL:[NSURL fileURLWithPath:memo.imageFilePath]
                   placeholderImage:[UIImage imageNamed:@"noimage"]
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//                              [UIView animateWithDuration:0.3f animations:^{
//                                  cell.imageView.alpha = 1.0;
//                              }];
                          }];
    
    NSDictionary *placeInfo = memo.placeInfo;
    NSLog(@"placeInfo[%@]", placeInfo);
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"select! [%d-%d]", indexPath.section, indexPath.row);
    
    PlaceMemo *memo = _memos[indexPath.row];
    [self performSegueWithIdentifier:@"showDetail" sender:memo];
    
}

@end
