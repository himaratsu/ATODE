//
//  NSPersistentStore+MagicalRecord.m
//
//  Created by Saul Mora on 3/11/10.
//  Copyright 2010 Magical Panda Software, LLC All rights reserved.
//

//#import "NSPersistentStore+MagicalRecord.h"
#import "CoreData+MagicalRecord.h"

NSString * const kMagicalRecordDefaultStoreFileName = @"CoreDataStore.sqlite";

static NSPersistentStore *defaultPersistentStore_ = nil;


@implementation NSPersistentStore (MagicalRecord)

+ (NSPersistentStore *) MR_defaultPersistentStore
{
	return defaultPersistentStore_;
}

+ (void) MR_setDefaultPersistentStore:(NSPersistentStore *) store
{
	defaultPersistentStore_ = store;
}

+ (NSString *) MR_directory:(int) type
{    
    return [NSSearchPathForDirectoriesInDomains(type, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)MR_applicationDocumentsDirectory 
{
	return [self MR_directory:NSDocumentDirectory];
}

+ (NSString *)MR_applicationStorageDirectory
{
    NSString *applicationName = @"ATODE";
    return [[self MR_directory:NSApplicationSupportDirectory] stringByAppendingPathComponent:applicationName];
}

// himara2 editted
// for app groups
+ (NSString *)MR_applicationAppGroupsStorageDirectory
{
    NSString *applicationName = @"ATODE";
    
    NSURL *storeURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.gomemo"];
    NSString *storeAbsoluteUrl = [[storeURL absoluteString] stringByReplacingOccurrencesOfString:@"file:" withString:@""];
    storeAbsoluteUrl = [storeAbsoluteUrl stringByAppendingPathComponent:@"ATODE"];
    
    NSLog(@"current path [%@]", [[self MR_directory:NSApplicationSupportDirectory] stringByAppendingPathComponent:applicationName]);
    NSLog(@"app groups path [%@]", storeAbsoluteUrl);
    
    return storeAbsoluteUrl;
}

// default storage
+ (NSURL *) MR_urlForStoreName:(NSString *)storeFileName
{
	NSArray *paths = [NSArray arrayWithObjects:[self MR_applicationDocumentsDirectory], [self MR_applicationStorageDirectory], nil];
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    for (NSString *path in paths) 
    {
        NSString *filepath = [path stringByAppendingPathComponent:storeFileName];
        if ([fm fileExistsAtPath:filepath])
        {
            return [NSURL fileURLWithPath:filepath];
        }
    }

    return [NSURL fileURLWithPath:[[self MR_applicationStorageDirectory] stringByAppendingPathComponent:storeFileName]];
}

// himara2 editted.
// App Groups
+ (NSURL *) MR_urlForAppGroupsStoreName:(NSString *)storeFileName
{
    NSArray *paths = [NSArray arrayWithObjects:[self MR_applicationAppGroupsStorageDirectory], nil];
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    for (NSString *path in paths)
    {
        NSString *filepath = [path stringByAppendingPathComponent:storeFileName];
        if ([fm fileExistsAtPath:filepath])
        {
            return [NSURL fileURLWithPath:filepath];
        }
    }
    
    return [NSURL fileURLWithPath:[[self MR_applicationAppGroupsStorageDirectory] stringByAppendingPathComponent:storeFileName]];
}

+ (NSURL *) MR_cloudURLForUbiqutiousContainer:(NSString *)bucketName;
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *cloudURL = nil;
    if ([fileManager respondsToSelector:@selector(URLForUbiquityContainerIdentifier:)])
    {
        cloudURL = [fileManager URLForUbiquityContainerIdentifier:bucketName];
    }

    return cloudURL;
}

+ (NSURL *) MR_defaultLocalStoreUrl
{
    return [self MR_urlForStoreName:kMagicalRecordDefaultStoreFileName];
}

@end
