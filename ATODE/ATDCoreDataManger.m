//
//  ATDCoreDataManger.m
//  ATODE
//
//  Created by himara2 on 2014/07/05.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDCoreDataManger.h"
#import <MagicalRecord/MagicalRecord.h>
#import <MagicalRecord/CoreData+MagicalRecord.h>

#import "PlaceMemo.h"


@implementation ATDCoreDataManger
{
    NSManagedObjectContext *_magicalContext;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)saveNewMemo:(ATDPlaceMemo *)memo {
    [self setUpStack];
    
    PlaceMemo *addMemo = [PlaceMemo MR_createEntity];
    addMemo.title = memo.title;
    addMemo.imageFilePath = memo.imageFilePath;
    addMemo.postdate = memo.postdate;
    addMemo.siteUrl = memo.siteUrl;
    addMemo.placeInfo = memo.placeInfo;
    
    [_magicalContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        NSLog(@"write to CoreData :success[%d]", success);
    }];
    
    // check
    [self printCoreData];
}

- (NSArray *)getAllMemos {
    [self setUpStack];
    return [PlaceMemo MR_findAll];
}

- (void)printCoreData {
    NSLog(@"メモが %d件 あります", [[PlaceMemo MR_findAll] count]);
}


- (void)resetSaveData {
    NSURL *URL = [NSPersistentStore MR_urlForStoreName:[MagicalRecord defaultStoreName]];
    [[NSFileManager defaultManager] removeItemAtURL:URL error:nil];
}



- (void)setUpStack {
    [MagicalRecord setupCoreDataStack];
    _magicalContext = [NSManagedObjectContext MR_contextForCurrentThread];
}



@end
