//
//  ATDPlaceMemo.h
//  ATODE
//
//  Created by himara2 on 2014/07/05.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATDPlaceMemo : NSObject

@property (nonatomic, strong) NSString *title;              // タイトル
@property (nonatomic, strong) NSString *imageFilePath;      // 画像ファイルパス
@property (nonatomic, strong) NSString *postdate;           // 投稿日時
@property (nonatomic, strong) NSString *siteUrl;            // サイトURL（option）

@end
