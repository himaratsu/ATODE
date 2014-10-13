//
//  ActionViewController.m
//  AddByUrl
//
//  Created by 平松　亮介 on 2014/10/13.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ActionViewController.h"
#import "ATODEFramework.h"
#import "ATDPlaceholderTextView.h"
#import "ATDTabelogSearcher.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface ActionViewController ()

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIView *titleFrameView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet ATDPlaceholderTextView *titleTextView;
@property (weak, nonatomic) IBOutlet UIButton *addPlaceButton;
@property (weak, nonatomic) IBOutlet UILabel *latlngLabel;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;


@property (nonatomic, strong) ATDTabelogSearcher *searcher;


@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _titleTextView.placeholder = @"メモを追加（オプション）";
    
    [self setAppearance];
    
    [self setUpViews];
    

    NSExtensionItem *urlItem = [self.extensionContext.inputItems firstObject];
    NSItemProvider *urlItemProvider = [[urlItem attachments] firstObject];
    
    if ([urlItemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
        [urlItemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL
                                           options:nil
                                 completionHandler:^(NSURL *item, NSError *error) {
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         if (error) {
                                             _statusLabel.text = [NSString stringWithFormat:@"エラー %@", error];
                                         }
                                         else {
                                             _statusLabel.text = item.absoluteString;
                                         }
                                         [_statusLabel sizeToFit];
                                         
                                         [self searchTabelogInfoFromUrl:item.absoluteString];
                                     });
                                 }];
    }
    else {
        _statusLabel.text = @"形式が異なります";
    }

    
}

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

    _addPlaceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _addPlaceButton.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);

    _addPlaceButton.layer.cornerRadius = 3.0f;
    _addPlaceButton.layer.masksToBounds = YES;

    _doneButton.layer.cornerRadius = 3.0f;
    _doneButton.layer.masksToBounds = YES;

    _cancelButton.layer.cornerRadius = 3.0f;
    _cancelButton.layer.masksToBounds = YES;
}


- (void)searchTabelogInfoFromUrl:(NSString *)url {
    self.searcher = [ATDTabelogSearcher new];
    [_searcher searchInfoWithTabelogUrl:url
                                handler:^(NSString *title, CLLocation *location, NSString *imageUrl, NSString *errorMsg) {
                                    if (errorMsg) {
                                        _statusLabel.text = [NSString stringWithFormat:@"エラー %@", errorMsg];
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
                                    
                                    CLLocationCoordinate2D coordinate = location.coordinate;
                                    _latlngLabel.text = [NSString stringWithFormat:@"%f, %f", coordinate.latitude, coordinate.longitude];
                                    
                                }];
}

- (IBAction)doneBtnTouched:(id)sender {
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

- (IBAction)cancelBtnTouched:(id)sender {
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

@end



//
//#import "ActionViewController.h"
//#import <MobileCoreServices/MobileCoreServices.h>
//#import <SDWebImage/UIImageView+WebCache.h>
//#import "ATODEFramework.h"
//#import "ATDPlaceholderTextView.h"
//#import "ATD4sqPlace.h"
//#import "ATDTabelogSearcher.h"
//
//@interface ActionViewController ()
//
//@property (weak, nonatomic) IBOutlet UIImageView *imageView;
//@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
//@property (weak, nonatomic) IBOutlet ATDPlaceholderTextView *titleTextView;
//@property (nonatomic, strong) ATD4sqPlace *placeInfo;
//@property (weak, nonatomic) IBOutlet UIButton *placeAddButton;
//
//@property (weak, nonatomic) IBOutlet UIView *titleFrameView;
//@property (weak, nonatomic) IBOutlet UIButton *doneButton;
//@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
//
//@property (weak, nonatomic) IBOutlet UILabel *latlngLabel;
//
//@end
//
//
//@interface ActionViewController ()
//
//@property (nonatomic, strong) ATDTabelogSearcher *searcher;
//
//@end
//
//
//
//@implementation ActionViewController
//
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    [self setAppearance];
//    
//    [self setUpViews];
//    
//    _titleTextView.placeholder = @"メモを追加（オプション）";
//    
//    // Get the item[s] we're handling from the extension context.
//}
//
//
//
//- (IBAction)doneBtnTouched:(id)sender {
//    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
//}
//
//- (IBAction)cancelBtnTouched:(id)sender {
//    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
//}


//@end
