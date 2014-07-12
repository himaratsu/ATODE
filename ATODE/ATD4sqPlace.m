//
//  ATD4sqPlace.m
//  ATODE
//
//  Created by himara2 on 2014/07/12.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATD4sqPlace.h"

@implementation ATD4sqPlace

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.name = dict[@"name"];
        self.address = dict[@"location"][@"address"];
        self.url = dict[@"url"];
    }
    return self;
}

@end
