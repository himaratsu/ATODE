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

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.name = [aDecoder decodeObjectForKey:@"NAME"];
        self.address = [aDecoder decodeObjectForKey:@"ADDRESS"];
        self.url = [aDecoder decodeObjectForKey:@"URL"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"NAME"];
    [aCoder encodeObject:_address forKey:@"ADDRESS"];
    [aCoder encodeObject:_url forKey:@"URL"];
}


+ (instancetype)dummy {
    ATD4sqPlace *place = [[ATD4sqPlace alloc] init];
    place.name = @"Demo";
    place.address = @"Tokyo";
    place.url = @"http://yahoo.co.jp";
    
    return place;
}

@end
