//
//  PlaceMemo.h
//  ATODE
//
//  Created by himara2 on 2014/07/13.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ATD4sqPlace.h"

@interface PlaceMemo : NSManagedObject

@property (nonatomic, retain) NSString * imageFilePath;
@property (nonatomic, retain) ATD4sqPlace *placeInfo;
@property (nonatomic, retain) NSString * postdate;
@property (nonatomic, retain) NSString * siteUrl;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;

@end
