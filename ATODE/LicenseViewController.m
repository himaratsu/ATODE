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

@property (nonatomic, strong) UIWebView *webView;

@end



@implementation LicenseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.delegate = self;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"license" ofType:@"html"];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]];
    [_webView loadRequest:req];
}




@end
