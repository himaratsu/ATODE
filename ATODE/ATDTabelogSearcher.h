//
//  ATDTabelogSearcher.h
//  ATODE
//
//  Created by 平松　亮介 on 2014/08/13.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^ATDTabelogSearchHandler)(NSString *title, CLLocation *location, NSString *imageUrl, NSString *errorMsg);


@interface ATDTabelogSearcher : NSObject
<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString *tabelogUrl;
@property (nonatomic, assign) BOOL isFinishSearch;
@property (nonatomic, copy) ATDTabelogSearchHandler handler;

- (void)searchInfoWithTabelogUrl:(NSString *)tabelogUrl
                         handler:(ATDTabelogSearchHandler)handler;

@end
