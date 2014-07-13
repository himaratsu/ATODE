//
//  ATDAnnotation.m
//  ATODE
//
//  Created by himara2 on 2014/07/13.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDAnnotation.h"

@implementation ATDAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title subtitle:(NSString *)subtitle {
    if (self = [super init]) {
        self.coordinate = coordinate;
        self.title = title;
        self.subtitle = subtitle;
    }
    return self;
}

@end
