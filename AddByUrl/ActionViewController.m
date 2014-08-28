//
//  ActionViewController.m
//  AddByUrl
//
//  Created by 平松　亮介 on 2014/08/28.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ATODEFramework.h"
#import "ATDPlaceholderTextView.h"
#import "ATD4sqPlace.h"
#import "ATDTabelogSearcher.h"

@interface ActionViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet ATDPlaceholderTextView *titleTextView;
@property (nonatomic, strong) ATD4sqPlace *placeInfo;
@property (weak, nonatomic) IBOutlet UIButton *placeAddButton;

@property (weak, nonatomic) IBOutlet UIView *titleFrameView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *latlngLabel;

@end


@interface ActionViewController ()

@property (nonatomic, strong) ATDTabelogSearcher *searcher;

@end



@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
                                    
                                    CLLocationCoordinate2D coordinate = location.coordinate;
                                    _latlngLabel.text = [NSString stringWithFormat:@"%f, %f", coordinate.latitude, coordinate.longitude];
                                    
                                }];
}


- (IBAction)doneBtnTouched:(id)sender {
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

@end
