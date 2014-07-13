//
//  ATDPlaceMemo.h
//  ATODE
//
//  Created by himara2 on 2014/07/05.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATD4sqPlace.h"
#import "PlaceMemo.h"
#import <CoreLocation/CoreLocation.h>

@interface ATDPlaceMemo : NSObject

@property (nonatomic, strong) NSString *title;              // タイトル
@property (nonatomic, strong) NSString *imageFilePath;      // 画像ファイルパス
@property (nonatomic, strong) NSString *postdate;           // 投稿日時
@property (nonatomic, strong) NSString *siteUrl;            // サイトURL（option）
@property (nonatomic, assign) double latitude;             // 写真撮影スポットのlat
@property (nonatomic, assign) double longitude;            // 写真撮影スポットのlong
@property (nonatomic, strong) ATD4sqPlace *placeInfo;       // スポットの情報（from 4sq）

- (id)initWithPlaceMemo:(PlaceMemo *)memo;


@end
