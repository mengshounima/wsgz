//
//  HttpClient.m
//  beiying
//
//  Created by Shen Jun on 15/5/26.
//  Copyright (c) 2015年 沈骏. All rights reserved.
//

#import "HttpClient.h"
#import "RTJSONResponseSerializerWithData.h"

@interface HttpClient()
//请求管理对象
@property (strong, nonatomic) AFHTTPSessionManager *manager;
// 请求对象
@property (strong, nonatomic) NSMutableURLRequest *request;


@end

@implementation HttpClient

static id _instace;

- (id)init
{
    if (self = [super init]) {//父类init方法
            self.manager = [AFHTTPSessionManager manager];
        
        
            self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            self.manager.requestSerializer.timeoutInterval = 15;
        
        
            //响应结果序列化类型
            self.manager.responseSerializer = [RTJSONResponseSerializerWithData serializer];
        
            //设置相应内容类型，返回可解析类型
            self.manager.responseSerializer.acceptableContentTypes =
            [NSSet setWithObjects:@"application/json",@"charset=utf-8",@"image/jpeg",@"text/html",nil];
            
            
            // 1.获得网络监控的管理者
            AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
            
            // 2.设置网络状态改变后的处理
            [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
                // 当网络状态改变了, 就会调用这个block
                switch (status) {
                    case AFNetworkReachabilityStatusUnknown: // 未知网络
                        //NSLog(@"未知网络");
                        self.netWorkStaus = AFNetworkReachabilityStatusUnknown;
                        [self showExceptionDialog];
                        break;
                        
                    case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
                        //NSLog(@"没有网络(断网)");
                        self.netWorkStaus = AFNetworkReachabilityStatusNotReachable;
                        [self showExceptionDialog];
                        break;
                        
                    case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
                        //MyLog(@"手机自带网络");
                        self.netWorkStaus = AFNetworkReachabilityStatusReachableViaWWAN;
                        break;
                        
                    case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
                        //MyLog(@"WIFI");
                        self.netWorkStaus = AFNetworkReachabilityStatusReachableViaWiFi;
                        break;
                }
            }];
            
            // 3.开始监控
            [mgr startMonitoring];
    }
    
    return self;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _instace = [super allocWithZone:zone];
    });
    return _instace;
}

+ (instancetype)httpClient
{
    return [[HttpClient alloc] init];
}

- (void)requestWithPath:(NSString *)url
                 method:(NSInteger)method
             parameters:(id)parameters prepareExecute:(PrepareExecuteBlock)prepareExecute
                success:(void (^)(NSURLSessionDataTask *, id))success
                failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    //请求的URL
    NSLog(@"参数%@",parameters);
    
    if (prepareExecute) {
        prepareExecute();
    }
    //切割
    NSString *urlStr;
    NSString *httpStr = [url substringToIndex:4];
    if ([httpStr isEqualToString:@"http"]) {
        urlStr = url;
    }
    else
    {
        urlStr = [NSString stringWithFormat:@"%@%@", BASEURlSTR, url];
    }
    
    
    switch (method) {
        case TBHttpRequestGet:
        {
            [self.manager GET:urlStr parameters:parameters progress:nil success:success failure:failure];
        }
            break;
        case TBHttpRequestPost:
        {
            [self.manager POST:urlStr parameters:parameters progress:nil success:success failure:failure];
        }
            break;
        case TBHttpRequestDelete:
        {
            [self.manager DELETE:urlStr parameters:parameters success:success failure:failure];
        }
            break;
        case TBHttpRequestPut:
        {
            [self.manager PUT:urlStr parameters:parameters success:success failure:false];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 请求管理请求,带data数据
- (void)requestOperaionManageWithURl:(NSString *)urlStr
                          httpMethod:(NSInteger)method
                          parameters:(id)parameters
                            bodyData:(NSArray *)bodyData
                          DataNumber:(NSInteger)number
                             success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                             failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSString *url = [NSString stringWithFormat:@"%@%@", BASEURlSTR, urlStr];
   switch (method) {
        case TBHttpRequestGet:
        {
            [self.manager GET:url parameters:parameters progress:nil success:success failure:failure];
           
        }
            break;
        case TBHttpRequestPost:
        {

            
            [self.manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
             {
                 for (int i =0 ; i<number; i++) {
                     [formData appendPartWithFileData:bodyData[i] name:@"pics" fileName:@".png" mimeType:@"image/png"];
                  
                     
                 }

             }progress:nil success:success failure:failure];
            
            
        }
        default:
            break;
    }
}

- (void)downloadWithURl:(NSString *)urlStr httpMethod:(NSInteger)method bodyData:(NSData *)bodyData success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    NSString *url = [NSString stringWithFormat:@"%@/policyupload/%@", BASEURlSTR, urlStr];
    
    NSString *resultUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLRequest *request =  [NSURLRequest requestWithURL:[NSURL URLWithString:resultUrl]];
    NSURLSessionDownloadTask *task = [self.manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //拼接缓存目录
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Report"];

        NSFileManager *fileManager = [NSFileManager defaultManager];

        [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];

        NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];

        return [NSURL fileURLWithPath:filePath];

    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSURLRequest *request = [NSURLRequest requestWithURL:filePath];
        if (success) {
            success(request);
        }
    }];
    
       [task resume];
}


// 弹出网络错误提示框
- (void)showExceptionDialog
{
    [[[UIAlertView alloc] initWithTitle:@"提示"
                                message:@"网络异常,请检查网络连接"
                               delegate:self
                      cancelButtonTitle:@"好的"
                      otherButtonTitles:nil, nil] show];
}


@end
