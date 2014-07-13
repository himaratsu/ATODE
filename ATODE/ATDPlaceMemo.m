//
//  ATDPlaceMemo.m
//  ATODE
//
//  Created by himara2 on 2014/07/05.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDPlaceMemo.h"

@implementation ATDPlaceMemo

- (id)initWithPlaceMemo:(PlaceMemo *)memo {
    self = [super init];
    if (self) {
        self.title = memo.title;
        self.imageFilePath = memo.imageFilePath;
        self.postdate = memo.postdate;
        self.siteUrl = memo.siteUrl;
        self.latitude = [memo.latitude doubleValue];
        self.longitude = [memo.longitude doubleValue];
        self.placeInfo = memo.placeInfo;
    }
    return self;
}

@end
