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
- (void)deleteMemo:(PlaceMemo *)memo;

- (NSArray *)getAllMemos;
- (PlaceMemo *)updateMemo:(PlaceMemo *)memo title:(NSString *)title;
- (PlaceMemo *)updateMemo:(PlaceMemo *)memo imageFilePath:(NSString *)imageFilePath;
- (void)resetSaveData;


@end
