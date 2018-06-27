//
//  ViewController.m
//  MLMDownload
//
//  Created by MAC on 2018/6/27.
//  Copyright © 2018年 MAC. All rights reserved.
//

#import "ViewController.h"
#import "MLMDownloadRequest.h"

@interface ViewController () <MLMDownloadRequestDelegate>

@property (weak, nonatomic) IBOutlet UITextField *urlTf;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;
@property (weak, nonatomic) IBOutlet UIButton *resumeBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UILabel *progressLab;
@property (weak, nonatomic) IBOutlet UITextView *stateTextView;

@property (nonatomic, strong) MLMDownloadRequest *downLoad;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.progress.progress = self.downLoad.progress;
    self.progressLab.text = [NSString stringWithFormat:@"%.2f",self.downLoad.progress];
}

- (IBAction)startAction:(UIButton *)sender {
    self.downLoad.url = self.urlTf.text;
    [self.downLoad downLoad];
}

- (IBAction)pauseAction:(UIButton *)sender {
    [self.downLoad suspend];
}

- (IBAction)resumeAction:(UIButton *)sender {
    [self.downLoad resume];
}


#pragma mark - MLMDownloadRequestDelegate
- (void)progressChangeWithRequest:(MLMDownloadRequest *)request withProgress:(CGFloat)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progress.progress = self.downLoad.progress;
        self.progressLab.text = [NSString stringWithFormat:@"%.2f",progress];
    });
}

- (void)stateChangeWithRequest:(MLMDownloadRequest *)request {
    NSString *msg = @"未知状态";
    switch (request.state) {
        case MLMDownloadStart:
        {
            msg = @"下载开始\n";
        }
            break;
        case MLMDownloadSuspended:
        {
            msg = @"下载暂停\n";
        }
            break;
        case MLMDownloadCompleted:
        {
            msg = @"下载完成\n";
        }
            break;
        case MLMDownloadFailed:
        {
            msg = @"下载失败\n";
        }
            break;
        default:
            break;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableString *text = [NSMutableString stringWithString:self.stateTextView.text];
        [text appendString:msg];
        self.stateTextView.text = text;
    });
}

- (MLMDownloadRequest *)downLoad {
    if (!_downLoad) {
        _downLoad = [[MLMDownloadRequest alloc] init];
        _downLoad.delegate = self;
        _downLoad.url = self.urlTf.text;
    }
    return _downLoad;
}

@end
