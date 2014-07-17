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
        self.venueId = dict[@"id"];
        self.name = dict[@"name"];
        self.address = dict[@"location"][@"address"];
        self.url = dict[@"url"];
        self.photoUrls = nil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.venueId = [aDecoder decodeObjectForKey:@"VENUE_ID"];
        self.name = [aDecoder decodeObjectForKey:@"NAME"];
        self.address = [aDecoder decodeObjectForKey:@"ADDRESS"];
        self.url = [aDecoder decodeObjectForKey:@"URL"];
        self.photoUrls = [aDecoder decodeObjectForKey:@"PHOTO_URLS"];
        self.shortUrl = [aDecoder decodeObjectForKey:@"SHORT_URL"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_venueId forKey:@"VENUE_ID"];
    [aCoder encodeObject:_name forKey:@"NAME"];
    [aCoder encodeObject:_address forKey:@"ADDRESS"];
    [aCoder encodeObject:_url forKey:@"URL"];
    [aCoder encodeObject:_photoUrls forKey:@"PHOTO_URLS"];
    [aCoder encodeObject:_shortUrl forKey:@"SHORT_URL"];
}


+ (instancetype)dummy {
    ATD4sqPlace *place = [[ATD4sqPlace alloc] init];
    place.name = @"Demo";
    place.address = @"Tokyo";
    place.url = @"http://yahoo.co.jp";
    
    return place;
}

@end
