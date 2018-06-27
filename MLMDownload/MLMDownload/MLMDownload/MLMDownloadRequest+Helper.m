//
//  MLMDownloadRequest+Helper.m
//  Live
//
//  Created by MAC on 2018/5/5.
//  Copyright © 2018年 Zego. All rights reserved.
//

#import "MLMDownloadRequest+Helper.h"
#import <CommonCrypto/CommonDigest.h>

@implementation MLMDownloadRequest (Helper)

#pragma mark - 获取Documents
+ (NSString *)documents {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

#pragma mark - 获取temp
+ (NSString *)temp {
    return NSTemporaryDirectory();
}

#pragma mark - 获取library
+ (NSString *)library {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

#pragma mark - 获取Library/Caches
+ (NSString *)libraryCache {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

#pragma mark - 创建目录
+ (BOOL)createDirectory:(NSString *)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }
    
    return [[NSFileManager defaultManager] createDirectoryAtPath:path
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:NULL];
}

#pragma mark - 创建文件
+ (BOOL)createPath:(NSString *)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }
    return [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
}

#pragma mark - 删除文件
+ (BOOL)deletePath:(NSString *)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        if (error) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - md5
+ (NSString *)md5String:(NSString *)input {
    const char* cStr = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    return digest;
}

@end
