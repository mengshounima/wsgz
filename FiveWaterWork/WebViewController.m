//
//  WebViewController.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 2017/10/5.
//  Copyright © 2017年 aty. All rights reserved.
//

#import "WebViewController.h"
#import <Masonry/Masonry.h>

@interface WebViewController ()

@property (nonatomic, strong) NSURLRequest *request;

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation WebViewController

- (instancetype)initWithRequest:(NSURLRequest *)request {
    if (self = [super init]) {
        _request = request;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"预览";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    
    _webView = [[UIWebView alloc] init];
    [self.view addSubview:_webView];
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [_webView loadRequest:_request];
}

- (void)close {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
