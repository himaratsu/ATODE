//
//  ATDTabelogSearcher.m
//  ATODE
//
//  Created by 平松　亮介 on 2014/08/13.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDTabelogSearcher.h"

@implementation ATDTabelogSearcher

- (void)searchInfoWithTabelogUrl:(NSString *)tabelogUrl handler:(ATDTabelogSearchHandler)handler {
    _isFinishSearch = NO;
    self.handler = handler;
    
    if (!_webView) {
        self.webView = [[UIWebView alloc] init];
        _webView.delegate = self;
    }
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:tabelogUrl]];
    [_webView loadRequest:req];
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // 検索リクエストをもう投げた後なら以降は無視する
    // （複数リクエスト飛ぶ問題対策）
    if (_isFinishSearch) {
        return;
    }
    
    NSString *host = webView.request.URL.host;
    
    if ([host isEqualToString:@"tabelog.com"]
        || [host isEqualToString:@"s.tabelog.com"]) {
        
        // 食べログサイトから情報を抽出
        NSString *shopTitle = [self searchShopTitleForTabelog];
        NSString *address = [self searchAddressForTabelog];
        NSString *imageUrl = [self searchImageUrlForTablelog];
        
        if (shopTitle == nil || [shopTitle isEqualToString:@""]
            || address == nil || [address isEqualToString:@""]
            || imageUrl == nil || [imageUrl isEqualToString:@""]) {
            self.handler(nil, nil, nil, @"該当するお店を見つけられませんでした。URLが正しいかを確認してください");
            return;
        }
        
        // ジオコーディング
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                self.handler(nil, nil, nil, @"住所取得中にエラーが発生しました。時間をおいて再度お試しください");
                return;
            }
            else {
                if (placemarks > 0) {
                    CLPlacemark *p = placemarks[0]; // 0番目を使用
                    CLLocation *location = p.location;
                    self.handler(shopTitle, location, imageUrl, nil);
                }
                else {
                    self.handler(nil, nil, nil, @"住所を分析できませんでした");
                    NSLog(@"住所をジオコーディングできませんでした");
                }
            }
        }];
        
        _isFinishSearch = YES;
    }
    else {
        self.handler(nil, nil, nil, @"店情報の検索に失敗しました。食べログのURLを確認してください");
        return;
    }
}


- (NSString *)searchShopTitleForTabelog {
    NSString *jsStr = @"document.getElementsByClassName('rst-name')[0].innerHTML";
    return [_webView stringByEvaluatingJavaScriptFromString:jsStr];
}

- (NSString *)searchAddressForTabelog {
    NSString *jsStr = @"document.getElementsByClassName('add data')[0].innerText";
    return [_webView stringByEvaluatingJavaScriptFromString:jsStr];
}

- (NSString *)searchImageUrlForTablelog {
    NSString *jsStr = @"document.getElementById('mainphoto-view').getElementsByTagName('li')[0].getElementsByClassName('mainphoto-image')[0].getAttribute('src')";
    return [_webView stringByEvaluatingJavaScriptFromString:jsStr];
}



@end
