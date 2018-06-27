//
//  MLMDownloadRequest.h
//  Live
//
//  Created by MAC on 2018/4/29.
//  Copyright © 2018年 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MLMDownloadState) {
    MLMDownloadNone,//未开始下载
    MLMDownloadStart,//下载中
    MLMDownloadSuspended,//等待下载,暂停
    MLMDownloadCompleted,//下载完成
    MLMDownloadFailed//下载失败
};

@class MLMDownloadRequest;
@protocol MLMDownloadRequestDelegate <NSObject>

@optional
//状态变化
- (void)stateChangeWithRequest:(MLMDownloadRequest *)request;
//进度变化
- (void)progressChangeWithRequest:(MLMDownloadRequest *)request withProgress:(CGFloat)progress;

@end

@interface MLMDownloadRequest : NSObject

//代理
@property (nonatomic, weak) id<MLMDownloadRequestDelegate> delegate;

/** 下载的链接 */
@property (nonatomic, strong) NSString *url;
/** 当前下载文件存放的文件夹 */
@property (nonatomic, strong) NSString *fileFolder;
/** 文件名字 */
@property (nonatomic, strong) NSString *fileName;

//开始下载
- (void)downLoad;
//暂停
- (void)suspend;
//恢复下载
- (void)resume;
//停止下载
- (void)stop;
//删除文件
- (void)deleteFile;
//判断文件是否下载完成
- (BOOL)isCompletion;

/** 总文件路径 */
@property (nonatomic, strong, readonly) NSString *filePath;
/** 文件的总长度 */
@property (nonatomic, assign, readonly) long long allLength;
/** 当前下载长度 */
@property (nonatomic, assign, readonly) long long currentLength;
/** 下载进度 */
@property (nonatomic, assign, readonly) CGFloat progress;
/** 状态 */
@property (nonatomic, assign, readonly) MLMDownloadState state;

@end
