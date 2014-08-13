//
//  ATDTabelogSearcher.m
//  ATODE
//
//  Created by 平松　亮介 on 2014/08/13.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDTabelogSearcher.h"

@implementation ATDTabelogSearcher

- (void)searchInfoWithTabelogUrl:(NSString *)tabelogUrl {
    NSLog(@"tabelogUrl[%@]", tabelogUrl);
    
    if (!_webView) {
        self.webView = [[UIWebView alloc] init];
        _webView.delegate = self;
    }
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:tabelogUrl]];
    [_webView loadRequest:req];
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSLog(@"title [%@]", title);
    
    NSString *host = webView.request.URL.host;
    
    if ([host isEqualToString:@"tabelog.com"]
        || [host isEqualToString:@"s.tabelog.com"]) {
        // エラーハンドリング
        if ([webView.request.URL.absoluteString isEqualToString:@"http://s.tabelog.com/2800145/"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"食べログ エラー"
                                                            message:@"該当するお店を見つけられませんでした。URLが正しいかを確認してください"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
            return;
        }
        
        // 食べログなら
        NSString *address = [self searchAddressForTabelog];
        NSLog(@"address [%@]", address);
        
        NSString *imageUrl = [self searchImageUrlForTablelog];
        NSLog(@"imageUrl [%@]", imageUrl);
        
        // 画像URL
        // document.getElementsByClassName('post-photos')[0].getElementsByTagName('li')[0].getElementsByTagName('img')[0].getAttribute('src')
    }
    else {
        // どちらでもないなら
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                        message:@"検索に失敗しました。食べログのURLを確認してください"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
}



- (NSString *)searchAddressForTabelog {
    // PCサイト
    //    NSString *jsStr = @"document.getElementsByClassName('address')[0].getElementsByTagName('p')[0].innerText";
    
    // スマホサイト（食べログ）
    NSString *jsStr = @"document.getElementsByClassName('add data')[0].innerText";
    return [_webView stringByEvaluatingJavaScriptFromString:jsStr];
}

- (NSString *)searchImageUrlForTablelog {
    NSString *jsStr = @"document.getElementsByClassName('post-photos')[0].getElementsByTagName('li')[0].getElementsByTagName('img')[0].getAttribute('src')";
    return [_webView stringByEvaluatingJavaScriptFromString:jsStr];
}



@end
