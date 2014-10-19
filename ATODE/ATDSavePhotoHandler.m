//
//  ATDSavePhotoHandler.m
//  ATODE
//
//  Created by himara2 on 2014/09/06.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDSavePhotoHandler.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation ATDSavePhotoHandler


- (NSString *)todayStr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddhhmmss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    return dateStr;
}

- (NSString *)saveImageWithImage:(UIImage *)image {
    NSString *hashStr = [self hashFromImage:image];
    hashStr = [NSString stringWithFormat:@"%@%@", hashStr, [self todayStr]];
    
    // Save to sharedContainer
    NSURL *fileURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.gomemo"];
    NSString *documentsDirPath = fileURL.absoluteString;
    NSString *filePath = [documentsDirPath stringByAppendingFormat:@"%@", hashStr];
    filePath = [filePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    NSLog(@"filePath is %@", filePath);
    
//    NSDictionary* dict = @{ @"place":@"Tokyo", @"tel":@"03-1234-5678"};
//    [dict writeToURL:fileURL atomically:YES];
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *DocumentsDirPath = [paths objectAtIndex:0];
//    NSString *filePath = [DocumentsDirPath stringByAppendingFormat:@"/%@", hashStr];
    
    // Save image.
    if (![UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES]) {
        NSLog(@"save file error!");
        return nil;
    }
    
    // TODO: SDWebImageでキャッシュ
    // TODO: 保存失敗した時の処理
    
    return filePath;
}

- (NSString *)hashFromImage:(UIImage *)image {
    unsigned char   result[16];
    NSData*         data;
    data = UIImagePNGRepresentation(image);
    CC_MD5([data bytes], [data length], result);
    
    NSString* hashStr =  [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                          result[0], result[1],
                          result[2], result[3],
                          result[4], result[5],
                          result[6], result[7],
                          result[8], result[9],
                          result[10], result[11],
                          result[12], result[13],
                          result[14], result[15]];
    
    return hashStr;
    
}


@end
