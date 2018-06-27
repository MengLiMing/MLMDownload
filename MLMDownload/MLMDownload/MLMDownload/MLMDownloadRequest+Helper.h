//
//  MLMDownloadRequest+Helper.h
//  Live
//
//  Created by MAC on 2018/5/5.
//  Copyright © 2018年 Zego. All rights reserved.
//

#import "MLMDownloadRequest.h"

@interface MLMDownloadRequest (Helper)

/**
 获取Documents
 */
+ (NSString *)documents;

/**
 获取temp
 */
+ (NSString *)temp;

/**
 获取library
 */
+ (NSString *)library;

/**
 获取Library/Caches
 */
+ (NSString *)libraryCache;

/**
 创建目录
 */
+ (BOOL)createDirectory:(NSString *)path;

/**
 创建文件
 */
+ (BOOL)createPath:(NSString *)path;

/**
 删除文件
 */
+ (BOOL)deletePath:(NSString *)path;


/**
 md5
 */
+ (NSString *)md5String:(NSString *)input;

@end
