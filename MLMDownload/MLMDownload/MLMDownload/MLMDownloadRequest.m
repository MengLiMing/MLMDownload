//
//  MLMDownloadRequest.m
//  Live
//
//  Created by MAC on 2018/4/29.
//  Copyright © 2018年 Zego. All rights reserved.
//

#import "MLMDownloadRequest.h"
#import "MLMDownloadRequest+Helper.h"

#define LENGTH_PAHT @"fileLenght"
#define MLMDOWNLOADFILE @"mlmDownloadFile"

@interface MLMDownloadRequest () <NSURLSessionDelegate>

/** 下载任务 */
@property (nonatomic, strong) NSURLSessionDataTask *downloadTask;
/** 状态 */
@property (nonatomic, assign) MLMDownloadState state;
/** 流 */
@property (nonatomic, strong) NSOutputStream *stream;
/** 文件的总长度 */
@property (nonatomic, assign) long long allLength;
/** 当前下载长度 */
@property (nonatomic, assign) long long currentLength;
/** 下载进度 */
@property (nonatomic, assign) CGFloat progress;

@end


@implementation MLMDownloadRequest

#pragma mark - 文件长度
- (long long)allLength {
    if (_allLength == 0 && self.fileName) {
        NSDictionary *lengthDic = [NSDictionary dictionaryWithContentsOfFile:[self lengthPath]];
        if (lengthDic) {
            NSNumber *length = [lengthDic valueForKey:self.fileName];
            if (length) {
                _allLength = [length longLongValue];
            }
        }
    }
    return _allLength;
}


- (void)saveAllLength:(long long)allLength {
    self.allLength = allLength;
    if (!self.fileName) {
        return;
    }
    NSMutableDictionary *lengthDic = [[NSMutableDictionary alloc] initWithContentsOfFile:[self lengthPath]];
    if (!lengthDic) {
        lengthDic = [NSMutableDictionary dictionary];
    }
    [lengthDic setValue:[NSNumber numberWithLongLong:allLength] forKey:self.fileName];
    [lengthDic writeToFile:[self lengthPath] atomically:YES];
}

/**
 当前文件的长度
 */
- (long long)currentLength {
    long long currentLength = 0;
    NSString *path = [self filePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            currentLength = [fileDict fileSize];
        }
    }
    return currentLength;
}

#pragma mark - 状态进度变化
- (void)progressChangeWithProgress:(CGFloat)progress {
    _progress = 1.0 * self.currentLength/self.allLength;
    if (self.delegate && [self.delegate respondsToSelector:@selector(progressChangeWithRequest:withProgress:)]) {
        [self.delegate progressChangeWithRequest:self withProgress:_progress];
    }
}

- (void)stateChangeWithState:(MLMDownloadState)state {
    _state = state;
    if (self.delegate && [self.delegate respondsToSelector:@selector(stateChangeWithRequest:)]) {
        [self.delegate stateChangeWithRequest:self];
    }
}


- (CGFloat)progress {
    if (_progress == 0 && self.allLength != 0) {
        _progress = self.currentLength/self.allLength;
    }
    return _progress;
}


#pragma mark - 目录文件创建
/**
 创建缓存目录
 */
- (void)createFileDirectory {
    [MLMDownloadRequest createDirectory:[self fileDirectory]];
}

//缓存文件夹路径
- (NSString *)fileDirectory {
    return [[MLMDownloadRequest libraryCache] stringByAppendingPathComponent:self.fileFolder];
}

- (NSString *)fileFolder {
    if (!_fileFolder) {
        _fileFolder = MLMDOWNLOADFILE;
    }
    return _fileFolder;
}

/**
 文件路径
 */
- (NSString *)filePath {
    return [[self fileDirectory] stringByAppendingPathComponent:self.fileName];
}

- (NSString *)fileName {
    if (!_fileName && self.url) {
        _fileName = [MLMDownloadRequest md5String:self.url];
    }
    return _fileName;
}

/**
 创建文件长度的plist
 */
- (void)createlengthFile {
    [MLMDownloadRequest createPath:[self lengthPath]];
}

/**
 存储文件总长度的路径
 */
- (NSString *)lengthPath {
    return [[self fileDirectory] stringByAppendingPathComponent:LENGTH_PAHT];
}


#pragma mark - 暂停
- (void)suspend {
    if (self.state != MLMDownloadSuspended) {
        [self.downloadTask suspend];
        [self stateChangeWithState:MLMDownloadSuspended];
    }
}

#pragma mark - 恢复下载
- (void)resume {
    if (self.state != MLMDownloadStart) {
        if (self.downloadTask) {
            [self.downloadTask resume];
            [self stateChangeWithState:MLMDownloadStart];
        } else {
            [self downLoad];
        }
    }
}


#pragma mark - 开始下载
- (void)downLoad {
    if (!self.url) {
        [self stateChangeWithState:MLMDownloadFailed];
        return;
    }
    
    if ([self isCompletion]) {
        [self stateChangeWithState:MLMDownloadCompleted];
        return;
    }
    
    //如果有就不创建
    if (self.downloadTask) {
        [self resume];
        return;
    }
    
    //创建缓存目录文件
    [self createFileDirectory];
    //创建文件长度的plist
//    [self createlengthFile];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    //文件路径
    NSString *filePath = [self filePath];
    // 创建流
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:filePath append:YES];
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    // 设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%llu-", self.currentLength];
    [request setValue:range forHTTPHeaderField:@"Range"];
    //创建一个Data任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    // 保存任务
    self.downloadTask = task;

    self.stream = stream;
    
    [self.downloadTask resume];
    [self stateChangeWithState:MLMDownloadStart];
}

#pragma mark - 停止下载
- (void)stop {
    [self suspend];
    
    [self.stream close];
    self.downloadTask = nil;
    self.stream = nil;
}

#pragma mark - 判断文件是否下载完成
- (BOOL)isCompletion {
    if (self.allLength && self.allLength == self.currentLength) {
        return YES;
    }
    return NO;
}

#pragma mark - 删除
- (void)deleteFile {
    [self stop];
    [self saveAllLength:0];
    [MLMDownloadRequest deletePath:[self filePath]];
}

#pragma mark NSURLSessionDataDelegate
/**
 * 接收到响应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    //打开流
    [self.stream open];
    
    if (self.allLength == 0) {
        //第一次下载，返回数据的总长度
        NSInteger totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] + self.currentLength;
        [self saveAllLength:totalLength];
    }

    // 接收这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
}

/**
 * 接收到服务器返回的数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    //写入数据
    [self.stream write:data.bytes maxLength:data.length];
    //下载进度
    CGFloat progress = 1.0 * self.currentLength/self.allLength;
    [self progressChangeWithProgress:progress];
}

/**
 * 请求完毕（成功|失败）
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    //是否下载完成
    if ([self isCompletion]) {
        [self stateChangeWithState:MLMDownloadCompleted];
    } else if (error) {
        [self stateChangeWithState:MLMDownloadFailed];
    }
    
    //关闭流
    [self.stream close];
    
    self.downloadTask = nil;
    self.stream = nil;
}

- (void)dealloc {
    self.delegate = nil;
}




@end
