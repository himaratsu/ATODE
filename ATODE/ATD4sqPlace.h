//
//  ATD4sqPlace.h
//  ATODE
//
//  Created by himara2 on 2014/07/12.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATD4sqPlace : NSObject <NSCoding>

@property (nonatomic, strong) NSString *venueId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSArray  *photoUrls;

@property (nonatomic, strong) NSString *shortUrl;   // 4sq page


- (id)initWithDictionary:(NSDictionary *)dict;

+ (instancetype)dummy;

@end
