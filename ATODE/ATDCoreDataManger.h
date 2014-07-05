//
//  ATDCoreDataManger.h
//  ATODE
//
//  Created by himara2 on 2014/07/05.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATDPlaceMemo.h"

@interface ATDCoreDataManger : NSObject

+ (instancetype)sharedInstance;

- (void)saveNewMemo:(ATDPlaceMemo *)memo;
- (NSArray *)getAllMemos;

@end
