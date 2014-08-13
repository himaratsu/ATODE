//
//  ATDTabelogSearcher.h
//  ATODE
//
//  Created by 平松　亮介 on 2014/08/13.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATDTabelogSearcher : NSObject
<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString *tabelogUrl;

- (void)searchInfoWithTabelogUrl:(NSString *)tabelogUrl;

@end
