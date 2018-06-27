//
//  RRKShortDownloadManager.h
//  Live
//
//  Created by MAC on 2018/4/29.
//  Copyright © 2018年 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLMDownloadRequest.h"

@interface MLMDownloadManager : NSObject

/** 最大下载个数 */
@property (nonatomic, assign) NSInteger maxCount;


/** 当前下载的队列 */
@property (nonatomic, strong) NSArray *downloadList;

//添加一个下载
- (void)addRequest:(MLMDownloadRequest *)request;
//暂停一个下载
- (void)suspendRequest:(MLMDownloadRequest *)request;
//恢复一个下载
- (void)resumeRequest:(MLMDownloadRequest *)request;
//停止一个下载
- (void)stopRequest:(MLMDownloadRequest *)request;
//删除一个下载
- (void)deleteRequest:(MLMDownloadRequest *)request;

@end
