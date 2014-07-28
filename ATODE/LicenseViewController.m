//
//  LicenseViewController.m
//  ATODE
//
//  Created by 平松　亮介 on 2014/07/18.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "LicenseViewController.h"

@interface LicenseViewController ()
<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end


@implementation LicenseViewController

+ (instancetype)view {
    LicenseViewController *vc = [[LicenseViewController alloc] initWithNibName:@"LicenseViewController"
                                                                        bundle:nil];
    return vc;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"ライセンス";
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"license" ofType:@"html"];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]];
    [_webView loadRequest:req];
}




@end
